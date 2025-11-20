# id: 8f7e6d5c-4a3b-2e1f-9d8c-7b6a5f4e3d2c

# Traefik Proxy Configuration Guide

Complete guide for using Traefik as a reverse proxy for MCP services in the global deployment.

## Overview

Traefik is configured as the ingress controller for all MCP services, providing:

- **Path-based routing**: Route requests based on URL paths
- **Host-based routing**: Route requests based on hostnames
- **Automatic service discovery**: Detects Docker containers with proper labels
- **Middleware support**: Strip prefixes, add headers, redirect, etc.

## Current Setup

### Traefik Service Configuration

```yaml
traefik:
  image: traefik:latest
  container_name: ingress
  command:
    - "--api.insecure=true" # Enable dashboard (dev only!)
    - "--providers.docker=true" # Auto-discover Docker services
    - "--entrypoints.web.address=:80" # HTTP entry point
  ports:
    - "80:80" # HTTP traffic
    - "8080:8080" # Traefik dashboard
  volumes:
    - /var/run/docker.sock:/var/run/docker.sock # Docker API access
```

### Access Points

| Service           | URL                         | Backend             |
| ----------------- | --------------------------- | ------------------- |
| Traefik Dashboard | http://localhost:8080       | Traefik API         |
| FalkorDB UI       | http://db.localhost/        | graphdb:3000        |
| FalkorDB Login    | http://db.localhost/login   | graphdb:3000/login  |
| Memory Service    | http://localhost:8000/mcp/  | memory:8000/mcp/    |
| GitHub MCP        | http://localhost/github     | github container    |
| GitLab MCP        | http://localhost/gitlab     | gitlab container    |
| DuckDuckGo Search | http://localhost/search/ddg | websearch container |

---

## FalkorDB UI Proxy Configuration

### Goal

Access FalkorDB Browser UI at `http://db.localhost/` instead of `http://localhost:3000`

**Note**: Originally attempted path-based routing (`/ui/falkor`) but switched to subdomain routing due to Next.js asset loading issues. See [Troubleshooting](#common-issues--solutions) for details.

### Implementation

```yaml
falkordb:
  image: falkordb/falkordb:latest
  container_name: graphdb
  ports:
    - "6379:6379" # Redis/FalkorDB port
    - "3000:3000" # FalkorDB web UI
  labels:
    traefik.enable: true

    # Define the service (backend)
    traefik.http.services.falkorui.loadbalancer.server.port: 3000

    # Define the router (frontend) - subdomain routing
    traefik.http.routers.falkorui.rule: Host(`db.localhost`)
    traefik.http.routers.falkorui.service: falkorui
    traefik.http.routers.falkorui.entrypoints: web
```

### How It Works

1. **Request**: Browser → `http://db.localhost/login`
2. **Router Match**: Traefik matches `Host(db.localhost)`
3. **Proxy**: Traefik → `http://graphdb:3000/login` (direct, no path manipulation)
4. **Response**: FalkorDB UI → Traefik → Browser
5. **Assets**: Browser loads `http://db.localhost/_next/static/...` → Traefik → `graphdb:3000/_next/static/...`

### Path Mapping

| Browser URL                               | Traefik Receives       | Proxies To     | Backend Receives       |
| ----------------------------------------- | ---------------------- | -------------- | ---------------------- |
| `http://db.localhost/`                    | `/`                    | `graphdb:3000` | `/`                    |
| `http://db.localhost/login`               | `/login`               | `graphdb:3000` | `/login`               |
| `http://db.localhost/_next/static/app.js` | `/_next/static/app.js` | `graphdb:3000` | `/_next/static/app.js` |

---

## Traefik Labels Reference

### Basic Labels

```yaml
labels:
  # Enable Traefik for this container
  traefik.enable: true

  # Define which port Traefik should proxy to
  traefik.http.services.<service-name>.loadbalancer.server.port: 8000

  # Define routing rule
  traefik.http.routers.<router-name>.rule: PathPrefix(`/myapp`)

  # Link router to service
  traefik.http.routers.<router-name>.service: <service-name>

  # Specify entrypoint (usually 'web' for HTTP)
  traefik.http.routers.<router-name>.entrypoints: web
```

### Router Rules

**Path-based routing**:

```yaml
traefik.http.routers.myapp.rule: PathPrefix(`/app`)
```

**Host-based routing**:

```yaml
traefik.http.routers.myapp.rule: Host(`app.localhost`)
```

**Combined (AND)**:

```yaml
traefik.http.routers.myapp.rule: Host(`app.localhost`) && PathPrefix(`/api`)
```

**Multiple paths (OR)**:

```yaml
traefik.http.routers.myapp.rule: PathPrefix(`/app`) || PathPrefix(`/application`)
```

### Middleware Examples

**Strip Path Prefix**:

```yaml
traefik.http.middlewares.myapp-strip.stripprefix.prefixes: /app
traefik.http.routers.myapp.middlewares: myapp-strip
```

**Add Prefix**:

```yaml
traefik.http.middlewares.myapp-prefix.addprefix.prefix: /v1
traefik.http.routers.myapp.middlewares: myapp-prefix
```

**Redirect**:

```yaml
traefik.http.middlewares.myapp-redirect.redirectregex.regex: ^http://(.*)
traefik.http.middlewares.myapp-redirect.redirectregex.replacement: https://$$1
traefik.http.routers.myapp.middlewares: myapp-redirect
```

**Headers**:

```yaml
traefik.http.middlewares.myapp-headers.headers.customrequestheaders.X-Custom-Header: value
traefik.http.routers.myapp.middlewares: myapp-headers
```

**Multiple Middlewares** (chain them):

```yaml
traefik.http.routers.myapp.middlewares: myapp-strip,myapp-headers,myapp-cors
```

---

## Common Routing Patterns

### Pattern 1: Simple Path Prefix

**Goal**: Route `/api/*` to a backend service

```yaml
labels:
  traefik.enable: true
  traefik.http.services.api.loadbalancer.server.port: 8080
  traefik.http.routers.api.rule: PathPrefix(`/api`)
  traefik.http.routers.api.service: api
```

**Result**:

- `http://localhost/api/users` → `http://backend:8080/api/users`
- `http://localhost/api/health` → `http://backend:8080/api/health`

---

### Pattern 2: Path Prefix with Strip

**Goal**: Route `/app/*` to backend serving at root `/`

```yaml
labels:
  traefik.enable: true
  traefik.http.services.myapp.loadbalancer.server.port: 3000
  traefik.http.routers.myapp.rule: PathPrefix(`/app`)
  traefik.http.routers.myapp.service: myapp
  traefik.http.middlewares.myapp-strip.stripprefix.prefixes: /app
  traefik.http.routers.myapp.middlewares: myapp-strip
```

**Result**:

- `http://localhost/app` → `http://backend:3000/`
- `http://localhost/app/login` → `http://backend:3000/login`
- `http://localhost/app/api/data` → `http://backend:3000/api/data`

---

### Pattern 3: Subdomain Routing

**Goal**: Route `api.localhost` to API service

```yaml
labels:
  traefik.enable: true
  traefik.http.services.api.loadbalancer.server.port: 8080
  traefik.http.routers.api.rule: Host(`api.localhost`)
  traefik.http.routers.api.service: api
```

**Result**:

- `http://api.localhost/users` → `http://backend:8080/users`
- `http://api.localhost/health` → `http://backend:8080/health`

---

### Pattern 4: Combined Host + Path

**Goal**: Route `db.localhost/ui/*` to database UI

```yaml
labels:
  traefik.enable: true
  traefik.http.services.dbui.loadbalancer.server.port: 3000
  traefik.http.routers.dbui.rule: Host(`db.localhost`) && PathPrefix(`/ui`)
  traefik.http.routers.dbui.service: dbui
  traefik.http.middlewares.dbui-strip.stripprefix.prefixes: /ui
  traefik.http.routers.dbui.middlewares: dbui-strip
```

**Result**:

- `http://db.localhost/ui` → `http://backend:3000/`
- `http://db.localhost/ui/login` → `http://backend:3000/login`

---

## Debugging Traefik Routes

### 1. Check Traefik Dashboard

Visit: http://localhost:8080

- **HTTP → Routers**: See all configured routes
- **HTTP → Services**: See all backend services
- **HTTP → Middlewares**: See all middleware configurations

### 2. Inspect Router Configuration

```bash
# List all routers
curl -s http://localhost:8080/api/http/routers | jq '.'

# Check specific router
curl -s http://localhost:8080/api/http/routers | jq '.[] | select(.name | contains("falkor"))'
```

### 3. Inspect Service Configuration

```bash
# List all services
curl -s http://localhost:8080/api/http/services | jq '.'

# Check specific service
curl -s http://localhost:8080/api/http/services | jq '.[] | select(.name | contains("falkorui"))'
```

### 4. Test Routes

```bash
# Test with curl (follow redirects)
curl -L -I http://db.localhost/ui/falkor

# Test without following redirects
curl -I http://db.localhost/ui/falkor

# Test with verbose output
curl -v http://db.localhost/ui/falkor
```

### 5. Check Container Labels

```bash
# See all labels on a container
docker inspect graphdb | jq '.[0].Config.Labels'

# See only Traefik labels
docker inspect graphdb | jq '.[0].Config.Labels | to_entries | .[] | select(.key | startswith("traefik"))'
```

---

## Common Issues & Solutions

### Issue 1: 404 Not Found

**Symptoms**: `http://db.localhost/ui/falkor` returns 404

**Possible Causes**:

1. Traefik labels not set on container
2. `traefik.enable: true` missing
3. Wrong port in `loadbalancer.server.port`
4. Container not on same Docker network as Traefik

**Solution**:

```bash
# Check if Traefik sees the service
curl -s http://localhost:8080/api/http/routers | jq '.[] | select(.name | contains("falkorui"))'

# Verify container labels
docker inspect graphdb | jq '.[0].Config.Labels'

# Check networks
docker inspect graphdb | jq '.[0].NetworkSettings.Networks'
docker inspect ingress | jq '.[0].NetworkSettings.Networks'
```

---

### Issue 2: Gateway Timeout / Connection Refused

**Symptoms**: Request hangs or times out

**Possible Causes**:

1. Backend service not running
2. Wrong port number
3. Backend not listening on 0.0.0.0 (listening on 127.0.0.1 only)

**Solution**:

```bash
# Check if backend is running
docker ps | grep graphdb

# Check backend port
docker port graphdb

# Test backend directly
curl http://localhost:3000/

# Check backend logs
docker logs graphdb --tail 50
```

---

### Issue 3: Next.js/React App Shows Broken UI (Missing Styles/Scripts)

**Symptoms**:

- HTML loads but page appears unstyled or broken
- Browser console shows 404 errors for `/_next/static/...` or `/static/...` assets
- Network tab shows failed asset requests

**Cause**:
Path-based routing with apps that use absolute asset paths. Next.js apps generate paths like `/_next/static/...` which don't work under path prefixes like `/ui/falkor`.

Example:

```
Browser loads:  http://db.localhost/ui/falkor/
App HTML has:   <script src="/_next/static/chunks/app.js">
Browser tries:  http://db.localhost/_next/static/chunks/app.js  ❌ 404!
Should be:      http://db.localhost/ui/falkor/_next/static/chunks/app.js
```

**Solution 1 - Use Subdomain Routing** (Recommended):

```yaml
labels:
  traefik.http.routers.myapp.rule: Host(`app.localhost`) # Not PathPrefix!
  # No stripprefix middleware needed
```

**Solution 2 - Configure App Base Path** (If you control the app):

```javascript
// next.config.js
module.exports = {
  basePath: "/ui/falkor",
  assetPrefix: "/ui/falkor",
};
```

**Solution 3 - Add Asset Proxy Rules** (Complex, not recommended):

```yaml
# Proxy both the app AND its assets
traefik.http.routers.myapp-main.rule: Host(`localhost`) && PathPrefix(`/ui/falkor`)
traefik.http.routers.myapp-assets.rule: Host(`localhost`) && PathPrefix(`/_next/static`)
# Complex middleware chain needed
```

**Diagnosis**:

```bash
# Check if assets are loading
curl -I http://db.localhost/_next/static/chunks/webpack-*.js

# View HTML source to see asset paths
curl -s http://db.localhost/ui/falkor/ | grep -o 'src="[^"]*"'

# Check browser Network tab for 404s
```

**Best Practice**: For third-party apps (FalkorDB, Grafana, etc.) that you can't modify, always use subdomain routing instead of path prefixes.

---

### Issue 4: Redirect Loop

**Symptoms**: Browser shows "Too many redirects"

**Possible Causes**:

1. Backend redirects to a path that triggers the same route
2. Middleware redirect creates infinite loop

**Solution**:

```bash
# Trace redirects
curl -L -v http://db.localhost/ui/falkor 2>&1 | grep -E "(Location:|HTTP/)"

# Check for redirect middleware
curl -s http://localhost:8080/api/http/middlewares | jq '.[] | select(.name | contains("redirect"))'
```

---

## Testing Your Configuration

### Manual Testing Checklist

```bash
# 1. Verify Traefik is running
docker ps | grep ingress

# 2. Check Traefik dashboard
curl -I http://localhost:8080

# 3. Verify backend is running
docker ps | grep graphdb

# 4. Test backend directly
curl -I http://localhost:3000/

# 5. Test Traefik proxy
curl -I http://db.localhost/ui/falkor

# 6. Verify path stripping works
curl -I http://db.localhost/ui/falkor/login

# 7. Check response headers
curl -I http://db.localhost/ui/falkor | grep -i "x-powered-by"
```

### Automated Testing Script

```bash
#!/bin/bash

echo "Testing Traefik Proxy Configuration..."
echo ""

# Test 1: Traefik Dashboard
echo "1. Traefik Dashboard:"
curl -s -o /dev/null -w "   Status: %{http_code}\n" http://localhost:8080

# Test 2: FalkorDB Direct
echo "2. FalkorDB Direct (localhost:3000):"
curl -s -o /dev/null -w "   Status: %{http_code}\n" http://localhost:3000/

# Test 3: FalkorDB via Proxy (root)
echo "3. FalkorDB via Proxy (db.localhost/ui/falkor):"
curl -s -o /dev/null -w "   Status: %{http_code}\n" http://db.localhost/ui/falkor

# Test 4: FalkorDB Login via Proxy
echo "4. FalkorDB Login via Proxy (db.localhost/ui/falkor/login):"
curl -s -o /dev/null -w "   Status: %{http_code}\n" http://db.localhost/ui/falkor/login

echo ""
echo "All tests complete!"
```

---

## Advanced Configuration

### Multiple Services, One Container

If a container exposes multiple services on different ports:

```yaml
labels:
  traefik.enable: true

  # Service 1: API on port 8080
  traefik.http.services.myapp-api.loadbalancer.server.port: 8080
  traefik.http.routers.myapp-api.rule: PathPrefix(`/api`)
  traefik.http.routers.myapp-api.service: myapp-api

  # Service 2: UI on port 3000
  traefik.http.services.myapp-ui.loadbalancer.server.port: 3000
  traefik.http.routers.myapp-ui.rule: PathPrefix(`/ui`)
  traefik.http.routers.myapp-ui.service: myapp-ui
```

---

### CORS Middleware

```yaml
labels:
  traefik.http.middlewares.myapp-cors.headers.accesscontrolallowmethods: GET,POST,PUT,DELETE,OPTIONS
  traefik.http.middlewares.myapp-cors.headers.accesscontrolalloworigin: "*"
  traefik.http.middlewares.myapp-cors.headers.accesscontrolmaxage: 100
  traefik.http.middlewares.myapp-cors.headers.addvaryheader: true
  traefik.http.routers.myapp.middlewares: myapp-cors
```

---

### Rate Limiting

```yaml
labels:
  traefik.http.middlewares.myapp-ratelimit.ratelimit.average: 100
  traefik.http.middlewares.myapp-ratelimit.ratelimit.burst: 200
  traefik.http.routers.myapp.middlewares: myapp-ratelimit
```

---

### IP Whitelist

```yaml
labels:
  traefik.http.middlewares.myapp-ipwhitelist.ipwhitelist.sourcerange: 127.0.0.1/32,192.168.1.0/24
  traefik.http.routers.myapp.middlewares: myapp-ipwhitelist
```

---

## Security Considerations

### Production Deployment

For production, modify the Traefik configuration:

```yaml
traefik:
  image: traefik:latest
  container_name: ingress
  command:
    - "--api.insecure=false" # Disable insecure API
    - "--api.dashboard=false" # Disable dashboard
    - "--providers.docker=true"
    - "--providers.docker.exposedbydefault=false" # Require explicit enable
    - "--entrypoints.web.address=:80"
    - "--entrypoints.websecure.address=:443"
    - "--certificatesresolvers.letsencrypt.acme.email=your-email@example.com"
    - "--certificatesresolvers.letsencrypt.acme.storage=/letsencrypt/acme.json"
    - "--certificatesresolvers.letsencrypt.acme.httpchallenge.entrypoint=web"
  ports:
    - "80:80"
    - "443:443"
  volumes:
    - /var/run/docker.sock:/var/run/docker.sock
    - ./letsencrypt:/letsencrypt
```

Then update service labels:

```yaml
labels:
  traefik.enable: true
  traefik.http.routers.myapp.rule: Host(`myapp.example.com`)
  traefik.http.routers.myapp.entrypoints: websecure
  traefik.http.routers.myapp.tls.certresolver: letsencrypt
```

---

## Summary: FalkorDB UI Proxy

**What You Have**:

```
http://db.localhost/       → FalkorDB UI root page
http://db.localhost/login  → FalkorDB login page
```

**How It Works**:

1. Traefik matches `Host(db.localhost)`
2. Proxies directly to `graphdb:3000` (no path manipulation)
3. Assets load correctly at `http://db.localhost/_next/static/...`

**Configuration**:

```yaml
falkordb:
  labels:
    traefik.enable: true
    traefik.http.services.falkorui.loadbalancer.server.port: 3000
    traefik.http.routers.falkorui.rule: Host(`db.localhost`)
    traefik.http.routers.falkorui.service: falkorui
    traefik.http.routers.falkorui.entrypoints: web
```

**Why Subdomain Instead of Path?**:
Originally attempted `Host(db.localhost) && PathPrefix(/ui/falkor)` but FalkorDB is a Next.js app that generates absolute asset paths like `/_next/static/...`. With path prefix routing, these assets would fail to load (404 errors). Subdomain routing solves this by making the app think it's at the root `/`, so all asset paths work correctly.

**Status**: ✅ Working correctly!

---

**Last Updated**: 2025-11-19  
**Related Docs**:

- Traefik Documentation: https://doc.traefik.io/traefik/
- Docker Provider: https://doc.traefik.io/traefik/providers/docker/
- Middlewares: https://doc.traefik.io/traefik/middlewares/overview/
