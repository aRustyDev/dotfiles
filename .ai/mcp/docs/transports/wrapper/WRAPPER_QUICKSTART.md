---
id: 4b5c6d7e-8f9a-0b1c-2d3e-4f5a6b7c8d9e
doc_type: quickstart-guide
scope: mcp-global-deployment
purpose: http-wrapper-quickstart
last_updated: 2025-11-19
status: active
---

# HTTP Wrapper Quick Start Guide

**Goal**: Add HTTP access to stdio-based MCP servers in 5 minutes using `mcp-proxy`.

---

## What You're Building

```
Before:  docker exec -i thinking node dist/index.js
After:   curl http://thinking.localhost/mcp
```

---

## Prerequisites

- Docker & Docker Compose
- Traefik running (already in your global.yaml)
- An existing stdio MCP server container

---

## Quick Start (Copy-Paste Ready)

### Step 1: Add Wrapper Service to global.yaml

Add this service definition after your stdio server:

```yaml
# Your existing stdio server (keep as-is)
sequentialthinking:
  image: mcp/sequentialthinking
  container_name: thinking
  stdin_open: true
  tty: true

# NEW: HTTP wrapper service
thinking-http:
  image: node:20-alpine
  container_name: thinking-http
  restart: unless-stopped
  command: >
    sh -c "npm install -g mcp-proxy &&
           mcp-proxy
             --host 0.0.0.0
             --port 8080
             --stateless
             docker exec -i thinking node dist/index.js"
  ports:
    - "9001:8080"
  volumes:
    - /var/run/docker.sock:/var/run/docker.sock
  labels:
    traefik.enable: true
    traefik.http.services.thinking.loadbalancer.server.port: 8080
    traefik.http.routers.thinking.rule: Host(`thinking.localhost`)
    traefik.http.routers.thinking.service: thinking
    traefik.http.routers.thinking.entrypoints: web
  depends_on:
    - sequentialthinking
```

### Step 2: Deploy

```bash
cd /Users/adamsm/.config/nix/.ai/mcp/deploy
docker compose -f global.yaml up -d thinking-http
```

### Step 3: Test

```bash
# Health check
curl http://thinking.localhost/health

# List tools
curl -X POST http://thinking.localhost/mcp \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"tools/list","id":1}'

# Use with mcp-remote
npx -y mcp-remote http://thinking.localhost/mcp --allow-http
```

---

## Template for Any stdio Server

Replace these values for any stdio MCP server:

```yaml
<NAME>-http:
  image: node:20-alpine
  container_name: <NAME>-http
  restart: unless-stopped
  command: >
    sh -c "npm install -g mcp-proxy &&
           mcp-proxy
             --host 0.0.0.0
             --port 8080
             --stateless
             docker exec -i <CONTAINER_NAME> <COMMAND> <ARGS>"
  ports:
    - "<HOST_PORT>:8080"
  volumes:
    - /var/run/docker.sock:/var/run/docker.sock
  labels:
    traefik.enable: true
    traefik.http.services.<NAME>.loadbalancer.server.port: 8080
    traefik.http.routers.<NAME>.rule: Host(`<NAME>.localhost`)
    traefik.http.routers.<NAME>.service: <NAME>
    traefik.http.routers.<NAME>.entrypoints: web
  depends_on:
    - <ORIGINAL_SERVICE>
```

**Example Values**:
- `<NAME>`: `thinking`, `search`, `gitlab`, etc.
- `<CONTAINER_NAME>`: `thinking`, `websearch`, `gitlab`, etc.
- `<COMMAND>`: `node dist/index.js`, `python main.py`, etc.
- `<HOST_PORT>`: `9001`, `9002`, `9003`, etc. (unique per service)

---

## Examples for Your Services

### DuckDuckGo Search

```yaml
search-http:
  image: node:20-alpine
  container_name: search-http
  restart: unless-stopped
  command: >
    sh -c "npm install -g mcp-proxy &&
           mcp-proxy
             --host 0.0.0.0
             --port 8080
             --stateless
             docker exec -i websearch python -m duckduckgo_search"
  ports:
    - "9002:8080"
  volumes:
    - /var/run/docker.sock:/var/run/docker.sock
  labels:
    traefik.enable: true
    traefik.http.services.search.loadbalancer.server.port: 8080
    traefik.http.routers.search.rule: Host(`search.localhost`)
    traefik.http.routers.search.service: search
    traefik.http.routers.search.entrypoints: web
  depends_on:
    - duckduckgo
```

### GitLab

```yaml
gitlab-http:
  image: node:20-alpine
  container_name: gitlab-http
  restart: unless-stopped
  command: >
    sh -c "npm install -g mcp-proxy &&
           mcp-proxy
             --host 0.0.0.0
             --port 8080
             --stateless
             docker exec -i gitlab node dist/index.js"
  ports:
    - "9003:8080"
  volumes:
    - /var/run/docker.sock:/var/run/docker.sock
  labels:
    traefik.enable: true
    traefik.http.services.gitlab-mcp.loadbalancer.server.port: 8080
    traefik.http.routers.gitlab-mcp.rule: Host(`gitlab.localhost`)
    traefik.http.routers.gitlab-mcp.service: gitlab-mcp
    traefik.http.routers.gitlab-mcp.entrypoints: web
  environment:
    GITLAB_PERSONAL_ACCESS_TOKEN: "op://Developer/zed-mcp-gitlab/credential"
  depends_on:
    - gitlab
```

### Time

```yaml
time-http:
  image: node:20-alpine
  container_name: time-http
  restart: unless-stopped
  command: >
    sh -c "npm install -g mcp-proxy &&
           mcp-proxy
             --host 0.0.0.0
             --port 8080
             --stateless
             docker exec -i tool-time mcp-server-time"
  ports:
    - "9004:8080"
  volumes:
    - /var/run/docker.sock:/var/run/docker.sock
  labels:
    traefik.enable: true
    traefik.http.services.time.loadbalancer.server.port: 8080
    traefik.http.routers.time.rule: Host(`time.localhost`)
    traefik.http.routers.time.service: time
    traefik.http.routers.time.entrypoints: web
  depends_on:
    - time
```

---

## Path-Based Routing (Alternative)

If you prefer `/mcp/thinking` instead of `thinking.localhost`:

```yaml
thinking-http:
  # ... same as above ...
  labels:
    traefik.enable: true
    traefik.http.services.thinking.loadbalancer.server.port: 8080
    traefik.http.routers.thinking.rule: Host(`mcp.localhost`) && PathPrefix(`/thinking`)
    traefik.http.routers.thinking.service: thinking
    traefik.http.routers.thinking.entrypoints: web
    traefik.http.middlewares.strip-thinking.stripprefix.prefixes: /thinking
    traefik.http.routers.thinking.middlewares: strip-thinking
```

**Access**: `http://mcp.localhost/thinking/mcp`

---

## Advanced Options

### Add API Key Authentication

```yaml
thinking-http:
  command: >
    sh -c "npm install -g mcp-proxy &&
           mcp-proxy
             --host 0.0.0.0
             --port 8080
             --apiKey ${MCP_API_KEY:-secret-key-123}
             --stateless
             docker exec -i thinking node dist/index.js"
  environment:
    MCP_API_KEY: "op://path/to/secret"
```

**Usage**:
```bash
curl -X POST http://thinking.localhost/mcp \
  -H "X-API-Key: secret-key-123" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"tools/list","id":1}'
```

### Enable Debug Logging

```yaml
thinking-http:
  command: >
    sh -c "npm install -g mcp-proxy &&
           mcp-proxy
             --debug
             --host 0.0.0.0
             --port 8080
             docker exec -i thinking node dist/index.js"
```

### Set Request Timeout

```yaml
thinking-http:
  command: >
    sh -c "npm install -g mcp-proxy &&
           mcp-proxy
             --requestTimeout 60000
             --host 0.0.0.0
             --port 8080
             docker exec -i thinking node dist/index.js"
```

### Add Resource Limits

```yaml
thinking-http:
  deploy:
    resources:
      limits:
        cpus: '1.0'
        memory: 512M
      reservations:
        cpus: '0.25'
        memory: 128M
```

---

## Troubleshooting

### "Cannot connect to Docker socket"

**Problem**: Wrapper can't access docker.sock

**Fix**: Ensure volume is mounted:
```yaml
volumes:
  - /var/run/docker.sock:/var/run/docker.sock
```

### "Port already in use"

**Problem**: Another service using the port

**Fix**: Change the host port:
```yaml
ports:
  - "9005:8080"  # Use different port
```

### "404 Not Found"

**Problem**: Traefik can't reach the service

**Fix**: Check service is running:
```bash
docker logs thinking-http
curl http://localhost:9001/health  # Direct access
```

### "Container not found: thinking"

**Problem**: stdio container isn't running

**Fix**: Start the stdio container first:
```bash
docker compose -f global.yaml up -d sequentialthinking
docker compose -f global.yaml up -d thinking-http
```

### High CPU/Memory Usage

**Problem**: npm install runs on every restart

**Fix**: Build a custom image:
```dockerfile
FROM node:20-alpine
RUN npm install -g mcp-proxy
ENTRYPOINT ["mcp-proxy"]
```

```yaml
thinking-http:
  build:
    context: ./wrappers
    dockerfile: Dockerfile.mcp-proxy
  command: >
    --host 0.0.0.0
    --port 8080
    --stateless
    docker exec -i thinking node dist/index.js
```

---

## Verification Checklist

- [ ] Wrapper container is running: `docker ps | grep thinking-http`
- [ ] Health endpoint works: `curl http://thinking.localhost/health`
- [ ] Traefik sees the route: `curl http://localhost:8080/api/http/routers | jq`
- [ ] MCP endpoint responds: `curl -X POST http://thinking.localhost/mcp -d '{"jsonrpc":"2.0","method":"tools/list","id":1}'`
- [ ] mcp-remote can connect: `npx mcp-remote http://thinking.localhost/mcp --allow-http`

---

## When to Use Wrappers

✅ **Use HTTP wrapper when**:
- You need remote access from other machines
- You want Traefik routing
- You need multiple agents to access simultaneously
- Your MCP client only supports HTTP/SSE
- You want centralized logging/monitoring

❌ **Skip wrapper when**:
- Only local access needed
- Low traffic (< 5 requests/hour)
- You prefer direct docker exec
- Resource constraints (wrapper adds ~50MB RAM overhead)

---

## Next Steps

1. **Deploy one wrapper** - Start with sequential thinking
2. **Test thoroughly** - Verify all endpoints work
3. **Monitor resources** - Check CPU/memory usage
4. **Add more wrappers** - Repeat for other stdio servers
5. **Document URLs** - Keep a list of all HTTP endpoints

---

## All HTTP Endpoints (After Wrappers)

| Service | stdio Container | HTTP URL | Access |
|---------|----------------|----------|--------|
| memory | N/A (native HTTP) | http://mcp.localhost/memory/mcp | Direct |
| thinking | thinking | http://thinking.localhost/mcp | Wrapper |
| search | websearch | http://search.localhost/mcp | Wrapper |
| gitlab | gitlab | http://gitlab.localhost/mcp | Wrapper |
| time | tool-time | http://time.localhost/mcp | Wrapper |

---

## Related Documentation

- `MCP_TRANSPORTS.md` - Understanding stdio vs HTTP
- `STDIO_HTTP_WRAPPERS.md` - Complete wrapper guide
- `MULTIPLE_DB_UIS.md` - Traefik routing patterns
- `global.yaml` - Current deployment configuration

---

**Last Updated**: 2025-11-19  
**Status**: Tested and verified with mcp-proxy 5.11.0
