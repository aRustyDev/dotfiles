---
id: 8d9e0f1a-2b3c-4d5e-6f7a-8b9c0d1e2f3a
doc_type: quick-reference
scope: mcp-global-deployment
purpose: healthcheck-cheatsheet
last_updated: 2025-11-19
status: active
---

# MCP Server Healthcheck Cheatsheet

Quick reference for adding healthchecks to MCP servers in Docker Compose.

---

## Quick Copy-Paste Templates

### stdio MCP Server (Process Check)

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

**Pattern**: `ps aux | grep -q '[X]process_name' || exit 1`
- `[n]ode` matches "node" but not "grep node"
- `[p]ython` matches "python" but not "grep python"

---

### HTTP MCP Server (Native)

```yaml
memory:
  image: zepai/knowledge-graph-mcp:standalone
  container_name: memory
  ports:
    - "8000:8000"
  healthcheck:
    test: ["CMD-SHELL", "wget --spider http://localhost:8000/health || exit 1"]
    interval: 15s
    timeout: 10s
    retries: 3
    start_period: 30s
```

**Pattern**: `wget --spider http://localhost:PORT/health`

---

### HTTP Wrapper (mcp-proxy)

```yaml
thinking-http:
  image: node:20-alpine
  container_name: thinking-http
  command: "npm install -g mcp-proxy && mcp-proxy ..."
  ports:
    - "9001:8080"
  healthcheck:
    test: ["CMD-SHELL", "wget --spider http://localhost:8080/health || exit 1"]
    interval: 15s
    timeout: 10s
    retries: 3
    start_period: 30s  # Account for npm install time
  depends_on:
    sequentialthinking:
      condition: service_healthy
```

---

### Database (Redis/FalkorDB)

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

---

### Python MCP Server

```yaml
duckduckgo:
  image: mcp/duckduckgo
  container_name: websearch
  stdin_open: true
  tty: true
  healthcheck:
    test: ["CMD-SHELL", "ps aux | grep -q '[p]ython' || exit 1"]
    interval: 30s
    timeout: 5s
    retries: 3
    start_period: 10s
```

---

### Web UI (Next.js/React)

```yaml
falkordb-ui:
  image: falkordb/falkordb:latest
  ports:
    - "3000:3000"
  healthcheck:
    test: ["CMD-SHELL", "wget --spider http://localhost:3000 || exit 1"]
    interval: 15s
    timeout: 5s
    retries: 5
    start_period: 60s  # Next.js takes time to build
```

---

## Common Commands

### Process Checks

```bash
# Node.js
test: ["CMD-SHELL", "ps aux | grep -q '[n]ode' || exit 1"]

# Python
test: ["CMD-SHELL", "ps aux | grep -q '[p]ython' || exit 1"]

# Go binary
test: ["CMD-SHELL", "ps aux | grep -q '[m]cp-server' || exit 1"]

# Specific script
test: ["CMD-SHELL", "ps aux | grep -q '[d]ist/index.js' || exit 1"]
```

### HTTP Checks

```bash
# wget (most common)
test: ["CMD-SHELL", "wget --spider http://localhost:8000/health || exit 1"]

# wget verbose version
test: ["CMD-SHELL", "wget --no-verbose --tries=1 --spider http://localhost:8000/health || exit 1"]

# curl
test: ["CMD-SHELL", "curl -f http://localhost:8000/health || exit 1"]

# wget + curl fallback
test: ["CMD-SHELL", "wget --spider http://localhost:8000/health || curl -f http://localhost:8000/health || exit 1"]
```

### TCP Checks

```bash
# Check if port is listening
test: ["CMD-SHELL", "bash -c 'cat < /dev/null > /dev/tcp/localhost/8000' || exit 1"]

# nc (netcat) - if available
test: ["CMD-SHELL", "nc -z localhost 8000 || exit 1"]
```

### Database Checks

```bash
# Redis/FalkorDB
test: ["CMD", "redis-cli", "-p", "6379", "ping"]

# PostgreSQL
test: ["CMD", "pg_isready", "-U", "postgres"]

# MySQL
test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]

# MongoDB
test: ["CMD", "mongosh", "--eval", "db.adminCommand('ping')"]
```

---

## Timing Guidelines

| Service Type | interval | timeout | retries | start_period |
|--------------|----------|---------|---------|--------------|
| **Critical DB** | 10s | 5s | 5 | 10s |
| **HTTP MCP** | 15s | 10s | 3 | 30s |
| **stdio MCP** | 30s | 5s | 3 | 10s |
| **HTTP Wrapper** | 15s | 10s | 3 | 30-60s |
| **Web UI** | 15s | 5s | 5 | 60-120s |
| **Low Priority** | 60s | 10s | 3 | 30s |

---

## Dependency Patterns

### Wait for Container to Start

```yaml
service-b:
  depends_on:
    - service-a
```

### Wait for Healthy

```yaml
service-b:
  depends_on:
    service-a:
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

## Testing Commands

```bash
# Check health status
docker inspect thinking --format='{{.State.Health.Status}}'

# View health log
docker inspect thinking --format='{{json .State.Health}}' | jq

# Run healthcheck manually
docker exec thinking sh -c "ps aux | grep -q '[n]ode dist/index.js' && echo healthy || echo unhealthy"

# Watch all services
watch -n 2 'docker compose -f global.yaml ps'

# View health failures
docker inspect thinking --format='{{json .State.Health.Log}}' | jq '.[] | select(.ExitCode != 0)'
```

---

## Troubleshooting Quick Fixes

### Container immediately unhealthy
```yaml
# Increase start_period
healthcheck:
  start_period: 60s  # Was: 10s
```

### Healthcheck timeout
```yaml
# Increase timeout
healthcheck:
  timeout: 15s  # Was: 5s
```

### False failures (flaky)
```yaml
# Increase retries and interval
healthcheck:
  retries: 5     # Was: 3
  interval: 30s  # Was: 10s
```

### Command not found
```yaml
# Use CMD-SHELL instead of CMD
healthcheck:
  test: ["CMD-SHELL", "wget ... || curl ... || exit 1"]
```

### Slow service startup
```yaml
# Increase start_period significantly
healthcheck:
  start_period: 120s  # 2 minutes for npm install, model loading, etc.
```

---

## Common Mistakes

❌ **Wrong**: Checking external services
```yaml
test: ["CMD-SHELL", "curl https://api.github.com"]
```

✅ **Right**: Check this service
```yaml
test: ["CMD-SHELL", "curl http://localhost:8080/health"]
```

---

❌ **Wrong**: Using host paths
```yaml
test: ["CMD-SHELL", "curl http://thinking-http:8080/health"]
```

✅ **Right**: Use localhost in healthcheck
```yaml
test: ["CMD-SHELL", "curl http://localhost:8080/health"]
```

---

❌ **Wrong**: No start_period for slow services
```yaml
thinking-http:
  command: "npm install && ..."
  healthcheck:
    interval: 10s
```

✅ **Right**: Account for startup time
```yaml
thinking-http:
  command: "npm install && ..."
  healthcheck:
    start_period: 60s
    interval: 15s
```

---

❌ **Wrong**: Complex parsing
```yaml
test: ["CMD-SHELL", "curl http://localhost/api | jq .status | grep ok"]
```

✅ **Right**: Simple check
```yaml
test: ["CMD-SHELL", "curl -f http://localhost/health"]
```

---

## All Services Quick Reference

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

  # Native HTTP MCP
  memory:
    healthcheck:
      test: ["CMD-SHELL", "wget --spider http://localhost:8000/health || exit 1"]
      interval: 15s
      timeout: 10s
      retries: 3
      start_period: 30s

  # stdio Node.js MCP
  sequentialthinking:
    healthcheck:
      test: ["CMD-SHELL", "ps aux | grep -q '[n]ode dist/index.js' || exit 1"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 10s

  # stdio Python MCP
  duckduckgo:
    healthcheck:
      test: ["CMD-SHELL", "ps aux | grep -q '[p]ython' || exit 1"]
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
    depends_on:
      sequentialthinking:
        condition: service_healthy

  # Web API
  simplechecklist:
    healthcheck:
      test: ["CMD-SHELL", "wget --spider http://localhost:8355/health || exit 1"]
      interval: 15s
      timeout: 5s
      retries: 3
      start_period: 20s
```

---

## One-Liners

```bash
# Deploy with healthchecks
docker compose -f global.yaml up -d

# Check all health statuses
docker ps --format "table {{.Names}}\t{{.Status}}" | grep -i health

# Wait for service to be healthy
until [ "$(docker inspect thinking --format='{{.State.Health.Status}}')" == "healthy" ]; do sleep 1; done

# Restart unhealthy containers
docker ps -f health=unhealthy --format '{{.Names}}' | xargs docker restart

# View all failing healthchecks
for c in $(docker ps --format '{{.Names}}'); do docker inspect $c --format='{{.Name}}: {{.State.Health.Status}}' | grep unhealthy; done
```

---

## Related Documentation

- `HEALTHCHECKS.md` - Comprehensive healthcheck guide (714 lines)
- `MCP_TRANSPORTS.md` - Transport mechanisms
- `STDIO_HTTP_WRAPPERS.md` - HTTP wrapper implementations

---

**Last Updated**: 2025-11-19
