---
id: 4d3c2b1a-9e8f-7d6c-5b4a-3e2f1d0c9b8a
title: Deploying Streamable HTTP MCP Servers with Docker and Traefik
created: 2025-12-12T00:00:00
updated: 2025-12-12T00:00:00
project: dotfiles
scope:
  - docker
  - mcp
type: guide
status: ✅ active
publish: true
tags:
  - docker
  - traefik
  - mcp
  - deployment
  - architecture
aliases:
  - MCP Traefik Guide
  - Streamable HTTP MCP
related:
  - ref: "[[mcp-transports-p1]]"
    description: MCP transport mechanisms overview
  - ref: "[[traefik-proxy-guide]]"
    description: General Traefik proxy configuration
  - ref: "[[healthchecks]]"
    description: Container healthcheck configuration
---

# Deploying Streamable HTTP MCP Servers with Docker and Traefik

This guide covers the complete pattern for deploying MCP servers via Docker with Traefik v3.6+ as the ingress controller, using multi-layer routing with `parentRefs`.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              MCP Client                                      │
│                  (Claude Code, Zed, Cursor, etc.)                           │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ HTTPS + Header: X-Service: <name>
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         Traefik v3.6+ Ingress                               │
│                                                                              │
│  ┌──────────────────┐   ┌──────────────────┐   ┌──────────────────┐        │
│  │  docs@file       │   │  mcp@file        │   │  context7@file   │        │
│  │  (Root Router)   │──▶│  (Intermediate)  │──▶│  (Leaf Router)   │        │
│  │  Host matching   │   │  PathPrefix/mcp  │   │  Header matching │        │
│  │  TLS termination │   │  CORS middleware │   │  Service binding │        │
│  └──────────────────┘   └──────────────────┘   └──────────────────┘        │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ HTTP (internal network)
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                        Docker Network: traefik-public                        │
│                                                                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │  context7   │  │  tool-time  │  │  checklists │  │  duckduckgo │        │
│  │  :8080      │  │  :8080      │  │  :8355      │  │  :3000      │        │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘        │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Prerequisites

- **Traefik v3.6+**: Required for `parentRefs` multi-layer routing
- **Docker Compose**: For container orchestration
- **mkcert**: For local TLS certificates (optional but recommended)
- **File provider**: Traefik dynamic configuration via YAML files

---

## Quick Decision Tree

```
Is your MCP server...
    │
    ├── Already HTTP-native? (e.g., mcp/context7, mayurkakade/mcp-server)
    │   └── Use directly with Traefik routing
    │
    └── stdio-only? (e.g., mcp/time, mcp/filesystem)
        └── Wrap with supergateway in Dockerfile
            └── Then use with Traefik routing
```

---

## Pattern 1: HTTP-Native MCP Servers

For servers that already support HTTP transport (e.g., `mcp/context7`).

### Step 1: Docker Compose Module

Create `modules/mcp/docs/context7.yaml`:

```yaml
services:
  context7:
    image: mcp/context7:latest
    container_name: context7
    profiles: ["core"]
    restart: unless-stopped
    networks:
      - traefik-public              # REQUIRED: Must be on Traefik's network
    ports:
      - "${CONTEXT7_HTTP_PORT:-8210}:8080"
    environment:
      MCP_TRANSPORT: http           # Enable HTTP transport
      PORT: 8080
    healthcheck:
      test: ["CMD", "wget", "--spider", "-q", "http://localhost:8080/mcp"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 10s
    labels:
      # Minimal labels - routing is in file provider
      traefik.enable: true
      traefik.docker.network: traefik-public
```

### Step 2: Traefik File Provider Config

Create `config/traefik/dynamic/svc.mcp.context7.yaml`:

```yaml
http:
  routers:
    # Leaf router for Context7 MCP server
    # Matches: Host(docs.localhost) && PathPrefix(/mcp) && Header(X-Service: context7)
    context7:
      rule: "Header(`X-Service`, `context7`)"
      service: context7
      parentRefs:
        - mcp@file        # Intermediate router (adds PathPrefix/mcp, CORS)
        - docs@file       # Root router (adds Host matching, TLS)

    # Health check endpoint
    context7-health:
      rule: "Header(`X-Service`, `context7`)"
      service: context7
      parentRefs:
        - health@file     # Health intermediate router
        - docs@file       # Root router

  services:
    context7:
      loadBalancer:
        servers:
          - url: "http://context7:8080"    # Container name:port
```

---

## Pattern 2: stdio MCP Servers (with supergateway)

For servers that only support stdio transport.

### Step 1: Create Dockerfile

Create `files/time.dockerfile`:

```dockerfile
FROM node:22-slim

ARG PORT=8080
ARG MCP_PATH=/mcp
ARG SESSION_TIMEOUT=60000

ENV PORT=${PORT}
ENV MCP_PATH=${MCP_PATH}
ENV SESSION_TIMEOUT=${SESSION_TIMEOUT}

# Install runtime for the MCP server (Python example)
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-pip python3-venv \
    && rm -rf /var/lib/apt/lists/*

# Install the MCP server
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --no-cache-dir mcp-server-time

# Install supergateway to wrap stdio with HTTP
RUN npm install -g supergateway

EXPOSE ${PORT}

# Health check - TCP port check (session-aware endpoints don't work)
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD node -e "require('net').connect(${PORT}, 'localhost').on('error', () => process.exit(1)).on('connect', () => process.exit(0))"

# Run supergateway wrapping the stdio server
CMD supergateway \
    --stdio "mcp-server-time" \
    --outputTransport streamableHttp \
    --port ${PORT} \
    --streamableHttpPath ${MCP_PATH} \
    --stateful \
    --sessionTimeout ${SESSION_TIMEOUT}
```

### Step 2: Docker Compose Module

Create `modules/mcp/global/time.yaml`:

```yaml
services:
  time:
    build:
      context: ${XDG_CONFIG_HOME:-$HOME/.config}/docker/files
      dockerfile: time.dockerfile
    image: time-mcp:http
    container_name: tool-time
    profiles: ["core", "global"]
    restart: unless-stopped
    networks:
      - traefik-public
    ports:
      - "${TIME_HTTP_PORT:-8211}:8080"
    environment:
      PORT: 8080
      MCP_PATH: /mcp
      SESSION_TIMEOUT: 60000
    healthcheck:
      test: ["CMD", "node", "-e", "require('net').connect(8080, 'localhost').on('error', () => process.exit(1)).on('connect', () => process.exit(0))"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 15s
    labels:
      traefik.enable: true
      traefik.docker.network: traefik-public
```

### Step 3: Traefik File Provider Config

Create `config/traefik/dynamic/svc.mcp.time.yaml`:

```yaml
http:
  routers:
    time:
      rule: "Header(`X-Service`, `time`)"
      service: time
      parentRefs:
        - mcp@file
        - docs@file

    time-health:
      rule: "Header(`X-Service`, `time`)"
      service: time
      parentRefs:
        - health@file
        - docs@file

  services:
    time:
      loadBalancer:
        servers:
          - url: "http://tool-time:8080"
```

---

## Multi-Layer Routing Architecture (parentRefs)

Traefik v3.6+ supports hierarchical routing with `parentRefs`. This enables:

1. **DRY configuration**: Define Host/TLS once at root, reuse across services
2. **Centralized middleware**: Apply CORS, auth at intermediate layers
3. **Header-based service selection**: Route to different backends by header

### Core Routes Configuration

Create `config/traefik/dynamic/core.routes.yaml`:

```yaml
http:
  routers:
    # =========================================================================
    # ROOT ROUTERS (Layer 1) - Entry points with TLS
    # =========================================================================
    docs:
      rule: "Host(`docs.localhost`) || Host(`doc.localhost`)"
      entryPoints:
        - websecure
      tls: {}
      # No service - this is a routing-only router

    # =========================================================================
    # INTERMEDIATE ROUTERS (Layer 2) - Path-based routing
    # =========================================================================
    mcp:
      rule: "PathPrefix(`/mcp`)"
      middlewares:
        - mcp-cors@file
      parentRefs:
        - docs@file
      # No service - routes to leaf routers

    health:
      rule: "PathPrefix(`/health`)"
      middlewares:
        - mcp@file       # Inherit CORS from mcp
      parentRefs:
        - docs@file

    api:
      rule: "PathPrefix(`/api`)"
      parentRefs:
        - docs@file

    ui:
      rule: "PathPrefix(`/ui`)"
      middlewares:
        - strip-prefix@file
      parentRefs:
        - docs@file

  middlewares:
    mcp-cors:
      headers:
        accessControlAllowMethods:
          - GET
          - POST
          - OPTIONS
        accessControlAllowHeaders:
          - Content-Type
          - X-Service
          - Mcp-Session-Id
        accessControlAllowOriginList:
          - "*"
        accessControlMaxAge: 86400

    strip-prefix:
      stripPrefix:
        prefixes:
          - /ui
```

### Routing Hierarchy Visualization

```
docs@file (ROOT)
├── Host(`docs.localhost`) || Host(`doc.localhost`)
├── entryPoints: [websecure]
├── tls: {}
│
├── mcp@file (INTERMEDIATE)
│   ├── PathPrefix(`/mcp`)
│   ├── middlewares: [mcp-cors@file]
│   │
│   ├── context7@file (LEAF) → Header(`X-Service`, `context7`) → context7:8080
│   ├── time@file (LEAF) → Header(`X-Service`, `time`) → tool-time:8080
│   └── duckduckgo@file (LEAF) → Header(`X-Service`, `duckduckgo`) → duckduckgo:3000
│
├── health@file (INTERMEDIATE)
│   ├── PathPrefix(`/health`)
│   │
│   ├── context7-health@file (LEAF) → context7:8080
│   └── time-health@file (LEAF) → tool-time:8080
│
├── api@file (INTERMEDIATE)
│   ├── PathPrefix(`/api`)
│   │
│   └── checklist-api@file (LEAF) → Header(`X-Service`, `checklist`) → checklists:8355
│
└── ui@file (INTERMEDIATE)
    ├── PathPrefix(`/ui`)
    ├── middlewares: [strip-prefix@file]
    │
    └── checklist-ui@file (LEAF) → Header(`X-Service`, `checklist`) → checklists:80
```

---

## TLS Configuration for MCP Clients

### Problem

Node.js-based MCP clients (like `mcp-remote`, `npx`) use bundled CA certificates, not the system keychain. This causes TLS errors with mkcert certificates:

```
UNABLE_TO_VERIFY_LEAF_SIGNATURE
```

### Solution

Set `NODE_EXTRA_CA_CERTS` to the mkcert root CA:

```bash
# Find mkcert CA location
mkcert -CAROOT
# /Users/username/.local/share/mkcert

# Set environment variable
export NODE_EXTRA_CA_CERTS=/Users/username/.local/share/mkcert/rootCA.pem

# Test connection
npx mcp-remote https://docs.localhost/mcp --header "X-Service: context7"
```

### Certificate Generation

Generate certificates with explicit subdomain SANs (Node.js doesn't match wildcards properly):

```bash
mkcert -cert-file cert.pem -key-file key.pem \
    "*.localhost" "localhost" \
    "docs.localhost" "doc.localhost" \
    "traefik.localhost" "db.localhost" \
    127.0.0.1 ::1
```

---

## Testing

### Direct Container Access

```bash
# Test container directly (bypasses Traefik)
curl -s http://localhost:8210/mcp -X POST \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"initialize","params":{"capabilities":{}},"id":1}'
```

### Via Traefik

```bash
# Test via Traefik with header routing
curl -k -s https://docs.localhost/mcp -X POST \
  -H "Content-Type: application/json" \
  -H "X-Service: context7" \
  -d '{"jsonrpc":"2.0","method":"initialize","params":{"capabilities":{}},"id":1}'
```

### With mcp-remote

```bash
# Full integration test
NODE_EXTRA_CA_CERTS=~/.local/share/mkcert/rootCA.pem \
  npx mcp-remote https://docs.localhost/mcp --header "X-Service: time"

# Expected output:
# Connected to remote server using StreamableHTTPClientTransport
# Proxy established successfully
```

---

## MCP Client Configuration

### Zed Editor

```json
{
  "context_servers": {
    "context7": {
      "url": "https://docs.localhost/mcp",
      "headers": {
        "X-Service": "context7"
      }
    },
    "time": {
      "url": "https://docs.localhost/mcp",
      "headers": {
        "X-Service": "time"
      }
    }
  }
}
```

### Claude Code

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": [
        "mcp-remote",
        "https://docs.localhost/mcp",
        "--header", "X-Service: context7"
      ],
      "env": {
        "NODE_EXTRA_CA_CERTS": "/Users/username/.local/share/mkcert/rootCA.pem"
      }
    }
  }
}
```

---

## Deployment Workflow

1. **Create Dockerfile** (if stdio server) - `files/<name>.dockerfile`
2. **Create Docker Compose module** - `modules/mcp/<category>/<name>.yaml`
3. **Create Traefik file provider** - `config/traefik/dynamic/svc.mcp.<name>.yaml`
4. **Install dotfiles** - `just -f docker/justfile install`
5. **Build image** (if custom) - `docker compose --profile core build <name>`
6. **Deploy** - `just -g deploy-docker core`
7. **Test** - `npx mcp-remote https://docs.localhost/mcp --header "X-Service: <name>"`

---

## Troubleshooting

### 502 Bad Gateway

1. **Container not on network**: Check `docker network inspect traefik-public`
2. **Wrong service URL**: Verify container name matches service URL
3. **Container unhealthy**: Check `docker ps` and `docker logs <container>`

### 404 Not Found

1. **parentRefs error**: Requires Traefik v3.6+ - check `docker exec ingress traefik version`
2. **Missing file provider**: Check Traefik config includes dynamic config directory
3. **Router not matching**: Check rule syntax in file provider

### TLS Errors

1. **UNABLE_TO_VERIFY_LEAF_SIGNATURE**: Set `NODE_EXTRA_CA_CERTS`
2. **subjectAltName mismatch**: Regenerate cert with explicit subdomain SANs
3. **ERR_SSL_PACKET_LENGTH_TOO_LONG**: Accessing HTTP port with HTTPS

---

## File Structure Reference

```
docker/
├── config/traefik/dynamic/
│   ├── core.routes.yaml          # Root and intermediate routers
│   ├── middlewares.yaml          # Shared middlewares
│   ├── svc.mcp.context7.yaml     # Context7 leaf router
│   ├── svc.mcp.time.yaml         # Time leaf router
│   └── svc.mcp.checklist.yaml    # Checklist leaf router
├── files/
│   ├── time.dockerfile           # Custom wrapper for stdio servers
│   └── duckduckgo.dockerfile
├── modules/
│   ├── mcp/
│   │   ├── docs/
│   │   │   └── context7.yaml     # HTTP-native server
│   │   ├── global/
│   │   │   └── time.yaml         # Wrapped stdio server
│   │   └── workflow/
│   │       └── checklist.yaml
│   └── ingress/
│       └── traefik.yaml          # Traefik v3.6 config
└── docker-compose.yaml           # Main compose with includes
```

---

## References

- [MCP Streamable HTTP Transport Spec](https://modelcontextprotocol.io/specification/2025-03-26/basic/transports)
- [Traefik Multi-Layer Routing](https://doc.traefik.io/traefik/reference/routing-configuration/http/routing/multi-layer-routing/)
- [Supergateway](https://github.com/supercorp-ai/supergateway)
- [mkcert](https://github.com/FiloSottile/mkcert)

---

> [!info] Metadata
> **Scope**: `= this.scope`
> **Type**: `= this.type`
> **Status**: `= this.status`
