---
id: 456A3242-F5A4-46BA-9067-7F50E77E2EB5
title: MCP Config Generator - Strategy & Implementation Plan
status: ✅ Phase 1-3 Complete
date: 2025-01-27
author: adamsm
related:
  - 7A8B3C4D-E5F6-7890-ABCD-EF1234567890 # README.md
children:
  -  # Phase document IDs
---

# MCP Config Generator

> **Goal**: Generate MCP client configurations from a distributed YAML catalog system using Just recipes and JQ transformations.

## Executive Summary

This plan outlines a system to generate MCP (Model Context Protocol) configurations for multiple AI coding assistants from a unified catalog. The system supports both system/user-scoped (global) and project-scoped (local) configurations, with automatic deduplication.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                        MCP Catalog System                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  System/User Scope                    Project Scope                 │
│  ─────────────────                    ─────────────                 │
│  ${XDG_CONFIG_HOME}/mcp/              $PWD/.ai/mcp/                 │
│  └── catalog.yaml                     └── catalog.yaml              │
│      (global servers)                     (project servers)         │
│                                                                     │
│                    ┌──────────────────────┐                         │
│                    │   Merge & Filter     │                         │
│                    │   (Just + JQ)        │                         │
│                    └──────────┬───────────┘                         │
│                               │                                     │
│         ┌─────────────────────┼─────────────────────┐               │
│         ▼                     ▼                     ▼               │
│  ┌────────────┐        ┌────────────┐        ┌────────────┐         │
│  │    Zed     │        │   Claude   │        │   VSCode   │   ...   │
│  │  .jq file  │        │  .jq file  │        │  .jq file  │         │
│  └─────┬──────┘        └─────┬──────┘        └─────┬──────┘         │
│        │                     │                     │                │
│        ▼                     ▼                     ▼                │
│  settings.json    claude_desktop_      settings.json                │
│                     config.json                                     │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## Supported Clients

| Client             | Project Scope                          | System/User Scope                                    |
| ------------------ | -------------------------------------- | ---------------------------------------------------- |
| **Zed**            | `$PWD/.zed/settings.json`              | `$XDG_CONFIG_HOME/zed/settings.json`                 |
| **VSCode**         | `$PWD/.vscode/settings.json`           | `$XDG_CONFIG_HOME/Code/User/settings.json`           |
| **Claude Code**    | `$PWD/.claude/settings.json`           | `~/.claude/settings.json`                            |
| **Claude Desktop** | N/A                                    | `$XDG_CONFIG_HOME/Claude/claude_desktop_config.json` |
| **Cursor**         | `$PWD/.cursor/mcp.json`                | `~/.cursor/mcp.json`                                 |
| **Windsurf**       | `$PWD/.windsurfconfig/mcp_config.json` | `~/.codeium/windsurf/mcp_config.json`                |

## MCP Server Types

The catalog must support all these server connection patterns:

### 1. Local CLI (STDIO)

```yaml
servers:
  filesystem:
    transport: stdio
    command: npx
    args: ["-y", "@modelcontextprotocol/server-filesystem", "/path"]
```

### 2. HTTP/SSE Remote Endpoints

```yaml
servers:
  github-copilot:
    transport: http
    url: https://api.githubcopilot.com/mcp
    headers:
      Authorization: "Bearer ${GITHUB_TOKEN}"
```

### 3. Docker Run (Per-Session Container)

```yaml
servers:
  context7:
    transport: stdio
    docker:
      mode: run
      image: mcp/context7
      args: ["--rm", "-i"]
```

### 4. Docker Exec (Existing Container)

```yaml
servers:
  surrealdb:
    transport: stdio
    docker:
      mode: exec
      container: surrealdb-mcp
      command: ["/app/mcp-server"]
```

### 5. Docker HTTP/SSE (Container Endpoint)

```yaml
servers:
  graphiti:
    transport: http
    url: https://memory.localhost/mcp
    # Container managed separately via docker-compose
```

---

## Phase 1: Catalog Schema Definition

### Deliverables

- [ ] JSON Schema for `catalog.yaml`
- [ ] Example system catalog
- [ ] Example project catalog

### Catalog Schema (Draft)

```yaml
# $XDG_CONFIG_HOME/mcp/catalog.yaml
---
$schema: "https://mcp.config.local/schemas/catalog.v1.json"
version: "1.0"

defaults:
  # Default environment variables for all servers
  env:
    MCP_LOG_LEVEL: info

servers:
  # Server name (used as key in client configs)
  github:
    # Whether this server should be available globally
    global: true

    # Enable/disable without removing config
    enabled: true

    # Optional: Human-readable description
    description: "GitHub Copilot MCP integration"

    # Transport configuration
    transport: stdio | http | sse

    # For http/sse transports
    url: "https://api.example.com/mcp"
    headers:
      Authorization: "Bearer ${TOKEN}"

    # For stdio transports
    command: npx | uvx | uv | docker | /path/to/binary
    args:
      - "-y"
      - "@modelcontextprotocol/server-github"

    # Environment variables (supports 1Password references)
    env:
      GITHUB_TOKEN: "op://Developer/github/token"
      DEBUG: "mcp:*"

    # Docker-specific configuration
    docker:
      mode: run | exec
      image: "ghcr.io/github/github-mcp-server"
      container: "mcp-github" # For exec mode
      volumes:
        - "${HOME}/.config:/config:ro"
      network: host | bridge | <container_name>
      extra_args:
        - "--rm"
        - "--annotation"
        - "scope:global"

    # Client-specific overrides
    overrides:
      zed:
        # Zed-specific config adjustments
        source: custom
      claude-desktop:
        # Claude Desktop specific
        autoApprove: ["read_*"]
```

---

## Phase 2: JQ Transformation Scripts

### Directory Structure

```
$XDG_CONFIG_HOME/mcp/
├── catalog.yaml              # System/User catalog
├── schemas/
│   └── catalog.v1.json       # JSON Schema
└── transforms/
    ├── _common.jq            # Shared functions
    ├── merge-catalogs.jq     # Merge system + project
    ├── claude-desktop.jq     # Claude Desktop format
    ├── claude-code.jq        # Claude Code format
    ├── zed.jq                # Zed format
    ├── vscode.jq             # VSCode format
    ├── cursor.jq             # Cursor format
    └── windsurf.jq           # Windsurf format
```

### Transform Logic Examples

#### `_common.jq` - Shared Functions

```jq
# Build stdio command array
def stdio_command:
  if .docker then
    if .docker.mode == "run" then
      ["docker", "run", "-i"] + (.docker.extra_args // []) +
      [.docker.image] + (.args // [])
    elif .docker.mode == "exec" then
      ["docker", "exec", "-i", .docker.container] + (.args // [])
    else . end
  else
    [.command] + (.args // [])
  end;

# Filter enabled servers
def enabled_servers:
  .servers | to_entries | map(select(.value.enabled != false));

# Filter by scope
def by_scope(scope):
  if scope == "global" then
    map(select(.value.global == true))
  else
    .
  end;
```

#### `claude-desktop.jq` - Claude Desktop Format

```jq
include "_common";

# Transform to Claude Desktop format
{
  mcpServers: (
    enabled_servers | by_scope($scope) |
    map({
      key: .key,
      value: (
        if .value.transport == "stdio" then
          {
            command: (.value | stdio_command | .[0]),
            args: (.value | stdio_command | .[1:]),
            env: (.value.env // {})
          } + (.value.overrides."claude-desktop" // {})
        elif .value.transport == "http" or .value.transport == "sse" then
          {
            url: .value.url,
            transport: { type: .value.transport }
          } + (if .value.headers then { headers: .value.headers } else {} end)
        else {}
        end
      )
    }) | from_entries
  )
}
```

#### `zed.jq` - Zed Editor Format

```jq
include "_common";

# Transform to Zed format
{
  context_servers: (
    enabled_servers | by_scope($scope) |
    map({
      key: .key,
      value: {
        source: "custom"
      } + (
        if .value.transport == "stdio" then
          {
            command: (.value | stdio_command | .[0]),
            args: (.value | stdio_command | .[1:]),
            env: (.value.env // {})
          }
        elif .value.transport == "http" then
          {
            command: "npx",
            args: ["-y", "mcp-remote", .value.url, "--allow-http"] +
              (if .value.headers then
                (.value.headers | to_entries | map(["--header", "\(.key): \(.value)"]) | flatten)
              else [] end)
          }
        else {}
        end
      ) + (.value.overrides.zed // {})
    }) | from_entries
  )
}
```

#### `vscode.jq` - VSCode Format

```jq
include "_common";

# Transform to VSCode format
{
  mcp: {
    servers: (
      enabled_servers | by_scope($scope) |
      map({
        key: .key,
        value: {
          type: .value.transport
        } + (
          if .value.transport == "stdio" then
            {
              command: (.value | stdio_command | .[0]),
              args: (.value | stdio_command | .[1:])
            }
          elif .value.transport == "http" or .value.transport == "sse" then
            { url: .value.url }
          else {}
          end
        ) + (.value.overrides.vscode // {})
      }) | from_entries
    )
  }
}
```

---

## Phase 3: Just Recipes

### Main Justfile Module: `mcp.just`

```just
# MCP Config Generator
# Usage: just gen-mcp-config [--global] [--profile=<name>] <client>

set unstable := true

xdg_config := env("XDG_CONFIG_HOME", env("HOME") + "/.config")
mcp_catalog_system := xdg_config / "mcp/catalog.yaml"
mcp_catalog_project := justfile_directory() / ".ai/mcp/catalog.yaml"
mcp_transforms := xdg_config / "mcp/transforms"

# Client config paths
_zed_global := xdg_config / "zed/settings.json"
_zed_project := justfile_directory() / ".zed/settings.json"
_claude_desktop := env("HOME") / "Library/Application Support/Claude/claude_desktop_config.json"
_claude_code_global := env("HOME") / ".claude/settings.json"
_claude_code_project := justfile_directory() / ".claude/settings.json"
_vscode_global := xdg_config / "Code/User/settings.json"
_vscode_project := justfile_directory() / ".vscode/settings.json"
_cursor_global := env("HOME") / ".cursor/mcp.json"
_cursor_project := justfile_directory() / ".cursor/mcp.json"
_windsurf_global := env("HOME") / ".codeium/windsurf/mcp_config.json"
_windsurf_project := justfile_directory() / ".windsurfconfig/mcp_config.json"

# Main entry point
[doc("Generate MCP config for specified client")]
gen-mcp-config client scope="project" profile="":
    #!/usr/bin/env bash
    set -euo pipefail

    # Determine scope
    SCOPE="{{ scope }}"
    PROFILE="{{ profile }}"
    CLIENT="{{ client }}"

    # Get target config path
    case "$CLIENT" in
        zed)
            if [[ "$SCOPE" == "global" ]]; then
                TARGET="{{ _zed_global }}"
            else
                TARGET="{{ _zed_project }}"
            fi
            JQ_KEY="context_servers"
            ;;
        claude-desktop)
            TARGET="{{ _claude_desktop }}"
            SCOPE="global"  # Always global
            JQ_KEY="mcpServers"
            ;;
        claude-code|claude)
            if [[ "$SCOPE" == "global" ]]; then
                TARGET="{{ _claude_code_global }}"
            else
                TARGET="{{ _claude_code_project }}"
            fi
            JQ_KEY="mcpServers"
            ;;
        vscode|code)
            if [[ "$SCOPE" == "global" ]]; then
                if [[ -n "$PROFILE" ]]; then
                    TARGET="{{ xdg_config }}/Code/User/profiles/$PROFILE/settings.json"
                else
                    TARGET="{{ _vscode_global }}"
                fi
            else
                TARGET="{{ _vscode_project }}"
            fi
            JQ_KEY="mcp.servers"
            ;;
        cursor)
            if [[ "$SCOPE" == "global" ]]; then
                TARGET="{{ _cursor_global }}"
            else
                TARGET="{{ _cursor_project }}"
            fi
            JQ_KEY="mcpServers"
            ;;
        windsurf)
            if [[ "$SCOPE" == "global" ]]; then
                TARGET="{{ _windsurf_global }}"
            else
                TARGET="{{ _windsurf_project }}"
            fi
            JQ_KEY="mcpServers"
            ;;
        *)
            echo "Unknown client: $CLIENT"
            echo "Supported: zed, claude-desktop, claude-code, vscode, cursor, windsurf"
            exit 1
            ;;
    esac

    echo "Generating $CLIENT config ($SCOPE scope) -> $TARGET"

    # Generate config
    just _gen-mcp-internal "$CLIENT" "$SCOPE" "$TARGET" "$JQ_KEY"

# Internal generation logic
[private]
_gen-mcp-internal client scope target jq_key:
    #!/usr/bin/env bash
    set -euo pipefail

    CLIENT="{{ client }}"
    SCOPE="{{ scope }}"
    TARGET="{{ target }}"
    JQ_KEY="{{ jq_key }}"
    TRANSFORM="{{ mcp_transforms }}/${CLIENT}.jq"

    # Check if transform exists
    if [[ ! -f "$TRANSFORM" ]]; then
        echo "Error: Transform not found: $TRANSFORM"
        exit 1
    fi

    # Build merged catalog
    MERGED=$(just _merge-catalogs "$SCOPE")

    # Inject secrets (1Password)
    if command -v op &> /dev/null; then
        MERGED=$(echo "$MERGED" | op inject)
    fi

    # Expand environment variables
    MERGED=$(echo "$MERGED" | envsubst)

    # Transform to client format
    MCP_CONFIG=$(echo "$MERGED" | jq -L "{{ mcp_transforms }}" --arg scope "$SCOPE" -f "$TRANSFORM")

    # Ensure target directory exists
    mkdir -p "$(dirname "$TARGET")"

    # Merge into existing config or create new
    if [[ -f "$TARGET" ]]; then
        # Remove comments from JSON (for editors that allow them)
        EXISTING=$(sed -e 's|//.*||g' -e '/^[[:space:]]*$/d' "$TARGET" | jq '.')

        # Deep merge MCP config into existing
        echo "$EXISTING" | jq --argjson mcp "$MCP_CONFIG" \
            '. * $mcp' | sponge "$TARGET"
    else
        echo "$MCP_CONFIG" | jq '.' > "$TARGET"
    fi

    echo "✓ Generated $TARGET"

# Merge system and project catalogs
[private]
_merge-catalogs scope:
    #!/usr/bin/env bash
    set -euo pipefail

    SCOPE="{{ scope }}"
    SYSTEM_CATALOG="{{ mcp_catalog_system }}"
    PROJECT_CATALOG="{{ mcp_catalog_project }}"

    # Convert YAML to JSON
    if [[ -f "$SYSTEM_CATALOG" ]]; then
        SYSTEM_JSON=$(yq -o json '.' "$SYSTEM_CATALOG")
    else
        SYSTEM_JSON='{"servers":{}}'
    fi

    if [[ -f "$PROJECT_CATALOG" && "$SCOPE" != "global" ]]; then
        PROJECT_JSON=$(yq -o json '.' "$PROJECT_CATALOG")
    else
        PROJECT_JSON='{"servers":{}}'
    fi

    # Merge: project overrides system for non-global servers
    # Global servers from system always win
    jq -n --argjson sys "$SYSTEM_JSON" --argjson proj "$PROJECT_JSON" '
      {
        servers: (
          ($sys.servers // {}) *
          (($proj.servers // {}) | with_entries(
            select(.value.global != true)
          ))
        )
      }
    '

# List all configured MCP servers
[doc("List all MCP servers from catalogs")]
list-mcp-servers scope="all":
    #!/usr/bin/env bash
    set -euo pipefail

    echo "=== MCP Servers ==="
    echo ""

    if [[ "{{ scope }}" == "all" || "{{ scope }}" == "global" ]]; then
        echo "System/User Catalog ({{ mcp_catalog_system }}):"
        if [[ -f "{{ mcp_catalog_system }}" ]]; then
            yq '.servers | keys | .[]' "{{ mcp_catalog_system }}" | sed 's/^/  /'
        else
            echo "  (not found)"
        fi
        echo ""
    fi

    if [[ "{{ scope }}" == "all" || "{{ scope }}" == "project" ]]; then
        echo "Project Catalog ({{ mcp_catalog_project }}):"
        if [[ -f "{{ mcp_catalog_project }}" ]]; then
            yq '.servers | keys | .[]' "{{ mcp_catalog_project }}" | sed 's/^/  /'
        else
            echo "  (not found)"
        fi
    fi

# Generate configs for all clients
[doc("Generate MCP configs for all clients")]
gen-mcp-all scope="project":
    #!/usr/bin/env bash
    set -euo pipefail

    CLIENTS="zed claude-code vscode cursor windsurf"

    if [[ "{{ scope }}" == "global" ]]; then
        CLIENTS="zed claude-desktop claude-code vscode cursor windsurf"
    fi

    for client in $CLIENTS; do
        just gen-mcp-config "$client" "{{ scope }}" || true
    done

# Validate catalog schema
[doc("Validate catalog YAML against schema")]
validate-catalog file=mcp_catalog_system:
    #!/usr/bin/env bash
    set -euo pipefail

    SCHEMA="{{ xdg_config }}/mcp/schemas/catalog.v1.json"

    if [[ ! -f "$SCHEMA" ]]; then
        echo "Warning: Schema not found at $SCHEMA"
        echo "Skipping validation"
        exit 0
    fi

    yq -o json '.' "{{ file }}" | \
        check-jsonschema --schemafile "$SCHEMA" -
```

---

## Phase 4: Implementation Checklist

### Prerequisites

- [ ] Install dependencies: `jq`, `yq`, `sponge` (moreutils), `envsubst`, `op` (1Password CLI)
- [ ] Create directory structure

### Phase 4.1: Schema & Structure

- [ ] Create `$XDG_CONFIG_HOME/mcp/` directory
- [ ] Create JSON Schema for catalog validation
- [ ] Create example system catalog
- [ ] Create example project catalog

### Phase 4.2: JQ Transforms

- [ ] `_common.jq` - Shared functions
- [ ] `merge-catalogs.jq` - Catalog merging
- [ ] `claude-desktop.jq`
- [ ] `claude-code.jq`
- [ ] `zed.jq`
- [ ] `vscode.jq`
- [ ] `cursor.jq`
- [ ] `windsurf.jq`

### Phase 4.3: Just Recipes

- [ ] Create `mcp.just` module
- [ ] Integrate into main justfile
- [ ] Add shell completions

### Phase 4.4: Testing & Documentation

- [ ] Test each client generation
- [ ] Document catalog schema
- [ ] Add usage examples
- [ ] Create ADR for design decisions

---

## Usage Examples

```bash
# Generate project-scoped config for Zed
just gen-mcp-config zed

# Generate global config for Claude Desktop
just gen-mcp-config claude-desktop --global

# Generate VSCode config for specific profile
just gen-mcp-config vscode --global --profile=my-profile

# Generate all client configs (project scope)
just gen-mcp-all

# Generate all client configs (global scope)
just gen-mcp-all --global

# List all configured servers
just list-mcp-servers

# Validate catalog
just validate-catalog ~/.config/mcp/catalog.yaml
```

---

## Open Questions

1. **Config Merging Strategy**: Should MCP configs completely replace existing, or deep merge?
   - **Decision**: Deep merge, allowing manual additions to persist

2. **Secret Injection**: Support multiple secret backends (1Password, vault, env)?
   - **Decision**: Start with 1Password + envsubst, extensible later

3. **Docker Network Handling**: How to handle container networking across clients?
   - **Decision**: Use `host` network for simplicity, document alternatives

4. **Remote MCP Proxy**: Some clients don't support HTTP transport natively
   - **Decision**: Use `mcp-remote` npm package as stdio wrapper for HTTP endpoints

---

## References

- [MCP Specification](https://spec.modelcontextprotocol.io/)
- [FastMCP Documentation](https://gofastmcp.com/)
- [Zed Context Servers](https://zed.dev/docs/context-servers)
- [Claude Code MCP](https://docs.anthropic.com/en/docs/claude-code/mcp)
- [VSCode MCP Extension](https://marketplace.visualstudio.com/items?itemName=anthropic.mcp)
