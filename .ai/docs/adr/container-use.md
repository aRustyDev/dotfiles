Architectural Patterns for Container-Use + MCP Integration

You're already ahead of the curve! Your infrastructure uses **supergateway** to bridge stdio→HTTP. Let's explore how to extend this for container-use.

---

### Current Architecture (Your Setup)

```/dev/null/current-architecture.md#L1-30
┌─────────────────────────────────────────────────────────────────────────┐
│                           TRAEFIK REVERSE PROXY                         │
│                     https://tool.localhost/mcp/*                        │
└─────────────────────────────┬───────────────────────────────────────────┘
                              │ HTTP routing (X-Service header)
          ┌───────────────────┼───────────────────┐
          ▼                   ▼                   ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│  github-mcp:http│ │  gitlab-mcp:http│ │ context7-mcp    │
│  (supergateway) │ │  (supergateway) │ │ (native HTTP)   │
│                 │ │                 │ │                 │
│ ┌─────────────┐ │ │ ┌─────────────┐ │ │                 │
│ │github-mcp   │ │ │ │gitlab-mcp   │ │ │ HTTP endpoint   │
│ │(stdio)      │ │ │ │(stdio)      │ │ │ :8080/mcp       │
│ └─────────────┘ │ │ └─────────────┘ │ │                 │
└─────────────────┘ └─────────────────┘ └─────────────────┘
```

**Key Insight**: You're using `supergateway` to wrap stdio MCP servers with Streamable HTTP transport!

---

### Pattern 1: Container Accesses Host MCP Services via Traefik

The simplest solution - containers call your existing HTTP MCP endpoints:

```/dev/null/pattern1-traefik.md#L1-35
┌─────────────────────────────────────────────────────────────────────────┐
│                        CONTAINER ENVIRONMENT                            │
│  ┌───────────────────────────────────────────────────────────────────┐  │
│  │  environment_run_cmd("curl https://tool.localhost/mcp/...")       │  │
│  │                                                                    │  │
│  │  # Or use MCP client library:                                     │  │
│  │  from fastmcp.client import Client                                │  │
│  │  client = Client("https://tool.localhost/mcp",                    │  │
│  │                  headers={"X-Service": "github"})                 │  │
│  │  result = await client.call_tool("list_repos", {...})             │  │
│  └───────────────────────────────────────────────────────────────────┘  │
│                              │                                          │
│                              │ HTTP (via Docker network)                │
│                              ▼                                          │
│  ┌───────────────────────────────────────────────────────────────────┐  │
│  │                    TRAEFIK (on host)                               │  │
│  │              https://tool.localhost/mcp/*                          │  │
│  └───────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────┘

Network Configuration:
- Container joins traefik-public network
- Or uses host.docker.internal for host access
- Traefik routes based on X-Service header
```

**Implementation:**

```/dev/null/pattern1-implementation.yaml#L1-25
# In environment_config or container setup:
environment_config(config={
  "setup_commands": [
    # Install MCP client
    "pip install fastmcp httpx",
    # Or for simple HTTP calls
    "apt-get install -y curl jq"
  ],
  "envs": [
    # Point to Traefik endpoint
    "MCP_ENDPOINT=http://host.docker.internal:80/mcp",
    # Or if on same Docker network
    "MCP_ENDPOINT=http://traefik/mcp"
  ]
})

# Usage inside container:
environment_run_cmd("""
curl -X POST http://host.docker.internal/mcp \
  -H "X-Service: github" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list","params":{}}'
""")
```

**Pros:**

- ✅ Uses your existing infrastructure
- ✅ All MCP servers immediately available
- ✅ Centralized routing/auth via Traefik

**Cons:**

- ❌ Path translation still needed (container paths ≠ host paths)
- ❌ Network latency (minimal but present)

---

### Pattern 2: MCP Sidecar Containers

Run MCP servers as sidecars alongside the container-use environment:

```/dev/null/pattern2-sidecar.md#L1-40
┌─────────────────────────────────────────────────────────────────────────┐
│                      POD / COMPOSE SERVICE GROUP                        │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                    CONTAINER ENVIRONMENT                         │   │
│  │                    (environment_run_cmd)                         │   │
│  │                                                                  │   │
│  │  curl http://localhost:8080/mcp  # Smart Tree                   │   │
│  │  curl http://localhost:8081/mcp  # Filesystem                   │   │
│  │  curl http://localhost:8082/mcp  # Git                          │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                              │                                          │
│              localhost (shared network namespace)                       │
│                              │                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                  │
│  │ smart-tree   │  │ filesystem   │  │ git          │                  │
│  │ :8080/mcp    │  │ :8081/mcp    │  │ :8082/mcp    │                  │
│  │              │  │              │  │              │                  │
│  │ Volume:      │  │ Volume:      │  │ Volume:      │                  │
│  │ /workspace   │  │ /workspace   │  │ /workspace   │                  │
│  └──────────────┘  └──────────────┘  └──────────────┘                  │
│         │                 │                 │                           │
│         └─────────────────┴─────────────────┘                           │
│                           │                                             │
│                    SHARED VOLUME                                        │
│                    /workspace (all containers see same files)           │
└─────────────────────────────────────────────────────────────────────────┘
```

**Implementation:**

```/dev/null/pattern2-implementation.yaml#L1-50
# Enhanced environment_add_service for MCP sidecars
# (This would require container-use enhancement)

# Start environment
environment_create(
  environment_source="/Users/adamsm/code/myproject",
  title="Dev with MCP sidecars"
)

# Add Smart Tree MCP as sidecar
environment_add_service(
  name="smart-tree-mcp",
  image="ghcr.io/8b-is/smart-tree:latest",
  command="st --mcp --http --port 8080 --bind 0.0.0.0",
  ports=[8080],
  envs=["MCP_ALLOWED_PATHS=/workspace"]
)

# Add Filesystem MCP as sidecar
environment_add_service(
  name="filesystem-mcp",
  image="mcp/filesystem:latest",
  command="node /app/index.js /workspace",
  ports=[8081]
)

# Add Git MCP as sidecar
environment_add_service(
  name="git-mcp",
  image="mcp/git:latest",
  command="python -m mcp_server_git --repository /workspace",
  ports=[8082]
)

# Now inside the container:
environment_run_cmd("""
# All MCP servers see the SAME /workspace directory!
curl http://localhost:8080/mcp -d '{"method":"tools/call","params":{"name":"analyze_directory","arguments":{"path":"/workspace"}}}'
""")
```

**Pros:**

- ✅ **Solves the path problem!** All containers see `/workspace`
- ✅ MCP servers have same filesystem view as your container
- ✅ localhost access (fast, no network hops)

**Cons:**

- ❌ Requires container-use to support sidecar pattern
- ❌ More resource usage (multiple containers)
- ❌ Need to coordinate startup order

---

### Pattern 3: MCP Gateway with Path Translation

A smart proxy that translates paths between container and host:

```/dev/null/pattern3-gateway.md#L1-45
┌─────────────────────────────────────────────────────────────────────────┐
│                        CONTAINER ENVIRONMENT                            │
│  ┌───────────────────────────────────────────────────────────────────┐  │
│  │  # Container sees /workspace                                      │  │
│  │  curl http://mcp-gateway/smart-tree/analyze_directory             │  │
│  │       -d '{"path": "/workspace/src"}'                             │  │
│  │                                                                    │  │
│  │  # Gateway translates to host path automatically                  │  │
│  └───────────────────────────────────────────────────────────────────┘  │
│                              │                                          │
│                              ▼                                          │
│  ┌───────────────────────────────────────────────────────────────────┐  │
│  │                      MCP GATEWAY                                   │  │
│  │  ┌─────────────────────────────────────────────────────────────┐  │  │
│  │  │  Path Translation Rules:                                     │  │  │
│  │  │  /workspace/* → /Users/adamsm/code/myproject/*              │  │  │
│  │  │  /home/user/* → /Users/adamsm/*                             │  │  │
│  │  │                                                              │  │  │
│  │  │  Request Flow:                                               │  │  │
│  │  │  1. Receive request with container path                      │  │  │
│  │  │  2. Translate path to host path                              │  │  │
│  │  │  3. Forward to actual MCP server                             │  │  │
│  │  │  4. Translate response paths back to container paths         │  │  │
│  │  └─────────────────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────────────────┘  │
│                              │                                          │
│                              ▼                                          │
│  ┌───────────────────────────────────────────────────────────────────┐  │
│  │            HOST MCP SERVERS (Smart Tree, Git, etc.)               │  │
│  │                    Using host paths                                │  │
│  └───────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────┘
```

**Implementation (Gateway Service):**

```/dev/null/pattern3-gateway-service.py#L1-60
# mcp-gateway.py - Path-translating MCP proxy
from fastmcp import FastMCP
import httpx

gateway = FastMCP("MCP Gateway")

# Path translation registry
PATH_MAPPINGS = {
    "/workspace": "/Users/adamsm/code/myproject",
    "/home/user": "/Users/adamsm",
}

def translate_path(container_path: str, to_host: bool = True) -> str:
    """Translate between container and host paths."""
    if to_host:
        for container, host in PATH_MAPPINGS.items():
            if container_path.startswith(container):
                return container_path.replace(container, host, 1)
    else:
        for container, host in PATH_MAPPINGS.items():
            if container_path.startswith(host):
                return container_path.replace(host, container, 1)
    return container_path

@gateway.tool
async def analyze_directory(path: str, mode: str = "ai") -> str:
    """Proxy to Smart Tree with path translation."""
    host_path = translate_path(path, to_host=True)

    async with httpx.AsyncClient() as client:
        response = await client.post(
            "http://smart-tree:8080/mcp",
            json={
                "jsonrpc": "2.0",
                "method": "tools/call",
                "params": {
                    "name": "analyze_directory",
                    "arguments": {"path": host_path, "mode": mode}
                },
                "id": 1
            }
        )
        result = response.json()

        # Translate paths in response back to container paths
        if "result" in result:
            result["result"] = translate_paths_in_response(
                result["result"], to_host=False
            )

        return result

if __name__ == "__main__":
    gateway.run(transport="http", host="0.0.0.0", port=8888)
```

**Pros:**

- ✅ Transparent path translation
- ✅ Works with existing MCP servers
- ✅ Centralized mapping configuration

**Cons:**

- ❌ Additional service to maintain
- ❌ Response path translation can be complex
- ❌ Need to keep mappings in sync with volume mounts

---

### Pattern 4: Native HTTP MCP in Container (Recommended)

The cleanest solution: containers have MCP clients that speak HTTP to external services:

```/dev/null/pattern4-native-http.md#L1-50
┌─────────────────────────────────────────────────────────────────────────┐
│                        CONTAINER ENVIRONMENT                            │
│  ┌───────────────────────────────────────────────────────────────────┐  │
│  │  # Python MCP client in container                                 │  │
│  │  from fastmcp.client import Client                                │  │
│  │  from fastmcp.client.transports import StreamableHttpTransport    │  │
│  │                                                                    │  │
│  │  # Connect to Smart Tree on host via HTTP                         │  │
│  │  transport = StreamableHttpTransport(                             │  │
│  │      url="http://host.docker.internal:8080/mcp"                   │  │
│  │  )                                                                │  │
│  │  client = Client(transport)                                       │  │
│  │                                                                    │  │
│  │  # Use MCP tools - paths are host paths                           │  │
│  │  # (volume-mounted, so container sees them too)                   │  │
│  │  result = await client.call_tool(                                 │  │
│  │      "analyze_directory",                                         │  │
│  │      {"path": "/Users/adamsm/code/myproject"}  # Host path        │  │
│  │  )                                                                │  │
│  │                                                                    │  │
│  │  # For container operations, use environment_file_* tools         │  │
│  └───────────────────────────────────────────────────────────────────┘  │
│                              │                                          │
│                              │ HTTP (Streamable HTTP)                   │
│                              ▼                                          │
│  ┌───────────────────────────────────────────────────────────────────┐  │
│  │                    MCP Servers (HTTP mode)                         │  │
│  │  • Smart Tree:  st --mcp (HTTP via supergateway)                  │  │
│  │  • Filesystem:  npx @modelcontextprotocol/server-filesystem       │  │
│  │  • Git:         uvx mcp-server-git                                │  │
│  │                                                                    │  │
│  │  All exposed via Traefik at tool.localhost/mcp/*                  │  │
│  └───────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────┘
```

---

### Answer to Your Question: Does Streamable HTTP Enable This?

**Yes, absolutely!** Streamable HTTP is the key enabler because:

| Aspect               | stdio Transport                   | Streamable HTTP                  |
| -------------------- | --------------------------------- | -------------------------------- |
| **Container Access** | ❌ Can't cross container boundary | ✅ HTTP works across networks    |
| **Multiple Clients** | ❌ One client per process         | ✅ Many clients per server       |
| **Network Routing**  | ❌ Not possible                   | ✅ Traefik, load balancers, etc. |
| **Authentication**   | ❌ Process-level only             | ✅ Headers, tokens, OAuth        |
| **Streaming**        | ✅ Native                         | ✅ Native (chunked/SSE)          |

**Your existing setup with supergateway already solves half the problem!**

---

### Recommended Architecture for Container-Use + MCP

```/dev/null/recommended-architecture.md#L1-55
┌─────────────────────────────────────────────────────────────────────────┐
│                           TRAEFIK                                       │
│                 https://tool.localhost/mcp/*                            │
│                 (X-Service header routing)                              │
└───────────────────────────────┬─────────────────────────────────────────┘
                                │
        ┌───────────────────────┼───────────────────────┐
        ▼                       ▼                       ▼
┌───────────────┐      ┌───────────────┐      ┌───────────────┐
│ smart-tree    │      │ github        │      │ filesystem    │
│ :8080/mcp     │      │ :8081/mcp     │      │ :8082/mcp     │
│ (supergateway)│      │ (supergateway)│      │ (native HTTP) │
└───────────────┘      └───────────────┘      └───────────────┘
        ▲                       ▲                       ▲
        │                       │                       │
        └───────────────────────┴───────────────────────┘
                                │
                    ┌───────────┴───────────┐
                    ▼                       ▼
┌─────────────────────────────┐ ┌─────────────────────────────┐
│   Claude Code (Host)        │ │   Container Environment     │
│   • Direct MCP via stdio    │ │   • HTTP MCP via Traefik    │
│   • Or HTTP for remote      │ │   • host.docker.internal    │
└─────────────────────────────┘ │   • OR traefik-public net   │
                                │                             │
                                │   from fastmcp import Client│
                                │   client = Client(          │
                                │     "http://traefik/mcp",   │
                                │     headers={"X-Service":   │
                                │              "smart-tree"}  │
                                │   )                         │
                                └─────────────────────────────┘
```

---

### Implementation Checklist

1. **Already Done (Your Setup):**
   - [x] Traefik reverse proxy
   - [x] supergateway for stdio→HTTP bridging
   - [x] X-Service header routing
   - [x] HTTP MCP endpoints

2. **To Enable Container-Use Integration:**
   - [ ] Ensure containers can reach `host.docker.internal` or join `traefik-public` network
   - [ ] Install MCP client library in container base image
   - [ ] Create helper script/library for common MCP operations
   - [ ] Document path conventions (host paths vs container paths)

3. **Optional Enhancements:**
   - [ ] MCP Gateway with path translation
   - [ ] Sidecar pattern for full filesystem parity
   - [ ] Authentication for container→MCP calls

---

### Quick Start for Container-Use + HTTP MCP

```/dev/null/quickstart.sh#L1-30
# 1. Configure environment to access MCP servers
environment_config(config={
  "setup_commands": [
    "pip install fastmcp httpx"
  ],
  "envs": [
    "MCP_BASE_URL=http://host.docker.internal"
  ]
})

# 2. Use MCP from inside container
environment_run_cmd("""
python << 'EOF'
import asyncio
from fastmcp.client import Client

async def main():
    # Connect to Smart Tree via HTTP
    async with Client("http://host.docker.internal:8080/mcp") as client:
        result = await client.call_tool(
            "analyze_directory",
            {"path": "/Users/adamsm/code/myproject", "mode": "ai"}
        )
        print(result)

asyncio.run(main())
EOF
""")
```

**Bottom Line:** Streamable HTTP MCP is the architectural key that unlocks container-use integration. Your existing supergateway setup is 90% of the way there!

Now I have all the information needed to provide a comprehensive analysis. Let me compile this into a thoughtful response.

---

## Analysis: Container-Use Compatibility for MCP Servers

Based on my review of the [container-use.md](file:///Users/adamsm/.config/nix/.ai/docs/adr/container-use.md) ADR and the MCP servers you mentioned, here's my analysis:

### Understanding the Container-Use ADR

The ADR outlines several architectural patterns for integrating MCP servers with containerized environments. The key insight is:

> **Streamable HTTP is the key enabler** because:
>
> - stdio transport cannot cross container boundaries
> - HTTP works across networks
> - Multiple clients can connect to one server
> - Supports authentication, routing via reverse proxies

---

## MCP Server Analysis

### 1. Smart-Tree (`8b-is/smart-tree`)

| Aspect                  | Assessment                                                                   |
| ----------------------- | ---------------------------------------------------------------------------- |
| **Repository**          | [github.com/8b-is/smart-tree](https://github.com/8b-is/smart-tree)           |
| **Language**            | Rust                                                                         |
| **Native HTTP Support** | ✅ **Yes** - Has `--mcp` flag for MCP server mode, SSE streaming (`--sse`)   |
| **Docker Ready**        | ⚠️ **Partial** - No official Dockerfile, but statically-compiled Rust binary |
| **Containerizable**     | ✅ **Yes**                                                                   |

**Key Features for Containerization:**

- Already supports MCP server mode via `st --mcp`
- Has streaming support (`--sse`, `--stream`)
- Operates on filesystem paths (needs volume mounts)
- Configuration via environment variables and config files

**Containerization Approach:**

```/dev/null/smart-tree-containerization.dockerfile#L1-15
FROM rust:alpine AS builder
RUN cargo install --git https://github.com/8b-is/smart-tree --tag v5.4.0 st

FROM alpine:latest
COPY --from=builder /usr/local/cargo/bin/st /usr/local/bin/st
# Need volume mount for filesystem access
VOLUME /workspace
ENV ST_DEFAULT_DEPTH=5
EXPOSE 8080
ENTRYPOINT ["st", "--mcp", "--port", "8080"]
```

**Container-Use Compatibility:** ✅ **HIGH** - Needs HTTP wrapper (supergateway) or native HTTP mode addition

---

### 2. Char-Index MCP (`agent-hanju/char-index-mcp`)

| Aspect                  | Assessment                                                                             |
| ----------------------- | -------------------------------------------------------------------------------------- |
| **Repository**          | [github.com/agent-hanju/char-index-mcp](https://github.com/agent-hanju/char-index-mcp) |
| **Language**            | Python                                                                                 |
| **Native HTTP Support** | ❌ **No** - stdio only                                                                 |
| **Docker Ready**        | ❌ **No Dockerfile**                                                                   |
| **Containerizable**     | ✅ **Yes**                                                                             |

**Key Insight:** This server is **stateless** and operates purely on string inputs - no filesystem access needed!

**Containerization Approach:**

```/dev/null/char-index-containerization.dockerfile#L1-12
FROM python:3.12-slim
RUN pip install char-index-mcp
# No volumes needed - stateless string operations

# Wrap with supergateway for HTTP
RUN npm install -g @anthropics/supergateway
EXPOSE 8080
ENTRYPOINT ["supergateway", "--port", "8080", "--", "char-index-mcp"]
```

**Container-Use Compatibility:** ✅ **EXCELLENT** - Stateless, no filesystem concerns

---

### 3. Filesystem MCP (`modelcontextprotocol/servers/filesystem`)

| Aspect                  | Assessment                                                                                               |
| ----------------------- | -------------------------------------------------------------------------------------------------------- |
| **Repository**          | [modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers/tree/main/src/filesystem) |
| **Language**            | TypeScript/Node.js                                                                                       |
| **Native HTTP Support** | ❌ **stdio only** (needs wrapper)                                                                        |
| **Docker Ready**        | ✅ **Yes** - Official Dockerfile                                                                         |
| **Containerizable**     | ✅ **Yes**                                                                                               |

**Official Docker Support Exists!** The Dockerfile is already production-ready:

```/dev/null/filesystem-docker-config.json#L1-15
{
  "mcpServers": {
    "filesystem": {
      "command": "docker",
      "args": [
        "run", "-i", "--rm",
        "--mount", "type=bind,src=/path/to/dir,dst=/projects/dir",
        "mcp/filesystem",
        "/projects"
      ]
    }
  }
}
```

**Container-Use Compatibility:** ⚠️ **MODERATE** - Path translation is the main challenge

The ADR's Pattern 2 (Sidecar Containers) addresses this:

> All containers see `/workspace` - **solves the path problem!**

---

### 4. Git MCP (`modelcontextprotocol/servers/git`)

| Aspect                  | Assessment                                                                                        |
| ----------------------- | ------------------------------------------------------------------------------------------------- |
| **Repository**          | [modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers/tree/main/src/git) |
| **Language**            | Python                                                                                            |
| **Native HTTP Support** | ❌ **stdio only**                                                                                 |
| **Docker Ready**        | ✅ **Yes** - Official Dockerfile with git/git-lfs                                                 |
| **Containerizable**     | ✅ **Yes**                                                                                        |

**Official Docker Support:**

```/dev/null/git-docker-config.json#L1-12
{
  "mcpServers": {
    "git": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "--mount", "type=bind,src=/Users/username,dst=/Users/username",
        "mcp/git"
      ]
    }
  }
}
```

**Container-Use Compatibility:** ⚠️ **MODERATE** - Same path translation concerns as filesystem

---

## Can These Be Containerized for Streamed HTTP?

### Architecture: Host ↔ MCP Server Container ↔ container-use w/ MCP Client

**YES, all four can be containerized!** Here's how:

### Recommended Pattern (from the ADR)

```/dev/null/recommended-architecture.md#L1-30
┌─────────────────────────────────────────────────────────────────────────┐
│                           TRAEFIK                                       │
│                 https://tool.localhost/mcp/*                            │
│                 (X-Service header routing)                              │
└───────────────────────────────┬─────────────────────────────────────────┘
                                │
        ┌───────────────────────┼───────────────────────┐
        ▼                       ▼                       ▼
┌───────────────┐      ┌───────────────┐      ┌───────────────┐
│ smart-tree    │      │ char-index    │      │ filesystem    │
│ (supergateway)│      │ (supergateway)│      │ (supergateway)│
│ :8080/mcp     │      │ :8081/mcp     │      │ :8082/mcp     │
└───────────────┘      └───────────────┘      └───────────────┘
        ▲                                              ▲
        │                                              │
        └──────────────────────────────────────────────┘
                           │
               ┌───────────┴───────────┐
               ▼                       ▼
┌─────────────────────────────┐ ┌─────────────────────────────┐
│   Claude Code (Host)        │ │   Container Environment     │
│   stdio or HTTP             │ │   HTTP via Traefik          │
└─────────────────────────────┘ └─────────────────────────────┘
```

### Implementation Matrix

| Server         | Needs Volume Mount  | Needs supergateway   | Path Translation | Difficulty |
| -------------- | ------------------- | -------------------- | ---------------- | ---------- |
| **Smart-Tree** | ✅ Yes (filesystem) | Maybe (has MCP mode) | Required         | Medium     |
| **Char-Index** | ❌ No (stateless)   | ✅ Yes               | None             | **Easy**   |
| **Filesystem** | ✅ Yes (filesystem) | ✅ Yes               | Required         | Medium     |
| **Git**        | ✅ Yes (.git dirs)  | ✅ Yes               | Required         | Medium     |

### Docker Compose Example

```/dev/null/docker-compose-mcp.yaml#L1-50
version: '3.8'

services:
  # Stateless - easiest to containerize
  char-index:
    image: python:3.12-slim
    command: >
      sh -c "pip install char-index-mcp supergateway &&
             supergateway --port 8080 -- char-index-mcp"
    ports:
      - "8081:8080"
    networks:
      - traefik-public

  # Filesystem access - needs shared volume
  filesystem:
    build:
      context: .
      dockerfile: src/filesystem/Dockerfile
    volumes:
      - workspace:/projects/workspace
    environment:
      - MCP_HTTP_PORT=8080  # Would need supergateway wrapper
    networks:
      - traefik-public

  # Git - needs repo access
  git:
    image: mcp/git
    volumes:
      - workspace:/workspace
    networks:
      - traefik-public

  # Smart Tree - filesystem analysis
  smart-tree:
    image: ghcr.io/8b-is/smart-tree:latest
    command: ["st", "--mcp"]
    volumes:
      - workspace:/workspace
    networks:
      - traefik-public

volumes:
  workspace:

networks:
  traefik-public:
    external: true
```

---

## Key Challenges & Solutions

### Challenge 1: stdio → HTTP Translation

**Solution:** Use `supergateway` or similar bridges:

```/dev/null/supergateway-example.sh#L1-3
# Wrap any stdio MCP server with HTTP
supergateway --port 8080 -- mcp-server-filesystem /workspace
```

### Challenge 2: Path Translation (Container ↔ Host)

**Solution A:** Sidecar Pattern (from ADR)

- All containers share `/workspace` volume
- Paths are consistent across containers

**Solution B:** MCP Gateway with Path Translation

```/dev/null/path-translation.py#L1-10
PATH_MAPPINGS = {
    "/workspace": "/Users/adamsm/code/myproject",
}

def translate_path(container_path: str) -> str:
    for container, host in PATH_MAPPINGS.items():
        if container_path.startswith(container):
            return container_path.replace(container, host, 1)
    return container_path
```

### Challenge 3: Network Access from container-use

**Solution:** Use `host.docker.internal` or join `traefik-public` network:

```/dev/null/container-use-config.py#L1-8
environment_config(config={
  "envs": [
    "MCP_ENDPOINT=http://host.docker.internal/mcp",
    # Or if on same Docker network:
    "MCP_ENDPOINT=http://traefik/mcp"
  ]
})
```

---

## Conclusion

| Server         | Container-Use Ready? | Effort Required                                     |
| -------------- | -------------------- | --------------------------------------------------- |
| **Smart-Tree** | ✅ Yes               | Medium - needs HTTP wrapper or native HTTP mode     |
| **Char-Index** | ✅ Yes               | **Low** - stateless, just add supergateway          |
| **Filesystem** | ✅ Yes               | Medium - official Docker exists, needs HTTP wrapper |
| **Git**        | ✅ Yes               | Medium - official Docker exists, needs HTTP wrapper |

**Bottom Line:** All four MCP servers can be containerized for Streamed HTTP access. The **char-index** server is the easiest (stateless). The filesystem-dependent ones (**smart-tree**, **filesystem**, **git**) require volume mounting and potentially path translation when used in container-use scenarios.

Your existing infrastructure with **supergateway** + **Traefik** is already 90% of the solution!
