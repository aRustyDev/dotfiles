---
id: 5e6f7a8b-9c0d-1e2f-3a4b-5c6d7e8f9a0b
doc_type: operations-guide
scope: mcp-global-deployment
purpose: healthcheck-configuration-reference
last_updated: 2025-11-19
status: active
---

# MCP Server Healthcheck Guide

This guide provides healthcheck configurations for both stdio-based and HTTP-based MCP servers in Docker Compose.

---

## Why Healthchecks Matter

Healthchecks enable:

- ✅ **Dependency management** - Services wait for dependencies to be healthy
- ✅ **Automatic recovery** - Docker can restart unhealthy containers
- ✅ **Monitoring** - External tools can track service health
- ✅ **Rolling deployments** - New containers only start when healthy
- ✅ **Load balancing** - Unhealthy instances removed from rotation

---

## Healthcheck Anatomy

```yaml
healthcheck:
  test: ["CMD-SHELL", "command to test health"]
  interval: 30s        # How often to check
  timeout: 10s         # Max time for check to complete
  retries: 3           # Failures before marking unhealthy
  start_period: 40s    # Grace period during startup
```

**States**:
1. `starting` - Within start_period, failures don't count
2. `healthy` - Check passed
3. `unhealthy` - Failed `retries` consecutive checks

---

## stdio MCP Servers

### Challenge

stdio servers have **no HTTP endpoint** to check, so traditional healthchecks don't work.

### Solution Options

#### Option 1: Process Check (Recommended for Simple Cases)

Check if the server process is running:

```yaml
sequentialthinking:
  image: mcp/sequentialthinking
  container_name: thinking
  stdin_open: true
  tty: true
  healthcheck:
    test: ["CMD-SHELL", "ps aux | grep -q '[n]ode dist/index.js' || exit 1"]
    interval: 30s
    timeout: 5s
    retries: 3
    start_period: 10s
```

**Pros**:
- ✅ Fast and lightweight
- ✅ No external dependencies
- ✅ Catches crashed processes

**Cons**:
- ❌ Doesn't verify MCP server is responsive
- ❌ Process might be hung but still "running"

---

#### Option 2: Functional Check (Most Reliable)

Actually test the MCP server by sending a request:

```yaml
sequentialthinking:
  image: mcp/sequentialthinking
  container_name: thinking
  stdin_open: true
  tty: true
  healthcheck:
    test:
      [
        "CMD-SHELL",
        "echo '{\"jsonrpc\":\"2.0\",\"method\":\"tools/list\",\"id\":1}' | timeout 5 node dist/index.js | grep -q '\"jsonrpc\":\"2.0\"' || exit 1",
      ]
    interval: 30s
    timeout: 10s
    retries: 3
    start_period: 15s
```

**How it works**:
1. Sends a `tools/list` JSON-RPC request to stdin
2. Waits up to 5 seconds for response
3. Checks if response contains valid JSON-RPC
4. Exits 0 (healthy) or 1 (unhealthy)

**Pros**:
- ✅ Verifies MCP server is actually responding
- ✅ Tests end-to-end functionality
- ✅ Catches hung processes

**Cons**:
- ❌ Spawns new process each check (overhead)
- ❌ Slower than process check
- ❌ Might interfere with concurrent requests

---

#### Option 3: No Healthcheck (Acceptable)

For simple stdio servers with `depends_on` only:

```yaml
sequentialthinking:
  image: mcp/sequentialthinking
  container_name: thinking
  stdin_open: true
  tty: true
  # No healthcheck - just ensure container is running
```

**When to use**:
- Low-criticality services
- Wrapper service handles health monitoring
- Resource-constrained environments

---

## HTTP MCP Servers

### Native HTTP Servers

For servers with built-in HTTP endpoints (like `memory`):

```yaml
memory:
  image: zepai/knowledge-graph-mcp:standalone
  container_name: memory
  ports:
    - "8000:8000"
  healthcheck:
    test:
      [
        "CMD-SHELL",
        "wget --no-verbose --tries=1 --spider http://localhost:8000/health || curl -f http://localhost:8000/health || exit 1",
      ]
    interval: 15s
    timeout: 10s
    retries: 3
    start_period: 30s
  environment:
    - FALKORDB_URI=redis://falkordb:6379
  depends_on:
    falkordb:
      condition: service_healthy
```

**Best practices**:
- Use `/health` endpoint if available
- Otherwise use `/mcp` with lightweight request
- Include both `wget` and `curl` for compatibility
- Set longer `start_period` for slow-starting services

---

### HTTP Wrapper Services

For stdio-to-HTTP wrappers (like `thinking-http` with mcp-proxy):

```yaml
thinking-http:
  image: node:20-alpine
  container_name: thinking-http
  command: >
    sh -c "npm install -g mcp-proxy &&
           mcp-proxy --host 0.0.0.0 --port 8080 --stateless
                     docker exec -i thinking node dist/index.js"
  ports:
    - "9001:8080"
  volumes:
    - /var/run/docker.sock:/var/run/docker.sock
  healthcheck:
    test:
      [
        "CMD-SHELL",
        "wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1",
      ]
    interval: 15s
    timeout: 10s
    retries: 3
    start_period: 30s
  depends_on:
    sequentialthinking:
      condition: service_healthy
```

**Key points**:
- Check the wrapper's HTTP endpoint, not the underlying stdio server
- `start_period` accounts for npm install time
- Depend on stdio service being healthy first

---

## Common Patterns by Service Type

### Database Servers

```yaml
falkordb:
  image: falkordb/falkordb:latest
  ports:
    - "6379:6379"
  healthcheck:
    test: ["CMD", "redis-cli", "-p", "6379", "ping"]
    interval: 10s
    timeout: 5s
    retries: 5
    start_period: 10s
```

### Python MCP Servers

```yaml
duckduckgo:
  image: mcp/duckduckgo
  stdin_open: true
  tty: true
  healthcheck:
    test:
      [
        "CMD-SHELL",
        "ps aux | grep -q '[p]ython -m duckduckgo' || exit 1",
      ]
    interval: 30s
    timeout: 5s
    retries: 3
    start_period: 10s
```

### Node.js MCP Servers

```yaml
gitlab:
  image: mcp/gitlab
  stdin_open: true
  tty: true
  healthcheck:
    test: ["CMD-SHELL", "ps aux | grep -q '[n]ode dist/index.js' || exit 1"]
    interval: 30s
    timeout: 5s
    retries: 3
    start_period: 10s
  environment:
    GITLAB_PERSONAL_ACCESS_TOKEN: "${GITLAB_TOKEN}"
```

### Web UIs (Next.js, React)

```yaml
falkordb-ui:
  image: falkordb/falkordb:latest
  ports:
    - "3000:3000"
  healthcheck:
    test:
      [
        "CMD-SHELL",
        "wget --no-verbose --tries=1 --spider http://localhost:3000 || exit 1",
      ]
    interval: 10s
    timeout: 5s
    retries: 5
    start_period: 60s  # Next.js can take time to start
```

---

## Dependency Chains

### Basic Dependency

Wait for service to be running:

```yaml
thinking-http:
  depends_on:
    - sequentialthinking
```

### Healthy Dependency

Wait for service to pass healthcheck:

```yaml
thinking-http:
  depends_on:
    sequentialthinking:
      condition: service_healthy
```

### Multiple Dependencies

```yaml
memory:
  depends_on:
    falkordb:
      condition: service_healthy
    ollama-cpu:
      condition: service_healthy
    ollama-pull-models:
      condition: service_completed_successfully
```

---

## Testing Healthchecks

### Manual Test

```bash
# Check current health status
docker inspect thinking --format='{{.State.Health.Status}}'

# View health log
docker inspect thinking --format='{{json .State.Health}}' | jq

# Run healthcheck command manually
docker exec thinking sh -c "ps aux | grep -q '[n]ode dist/index.js' && echo healthy || echo unhealthy"
```

### Watch Health Status

```bash
# Watch health status change
watch -n 1 'docker ps --format "table {{.Names}}\t{{.Status}}"'

# Or with docker compose
docker compose -f global.yaml ps
```

### Force Healthcheck

```bash
# Trigger immediate healthcheck
docker inspect --format='{{.State.Health.Status}}' thinking
```

---

## Common Issues & Solutions

### Issue: "Health check probe error"

**Symptom**: Container keeps restarting

**Causes**:
- Command not found in container
- Timeout too short
- Insufficient `start_period`

**Fix**:
```yaml
healthcheck:
  start_period: 60s  # Increase grace period
  timeout: 15s       # Increase timeout
```

---

### Issue: "No such file or directory"

**Symptom**: Healthcheck fails with file not found

**Causes**:
- Binary not in container's PATH
- Using host paths instead of container paths

**Fix**:
```yaml
# Wrong
test: ["CMD", "curl", "http://localhost:8000"]

# Right - use full path or CMD-SHELL
test: ["CMD-SHELL", "command -v curl && curl -f http://localhost:8000 || wget --spider http://localhost:8000"]
```

---

### Issue: Container marked unhealthy but works fine

**Symptom**: docker ps shows `unhealthy`, but manual tests work

**Causes**:
- Healthcheck too strict
- Network delays
- Resource contention

**Fix**:
```yaml
healthcheck:
  retries: 5         # Increase retries
  interval: 30s      # Less frequent checks
  timeout: 15s       # More time to respond
```

---

### Issue: Service takes too long to start

**Symptom**: Healthcheck fails during startup

**Causes**:
- Insufficient `start_period`
- Heavy initialization (npm install, model loading)

**Fix**:
```yaml
healthcheck:
  start_period: 120s  # 2 minutes for slow services
  interval: 15s
  retries: 3
```

---

## Best Practices

### ✅ DO

1. **Use appropriate intervals**
   - Critical services: 10-15s
   - Normal services: 30s
   - Low-priority: 60s

2. **Set realistic timeouts**
   - Fast services: 5s
   - Network calls: 10s
   - Heavy operations: 15-30s

3. **Generous start_period**
   - Minimum: 2x normal startup time
   - Include npm install, model loading, etc.

4. **Include fallbacks**
   ```yaml
   test: ["CMD-SHELL", "curl -f http://localhost/health || wget --spider http://localhost/health || exit 1"]
   ```

5. **Use service_healthy for critical dependencies**
   ```yaml
   depends_on:
     database:
       condition: service_healthy
   ```

### ❌ DON'T

1. **Don't use complex checks**
   ```yaml
   # Too complex
   test: ["CMD-SHELL", "curl http://api/endpoint | jq .status | grep ok"]
   
   # Better
   test: ["CMD-SHELL", "curl -f http://api/health"]
   ```

2. **Don't check external services**
   ```yaml
   # Wrong - checks external API
   test: ["CMD-SHELL", "curl https://api.github.com"]
   
   # Right - checks this service
   test: ["CMD-SHELL", "curl http://localhost:8080/health"]
   ```

3. **Don't use short intervals on slow checks**
   ```yaml
   # Bad - spawns process every 5s
   interval: 5s
   test: ["CMD-SHELL", "echo ... | node dist/index.js"]
   
   # Better
   interval: 30s
   test: ["CMD-SHELL", "ps aux | grep node"]
   ```

4. **Don't forget start_period for slow services**
   ```yaml
   # Missing start_period - will fail during npm install
   thinking-http:
     command: "npm install && node server.js"
     healthcheck:
       test: ["CMD", "curl", "http://localhost:8080"]
   
   # Fixed
   thinking-http:
     healthcheck:
       start_period: 60s
   ```

---

## Reference: All Global Services

### Recommended Healthchecks

```yaml
services:
  # Database
  falkordb:
    healthcheck:
      test: ["CMD", "redis-cli", "-p", "6379", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 10s

  # Native HTTP MCP Server
  memory:
    healthcheck:
      test: ["CMD-SHELL", "wget --spider http://localhost:8000/health || exit 1"]
      interval: 15s
      timeout: 10s
      retries: 3
      start_period: 30s

  # stdio MCP Server (process check)
  sequentialthinking:
    healthcheck:
      test: ["CMD-SHELL", "ps aux | grep -q '[n]ode dist/index.js' || exit 1"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 10s

  # HTTP Wrapper
  thinking-http:
    healthcheck:
      test: ["CMD-SHELL", "wget --spider http://localhost:8080/health || exit 1"]
      interval: 15s
      timeout: 10s
      retries: 3
      start_period: 30s

  # Python stdio MCP Server
  duckduckgo:
    healthcheck:
      test: ["CMD-SHELL", "ps aux | grep -q '[p]ython' || exit 1"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 10s

  # GitLab MCP Server
  gitlab:
    healthcheck:
      test: ["CMD-SHELL", "ps aux | grep -q '[n]ode dist/index.js' || exit 1"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 10s

  # Ollama
  ollama-cpu:
    healthcheck:
      test: ["CMD-SHELL", "bash -c 'cat < /dev/null > /dev/tcp/localhost/11434'"]
      interval: 10s
      timeout: 5s
      retries: 10
      start_period: 60s

  # Simple Checklist (dual port)
  simplechecklist:
    healthcheck:
      test: ["CMD-SHELL", "wget --spider http://localhost:8355/health || exit 1"]
      interval: 15s
      timeout: 5s
      retries: 3
      start_period: 20s
```

---

## Monitoring Health Status

### Docker Compose

```bash
# View all service health
docker compose -f global.yaml ps

# Watch for changes
watch -n 2 'docker compose -f global.yaml ps'
```

### Docker CLI

```bash
# All containers with health status
docker ps --format "table {{.Names}}\t{{.Status}}"

# Specific container health details
docker inspect thinking --format='{{json .State.Health}}' | jq

# Health log (last 5 checks)
docker inspect thinking --format='{{json .State.Health.Log}}' | jq '.[0:5]'
```

### Automated Monitoring

```bash
#!/bin/bash
# check_mcp_health.sh

SERVICES=("thinking" "memory" "falkordb" "thinking-http")

for service in "${SERVICES[@]}"; do
  status=$(docker inspect "$service" --format='{{.State.Health.Status}}' 2>/dev/null)
  if [ "$status" != "healthy" ]; then
    echo "❌ $service: $status"
  else
    echo "✅ $service: $status"
  fi
done
```

---

## Debugging Failed Healthchecks

### Step 1: Check the healthcheck command

```bash
# View configured healthcheck
docker inspect thinking --format='{{json .Config.Healthcheck}}' | jq

# Expected output:
# {
#   "Test": ["CMD-SHELL", "ps aux | grep -q '[n]ode dist/index.js' || exit 1"],
#   "Interval": 30000000000,
#   "Timeout": 5000000000,
#   "Retries": 3,
#   "StartPeriod": 10000000000
# }
```

### Step 2: Run healthcheck manually

```bash
# Execute the healthcheck command inside container
docker exec thinking sh -c "ps aux | grep -q '[n]ode dist/index.js' && echo PASS || echo FAIL"
```

### Step 3: Check logs

```bash
# View healthcheck failures in logs
docker inspect thinking --format='{{json .State.Health.Log}}' | jq '.[] | select(.ExitCode != 0)'

# View container logs for errors
docker logs thinking --tail 50
```

### Step 4: Test incrementally

```bash
# Test each part of the command
docker exec thinking ps aux
docker exec thinking ps aux | grep node
docker exec thinking ps aux | grep -q '[n]ode dist/index.js' && echo yes || echo no
```

---

## Performance Impact

| Healthcheck Type | CPU Impact | Memory Impact | Network Impact | Recommendation |
|------------------|------------|---------------|----------------|----------------|
| Process check (`ps`) | Very Low | None | None | ✅ Default for stdio |
| HTTP check (local) | Low | None | Low | ✅ Default for HTTP |
| Functional check (spawn) | Medium | Medium | None | ⚠️ Use sparingly |
| External API check | Low | None | High | ❌ Avoid |

**Optimize by**:
- Using longer intervals (30-60s) for stable services
- Process checks over functional checks
- Avoiding complex parsing (jq, awk, etc.)

---

## Related Documentation

- `MCP_TRANSPORTS.md` - Understanding stdio vs HTTP transports
- `STDIO_HTTP_WRAPPERS.md` - HTTP wrapper implementations
- `global.yaml` - Current deployment configuration

---

**Last Updated**: 2025-11-19  
**Status**: Active, tested with Docker Compose 2.x
