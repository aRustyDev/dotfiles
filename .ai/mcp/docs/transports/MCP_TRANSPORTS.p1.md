---
id: 7f3a8b2c-9d4e-5f1a-8c7b-6e5d4c3b2a1f
doc_type: architecture-reference
scope: mcp-global-deployment
purpose: explain-transport-mechanisms
last_updated: 2025-11-19
status: active
---

# MCP Server Transport Mechanisms

This document explains the different transport mechanisms used by MCP (Model Context Protocol) servers and how to properly deploy them.

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

## Transport Detection

### Check if a Server Uses stdio:

```bash
# Run the container and check output
docker run --rm mcp/sequentialthinking

# Output: "Sequential Thinking MCP Server running on stdio"
# This means: NO network port, uses stdin/stdout
```

### Check if a Server Uses HTTP:

```bash
# Check container logs
docker logs memory 2>&1 | grep -i transport

# Output: "Running MCP server with streamable HTTP transport on 0.0.0.0:8000"
# This means: Listens on port 8000, accepts HTTP requests
```

### Inspect Image for Exposed Ports:

```bash
# Check if image exposes any ports
docker inspect mcp/sequentialthinking | jq '.[0].Config.ExposedPorts'

# null or {} = stdio transport
# {"8000/tcp": {}} = HTTP transport on port 8000
```

---

## Deployment Strategies

### stdio Servers (No HTTP Support)

**Services in this category:**
- `sequentialthinking` - Reasoning/planning tool
- `duckduckgo` - Web search (likely)
- `time` - Time utilities (likely)
- `gitlab` - GitLab API wrapper (likely)
- `dockerhub` - DockerHub operations (likely)

**Deployment Options:**

#### Option 1: **Project-Local stdio** (Recommended for stdio servers)

Run the container and connect via stdin/stdout:

```yaml
# In project-specific docker-compose.yml
sequentialthinking:
  image: mcp/sequentialthinking
  stdin_open: true
  tty: true
  # No ports, no Traefik labels
```

Connect using:
```bash
# Direct docker exec
docker exec -i thinking node dist/index.js < input.json

# Via MCP client with stdio transport
# (requires MCP client to support docker exec or similar)
```

#### Option 2: **stdio-to-HTTP Adapter** (Makes stdio servers network-accessible)

Use `mcp-remote` or similar to wrap stdio in HTTP:

```yaml
# Wrapper service that exposes stdio as HTTP
thinking-http:
  image: node:20-alpine
  command: npx -y mcp-remote-server --stdio-command "docker exec -i thinking node dist/index.js"
  ports:
    - "9001:9001"
  labels:
    traefik.enable: true
    traefik.http.services.thinking.loadbalancer.server.port: 9001
    traefik.http.routers.thinking.rule: Host(`thinking.localhost`)
  depends_on:
    - sequentialthinking
```

#### Option 3: **Keep stdio containers dormant** (Current approach)

Run containers but don't route traffic to them via Traefik:

```yaml
sequentialthinking:
  image: mcp/sequentialthinking
  stdin_open: true
  tty: true
  # Container runs but isn't accessible via HTTP
  # Can still be used via: docker exec -i thinking ...
```

**Current Status**: This is what you have now - containers running but not HTTP-accessible.

---

### HTTP Servers (Native HTTP Support)

**Services in this category:**
- `memory` (Graphiti Knowledge Graph) - Port 8000
- `simplechecklist` - Port 8355
- (Any server that explicitly listens on a port)

**Deployment:**

```yaml
memory:
  image: zepai/knowledge-graph-mcp:standalone
  ports:
    - "8000:8000"
  labels:
    traefik.enable: true
    traefik.http.services.memory.loadbalancer.server.port: 8000
    traefik.http.routers.memory-mcp.rule: Host(`mcp.localhost`) && PathPrefix(`/memory`)
    traefik.http.routers.memory-mcp.service: memory
    traefik.http.middlewares.strip-memory.stripprefix.prefixes: /memory
    traefik.http.routers.memory-mcp.middlewares: strip-memory
```

Connect using:
```bash
npx -y mcp-remote http://mcp.localhost/memory/mcp --allow-http
```

---

## Decision Matrix

| Scenario | Transport | Routing | Global/Local |
|----------|-----------|---------|--------------|
| Server has HTTP support built-in | HTTP | ✅ Traefik | Global |
| Server is stdio only, single user | stdio | ❌ No routing | Project-local |
| Server is stdio only, need remote access | HTTP wrapper | ✅ Traefik | Global (wrapped) |
| Server is stateless tool | Either | Optional | Global preferred |
| Server maintains state | Either | Optional | Per-project or use isolation |

---

## Current Global Deployment Status

### ✅ HTTP Servers (Routable via Traefik)

| Service | Port | URL | Status |
|---------|------|-----|--------|
| memory | 8000 | http://mcp.localhost/memory/mcp | ✅ Working |
| simplechecklist | 8355 | http://mcp.localhost/plan/checklist | ❓ Needs verification |
| falkordb (UI) | 3000 | http://falkor.ui.localhost | ✅ Working |

### ⚠️ stdio Servers (NOT Routable via Traefik)

| Service | Transport | Traefik Labels | Current Access Method |
|---------|-----------|----------------|----------------------|
| sequentialthinking | stdio | ❌ Removed (ineffective) | docker exec only |
| duckduckgo | stdio (likely) | ⚠️ Present but ineffective | docker exec only |
| gitlab | stdio (likely) | ⚠️ Present but ineffective | docker exec only |
| gitlab-sscm | stdio (likely) | ⚠️ Present but ineffective | docker exec only |
| time | stdio (likely) | ⚠️ Present but ineffective | docker exec only |
| dockerhub | stdio (likely) | ⚠️ Present but ineffective | docker exec only |

---

## Recommended Actions

### Immediate Actions

1. **Verify transport type** for each service:
   ```bash
   for svc in duckduckgo gitlab time dockerhub; do
     echo "=== $svc ==="
     docker logs $svc 2>&1 | grep -i "transport\|running on\|listening" | head -3
   done
   ```

2. **Remove ineffective Traefik labels** from stdio servers:
   - If a service has no HTTP port, Traefik labels do nothing
   - Clean up docker-compose.yml to avoid confusion

3. **Document access methods** for each service type

### Short-Term Solutions

**For stdio servers you want to access remotely:**

- Use an HTTP wrapper like `mcp-remote-server`
- Or use `mcp-proxy` to bridge stdio to HTTP
- Or rebuild the server with HTTP transport support

**For stdio servers used locally only:**

- Keep them in global compose but document they're stdio-only
- Create helper scripts for `docker exec` access
- Consider moving to project-local if only one project uses them

### Long-Term Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         Traefik                              │
│                    (HTTP/HTTPS Router)                       │
└─────────────────┬───────────────────────┬───────────────────┘
                  │                       │
        ┌─────────▼─────────┐   ┌────────▼──────────┐
        │  HTTP MCP Servers │   │ stdio-to-HTTP     │
        │  (native support) │   │    Wrappers       │
        ├───────────────────┤   ├───────────────────┤
        │ • memory          │   │ • thinking-proxy  │
        │ • checklist       │   │ • search-proxy    │
        │ • (future adds)   │   │ • time-proxy      │
        └───────────────────┘   └───────────────────┘
                                          │
                        ┌─────────────────▼─────────────────┐
                        │   stdio MCP Servers (containers)  │
                        │   • sequentialthinking            │
                        │   • duckduckgo                    │
                        │   • gitlab / time / dockerhub     │
                        └───────────────────────────────────┘
```

---

## Testing Transport Type

### Test stdio Server:

```bash
# This will hang waiting for stdin input (proving it's stdio)
docker exec -i thinking node dist/index.js
# Type: {"jsonrpc":"2.0","id":1,"method":"initialize","params":{}}
# Should get JSON response back
```

### Test HTTP Server:

```bash
# Should get HTTP response (not hang)
curl http://localhost:8000/health

# Or test MCP endpoint
curl -X POST http://localhost:8000/mcp/ \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{}}'
```

---

## Common Mistakes

❌ **Adding Traefik labels to stdio servers**
```yaml
# This does nothing - server has no port to route to
duckduckgo:
  image: mcp/duckduckgo
  stdin_open: true
  labels:
    traefik.enable: true  # ← Ineffective
    traefik.http.routers.duckduckgo.rule: PathPrefix(`/search`)  # ← No effect
```

❌ **Assuming all MCP servers support HTTP**
- Most MCP servers default to stdio
- HTTP support must be explicitly implemented
- Check documentation or test before assuming

❌ **Guessing port numbers**
- Always verify exposed ports via `docker inspect`
- Check server logs for "listening on" or "running on"
- Don't assume standard ports

✅ **Correct approach:**
1. Determine transport type (stdio vs HTTP)
2. For HTTP: verify actual port number
3. Configure routing accordingly
4. Test connectivity before marking as "working"

---

## FAQs

**Q: Can I convert a stdio server to HTTP?**

A: Yes, with a wrapper:
- Use `mcp-remote-server` to bridge stdio to HTTP
- Or modify the server source if you control it
- Or use a proxy like `socat` or custom bridge

**Q: Why are stdio servers in global-compose if they can't be routed?**

A: Several reasons:
- Keeps all MCP infrastructure in one place
- Allows docker exec access from any project
- Ready for future HTTP wrapper implementation
- Simpler than managing multiple compose files

**Q: Should I remove stdio servers from global deployment?**

A: Depends on usage:
- If used by multiple projects → keep global (add wrappers if needed)
- If project-specific → move to project compose
- If unused → remove entirely

**Q: How do I know if a server supports both transports?**

A: Check the server's documentation or source code:
- Some servers accept `--transport` flag: `--transport=http` or `--transport=stdio`
- Some auto-detect based on environment
- Most default to stdio unless configured otherwise

---

## Related Documentation

- `MULTIPLE_DB_UIS.md` - Subdomain vs path-based routing patterns
- `global.yaml` - Current deployment configuration
- `.rules` - Project operational rules (doesn't cover transports explicitly)

---

## Changelog

| Date | Change | Reason |
|------|--------|--------|
| 2025-11-19 | Initial creation | Document stdio vs HTTP transport confusion |
| 2025-11-19 | Added testing procedures | Help identify transport types |
| 2025-11-19 | Added decision matrix | Guide deployment choices |

---

**Key Takeaway**: Not all MCP servers can be accessed via HTTP/Traefik. Always verify the transport mechanism before configuring routing.
