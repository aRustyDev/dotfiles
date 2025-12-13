---
id: a1b2c3d4-e5f6-7890-abcd-ef1234567890
title: "ADR: Container-Use + MCP Integration Patterns"
created: 2025-12-13T00:00:00
updated: 2025-12-13T00:00:00
project: dotfiles
scope:
  - docker
  - mcp
type: adr
status: 📝 draft
publish: false
tags:
  - adr
  - architecture
  - container
  - mcp
  - docker
aliases:
  - Container MCP Integration
  - Container-Use ADR
related:
  - ref: "[[mcp-transports]]"
    description: MCP transport mechanisms
  - ref: "[[mcp-http-legacy-vs-modern]]"
    description: HTTP transport protocols
adr:
  number: "001"
  supersedes: null
  superseded_by: null
  deciders:
    - arustydev
---

# ADR: Container-Use + MCP Integration Patterns

Architectural patterns for integrating MCP servers with containerized environments.

## Status

Proposed

## Context

Containerized development environments (container-use) need access to MCP servers. The key insight is that **Streamable HTTP is the key enabler** because:

- stdio transport cannot cross container boundaries
- HTTP works across networks
- Multiple clients can connect to one server
- Supports authentication, routing via reverse proxies

---

## Current Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           TRAEFIK REVERSE PROXY                         │
│                     https://tool.localhost/mcp/*                        │
└─────────────────────────────────┬───────────────────────────────────────┘
                                  │ HTTP routing (X-Service header)
          ┌───────────────────────┼───────────────────┐
          ▼                       ▼                   ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│  github-mcp:http│ │  gitlab-mcp:http│ │ context7-mcp    │
│  (supergateway) │ │  (supergateway) │ │ (native HTTP)   │
└─────────────────┘ └─────────────────┘ └─────────────────┘
```

**Key Insight**: Using `supergateway` to wrap stdio MCP servers with Streamable HTTP transport.

---

## Decision

### Pattern 1: Container Accesses Host MCP Services via Traefik

The simplest solution - containers call existing HTTP MCP endpoints:

```python
environment_config(config={
  "setup_commands": ["pip install fastmcp httpx"],
  "envs": [
    "MCP_ENDPOINT=http://host.docker.internal:80/mcp",
    # Or if on same Docker network:
    "MCP_ENDPOINT=http://traefik/mcp"
  ]
})
```

**Pros:**
- Uses existing infrastructure
- All MCP servers immediately available
- Centralized routing/auth via Traefik

**Cons:**
- Path translation needed (container paths ≠ host paths)
- Network latency (minimal)

---

### Pattern 2: MCP Sidecar Containers

Run MCP servers as sidecars alongside the container-use environment:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                      POD / COMPOSE SERVICE GROUP                        │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                    CONTAINER ENVIRONMENT                         │   │
│  │  curl http://localhost:8080/mcp  # Smart Tree                   │   │
│  │  curl http://localhost:8081/mcp  # Filesystem                   │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│              localhost (shared network namespace)                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                  │
│  │ smart-tree   │  │ filesystem   │  │ git          │                  │
│  │ :8080/mcp    │  │ :8081/mcp    │  │ :8082/mcp    │                  │
│  │ Volume:      │  │ Volume:      │  │ Volume:      │                  │
│  │ /workspace   │  │ /workspace   │  │ /workspace   │                  │
│  └──────────────┘  └──────────────┘  └──────────────┘                  │
│                    SHARED VOLUME /workspace                             │
└─────────────────────────────────────────────────────────────────────────┘
```

**Pros:**
- **Solves the path problem!** All containers see `/workspace`
- MCP servers have same filesystem view as your container
- localhost access (fast, no network hops)

**Cons:**
- Requires container-use to support sidecar pattern
- More resource usage
- Need to coordinate startup order

---

### Pattern 3: MCP Gateway with Path Translation

A smart proxy that translates paths between container and host:

```python
PATH_MAPPINGS = {
    "/workspace": "/Users/adamsm/code/myproject",
    "/home/user": "/Users/adamsm",
}

def translate_path(container_path: str, to_host: bool = True) -> str:
    if to_host:
        for container, host in PATH_MAPPINGS.items():
            if container_path.startswith(container):
                return container_path.replace(container, host, 1)
    return container_path
```

**Pros:**
- Transparent path translation
- Works with existing MCP servers
- Centralized mapping configuration

**Cons:**
- Additional service to maintain
- Response path translation can be complex

---

### Pattern 4: Native HTTP MCP in Container (Recommended)

Containers have MCP clients that speak HTTP to external services:

```python
from fastmcp.client import Client
from fastmcp.client.transports import StreamableHttpTransport

transport = StreamableHttpTransport(
    url="http://host.docker.internal:8080/mcp"
)
client = Client(transport)

result = await client.call_tool(
    "analyze_directory",
    {"path": "/Users/adamsm/code/myproject"}
)
```

---

## Consequences

### Positive

- Streamable HTTP enables cross-container communication
- Traefik provides centralized routing and auth
- Multiple architectural patterns available for different use cases

### Negative

- Path translation remains a challenge for filesystem-dependent MCP servers
- Requires understanding of Docker networking

### Neutral

- supergateway bridge pattern already solves 90% of the problem

---

## Implementation Matrix

| Server | Needs Volume Mount | Needs supergateway | Path Translation | Difficulty |
|--------|-------------------|-------------------|------------------|------------|
| Smart-Tree | Yes (filesystem) | Maybe (has MCP mode) | Required | Medium |
| Char-Index | No (stateless) | Yes | None | **Easy** |
| Filesystem | Yes (filesystem) | Yes | Required | Medium |
| Git | Yes (.git dirs) | Yes | Required | Medium |

---

## References

- [MCP Transports Documentation](https://modelcontextprotocol.io/specification/2025-03-26/basic/transports)
- [supergateway](https://github.com/anthropics/supergateway)
- [container-use](https://github.com/anthropics/container-use)

---

> [!info] Metadata
> **ADR**: `= this.adr.number`
> **Status**: `= this.status`
> **Deciders**: `= this.adr.deciders`
