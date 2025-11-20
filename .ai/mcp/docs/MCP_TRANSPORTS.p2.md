---
id: 7f3a8b2c-9d4e-5f1a-8c7b-6e5d4c3b2a1f
doc_type: architecture-reference
scope: mcp-global-deployment
purpose: explain-transport-mechanisms-and-concurrency
last_updated: 2025-11-19
status: active
---

# MCP Server Transport Mechanisms & Concurrent Access

This document explains the different transport mechanisms used by MCP (Model Context Protocol) servers, how to properly deploy them, and how concurrent access works.

---

## Transport Types

MCP servers can communicate using different transport mechanisms:

### 1. **stdio (Standard Input/Output)**
- Communication via stdin/stdout streams
- No network port required
- Used for **local process communication**
- Most common for desktop/CLI MCP servers

### 2. **HTTP/SSE (Server-Sent Events)**
- Communication via HTTP endpoints
- Requires a network port
- Used for **remote/network communication**
- Enables Traefik routing and remote access

---

## Concurrent Access: The Critical Question

### **TL;DR: Yes, multiple agents can safely access stdio containers simultaneously via `docker exec -i`**

Each `docker exec` session creates an **isolated process** with its own:
- ✅ stdin/stdout file descriptors (no crosstalk)
- ✅ Memory space (no shared state)
- ✅ Process ID (independent lifecycle)
- ✅ Request context (stateless by design)

**Tested and verified**: Two simultaneous `docker exec -i thinking node dist/index.js` sessions completed independently without interference.

---

## How Concurrent Access Works

### Process Isolation Model

```
┌─────────────────────────────────────────────────────────────┐
│                    Container: "thinking"                     │
│                                                               │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐│
│  │   PID 1        │  │   PID 47       │  │   PID 52       ││
│  │ node dist/...  │  │ node dist/...  │  │ node dist/...  ││
│  │                │  │                │  │                ││
│  │ (main CMD)     │  │ (agent A exec) │  │ (agent B exec) ││
│  │ stdin: idle    │  │ stdin: Agent A │  │ stdin: Agent B ││
│  │ stdout: idle   │  │ stdout: Agent A│  │ stdout: Agent B││
│  └────────────────┘  └────────────────┘  └────────────────┘│
│                                                               │
│  Shared: filesystem, network namespace, kernel resources     │
│  Isolated: memory, stdin/stdout, CPU time, process state     │
└─────────────────────────────────────────────────────────────┘
```

### What Happens on Each `docker exec -i`

1. **New process spawned** inside the container
2. **Independent stdin/stdout** connected to the client
3. **Separate memory space** for that Node.js/Python instance
4. **Isolated execution** - no knowledge of other processes
5. **Clean termination** when request completes

### Example: Two Agents Accessing Simultaneously

```bash
# Terminal 1 (Agent A)
echo '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' | \
  docker exec -i thinking node dist/index.js

# Terminal 2 (Agent B) - runs at the same time
echo '{"jsonrpc":"2.0","id":2,"method":"tools/list"}' | \
  docker exec -i thinking node dist/index.js
```

**Result**: Both complete successfully, each gets their own response, no interference.

---

## Potential Concurrency Issues (and Mitigations)

### ⚠️ **Issue 1: Shared File System**

**Problem**: If multiple processes write to the same file path simultaneously.

```javascript
// Problematic code in MCP server
fs.writeFileSync('/tmp/state.json', data);  // ← Race condition!
```

**Mitigation**:
- Most MCP servers are **stateless** and don't write to disk
- If they do, they use unique filenames (PID-based, UUID, etc.)
- stdio servers typically don't persist state

**Impact**: ⭐ Low for most MCP servers

---

### ⚠️ **Issue 2: Resource Exhaustion**

**Problem**: Too many concurrent `docker exec` processes consume all memory/CPU.

```bash
# 100 agents all hitting the same container
for i in {1..100}; do
  docker exec -i thinking node dist/index.js &
done
# Could exhaust container resources
```

**Mitigation**:
- Set container resource limits in docker-compose:
  ```yaml
  sequentialthinking:
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 1G
        reservations:
          memory: 256M
  ```
- Monitor with `docker stats`
- Use a queue/proxy if >10 concurrent agents expected

**Impact**: ⭐⭐ Medium (only if many concurrent agents)

---

### ⚠️ **Issue 3: PID 1 Main Process**

**Problem**: The main container process (PID 1) might already be running the MCP server.

**Current situation**:
```bash
$ docker exec thinking ps aux
PID   USER     TIME  COMMAND
  1   root     0:00  node dist/index.js  # ← Already running, waiting for stdin
```

**Scenarios**:

1. **PID 1 is idle** (stdin_open: true but nothing connected)
   - ✅ Harmless, just wastes a bit of memory
   - Each `docker exec` creates new instances

2. **PID 1 is being used** (via `docker attach`)
   - ⚠️ Only one agent can `docker attach` at a time
   - Other agents should use `docker exec` instead

**Best Practice**:
- Don't use PID 1 for agent connections
- Always use `docker exec -i container cmd` for concurrent access
- Or change CMD to `tail -f /dev/null` and only use exec

**Impact**: ⭐ Low (use exec, not attach)

---

### ⚠️ **Issue 4: Server Assumes Single Instance**

**Problem**: Server code assumes it's the only instance and uses global state.

```javascript
// Problematic pattern
let globalState = {};  // Shared across requests - but NOT across processes!

function handleRequest(req) {
  globalState.lastRequest = req;  // Only affects THIS process
}
```

**Reality**: In separate processes, "global" state is **per-process**, so no conflict.

**Mitigation**: None needed - process isolation handles this.

**Impact**: ⭐ None (process isolation prevents this)

---

## When Concurrent Access WILL Cause Problems

### ❌ **HTTP Servers with Shared Database**

```yaml
# If multiple HTTP server instances share a database without proper locking
memory-instance-1:  # Writes to FalkorDB
memory-instance-2:  # Also writes to FalkorDB
# ← Need database-level transaction handling!
```

**Solution**: Use proper database transactions, row-level locking, or optimistic concurrency control.

### ❌ **Stateful HTTP Sessions**

```python
# Server maintains session state in memory
sessions = {}  # Only one HTTP server instance can manage this

@app.post("/start-session")
def start():
    sessions[session_id] = {...}
```

**Solution**: Use external session store (Redis, database) or sticky sessions.

---

## Recommended Deployment Patterns

### Pattern 1: **Global stdio Container** (Current Approach)

```yaml
sequentialthinking:
  image: mcp/sequentialthinking
  container_name: thinking
  stdin_open: true
  tty: true
  deploy:
    resources:
      limits:
        cpus: '1.0'
        memory: 512M
```

**Access**:
```bash
docker exec -i thinking node dist/index.js < request.json
```

**Pros**:
- ✅ Simple deployment
- ✅ Concurrent access works out-of-box
- ✅ No routing complexity

**Cons**:
- ❌ Must use docker exec (can't use HTTP clients)
- ❌ Resource limits apply to ALL agents combined

**Best for**: 5-10 concurrent agents, stateless tools

---

### Pattern 2: **HTTP Wrapper for stdio**

```yaml
thinking-http:
  image: node:20-alpine
  command: |
    sh -c "npm install -g mcp-remote-server &&
           mcp-remote-server \
             --stdio-command 'docker exec -i thinking node dist/index.js' \
             --port 9001"
  ports:
    - "9001:9001"
  labels:
    traefik.enable: true
    traefik.http.services.thinking.loadbalancer.server.port: 9001
    traefik.http.routers.thinking.rule: Host(`thinking.localhost`)
  depends_on:
    - sequentialthinking
```

**Access**:
```bash
npx mcp-remote http://thinking.localhost --allow-http
```

**Pros**:
- ✅ HTTP access (MCP clients work natively)
- ✅ Traefik routing
- ✅ Concurrent requests handled by wrapper

**Cons**:
- ❌ Additional wrapper layer
- ❌ More complex setup

**Best for**: HTTP-only MCP clients, >10 concurrent agents

---

### Pattern 3: **Per-Project Instance**

```yaml
# In project-specific docker-compose.yml
project-thinking:
  image: mcp/sequentialthinking
  stdin_open: true
  tty: true
```

**Access**: Same as Pattern 1, but container is project-scoped.

**Pros**:
- ✅ Complete isolation between projects
- ✅ Independent resource limits
- ✅ Can customize per-project

**Cons**:
- ❌ More container overhead
- ❌ Duplicate containers if multiple projects

**Best for**: Heavy usage by specific projects, isolation requirements

---

## Testing Concurrent Access

### Test 1: Basic Concurrency

```bash
#!/bin/bash
# test_concurrency.sh

echo "Testing concurrent access to thinking container..."

# Start 5 simultaneous requests
for i in {1..5}; do
  echo '{"jsonrpc":"2.0","id":'$i',"method":"tools/list","params":{}}' | \
    docker exec -i thinking node dist/index.js > /tmp/response_$i.json &
done

wait
echo "All requests completed"

# Check all responses are valid JSON
for i in {1..5}; do
  if jq empty /tmp/response_$i.json 2>/dev/null; then
    echo "✓ Response $i: valid"
  else
    echo "✗ Response $i: INVALID"
  fi
done
```

### Test 2: Resource Monitoring

```bash
# Terminal 1: Monitor resources
watch -n 1 'docker stats thinking --no-stream'

# Terminal 2: Generate load
for i in {1..20}; do
  echo '{"jsonrpc":"2.0","id":'$i',"method":"tools/list"}' | \
    docker exec -i thinking node dist/index.js &
done
```

### Test 3: Process Count

```bash
# Check how many processes are running
while true; do
  docker exec thinking ps aux | wc -l
  sleep 1
done

# Run concurrent requests in another terminal
# Watch process count spike and return to baseline
```

---

## Current Global Deployment Status

### ✅ HTTP Servers (Native Concurrent Support)

| Service | Port | Concurrency Model | Safe for Multiple Agents |
|---------|------|-------------------|-------------------------|
| memory | 8000 | HTTP server with async handlers | ✅ Yes (use group_id for isolation) |
| simplechecklist | 8355 | HTTP API + database | ✅ Yes (database handles concurrency) |
| falkordb (UI) | 3000 | Next.js web app | ✅ Yes (web UI, not MCP) |

### ✅ stdio Servers (Process-Isolated)

| Service | Method | Concurrent Access | Notes |
|---------|--------|------------------|-------|
| sequentialthinking | `docker exec -i` | ✅ **YES** | Each exec = new process |
| duckduckgo | `docker exec -i` | ✅ **YES** | Stateless search queries |
| gitlab | `docker exec -i` | ✅ **YES** | API calls, no shared state |
| gitlab-sscm | `docker exec -i` | ✅ **YES** | API calls, no shared state |
| time | `docker exec -i` | ✅ **YES** | Stateless time queries |
| dockerhub | `docker exec -i` | ✅ **YES** | API calls, no shared state |

**Verification**: All tested with concurrent `docker exec` - no conflicts observed.

---

## Best Practices

### ✅ **DO**

1. **Use `docker exec -i` for concurrent stdio access**
   ```bash
   docker exec -i thinking node dist/index.js < request.json
   ```

2. **Set resource limits on shared containers**
   ```yaml
   deploy:
     resources:
       limits:
         cpus: '2.0'
         memory: 1G
   ```

3. **Monitor resource usage**
   ```bash
   docker stats thinking
   ```

4. **Keep stdio servers stateless** (they usually are)

5. **Use HTTP servers for high-concurrency scenarios** (>20 agents)

### ❌ **DON'T**

1. **Don't use `docker attach`** - only one session possible
   ```bash
   docker attach thinking  # ← Only one agent can do this
   ```

2. **Don't assume stdio servers have state isolation** - verify they're stateless

3. **Don't skip resource limits** on shared containers

4. **Don't run 100+ concurrent execs** without testing first

---

## Monitoring Concurrent Usage

### Real-Time Process Count

```bash
# Count active MCP server processes
docker exec thinking ps aux | grep -c "node dist/index.js"
```

### Resource Usage

```bash
# CPU and memory usage
docker stats thinking --no-stream --format \
  "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.PIDs}}"
```

### Request Rate

```bash
# Log each docker exec invocation
alias mcp-exec='echo "[$(date +%T)] docker exec -i" && docker exec -i'

# Use instead of docker exec
echo '...' | mcp-exec thinking node dist/index.js
```

---

## FAQ

**Q: Will two agents interfere with each other when using the same stdio container?**

A: **No.** Each `docker exec` creates an isolated process with separate stdin/stdout. Tested and verified.

---

**Q: What's the maximum number of concurrent agents that can access a stdio container?**

A: Depends on:
- Container resource limits (CPU, memory)
- MCP server resource usage per request
- Host system resources

**General guideline**:
- **1-10 agents**: No problem
- **10-50 agents**: Set resource limits, monitor
- **50+ agents**: Consider HTTP wrapper or multiple instances

---

**Q: Is the PID 1 main process a problem?**

A: **No.** It's just an idle process waiting for stdin that never comes. Each agent uses `docker exec` which creates new processes.

**Optional optimization**: Change CMD to `tail -f /dev/null` to save ~50MB RAM.

---

**Q: Can I use `docker attach` instead of `docker exec`?**

A: **No, not for concurrent access.** Only one `docker attach` session is possible at a time. Always use `docker exec -i` for agents.

---

**Q: Do stdio servers maintain conversation history across requests?**

A: **No.** Each `docker exec` session is independent. If you need conversation history, use:
- HTTP server with session management
- External state store (database, Redis)
- Client-side conversation tracking

---

**Q: Should I move stdio servers to per-project deployments?**

A: Only if:
- ❌ One project dominates usage (>80% of requests)
- ❌ You need strict resource isolation
- ❌ Different projects need different versions/configs

Otherwise, global deployment with `docker exec` works great.

---

## Conclusion

### **Concurrent Access via `docker exec -i` is SAFE** ✅

- Each execution is an isolated process
- No stdin/stdout crosstalk
- No memory sharing between processes
- Tested and verified with multiple simultaneous requests

### **Deployment Recommendation**

For your current setup (5-10 agents, stateless tools):

✅ **Keep stdio servers in global deployment**
✅ **Access via `docker exec -i container cmd`**
✅ **Set resource limits to prevent exhaustion**
✅ **Monitor with `docker stats` periodically**

### **When to Reconsider**

- You hit resource limits (>50 concurrent agents)
- You need HTTP access for client compatibility
- You want request queuing/rate limiting
- You need session/conversation state

At that point, add HTTP wrappers or move to HTTP-native MCP servers.

---

## Related Documentation

- `MULTIPLE_DB_UIS.md` - Subdomain vs path-based routing patterns
- `global.yaml` - Current deployment configuration
- `.rules` - Project operational rules

---

**Last Updated**: 2025-11-19  
**Status**: Active, tested, and verified
