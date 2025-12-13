---
id: c3d4e5f6-a7b8-4c9d-0e1f-2a3b4c5d6e7f
title: Docker Compose Profile Strategy
created: 2025-12-12T00:00:00
updated: 2025-12-12T00:00:00
project: dotfiles
scope:
  - docker
type: reference
status: ✅ active
publish: true
tags:
  - docker
  - docker-compose
  - profiles
  - deployment
aliases:
  - Docker Profiles
  - Compose Profiles
related:
  - ref:
    description:
---

# Docker Compose Profile Strategy

This document defines the profile hierarchy and naming conventions for managing
Docker Compose service deployments across different contexts and workloads.

## Quick Reference

```bash
# Core infrastructure (all: auth, authz, db, o11y)
just deploy core

# Development workstation
just deploy core,mcp,mcp-project,mcp-thinking

# Full stack with project-specific profiles
just deploy core,mcp,project-iac

# Research workflow
just deploy core,mcp,mcp-memory,research

# List available profiles
just list-docker-profiles

# List all deployed projects
just list-projects
```

## Profile Hierarchy

### Tier 1: Core Infrastructure

The `core` profile includes all foundational services. This is a single unified
profile that combines auth, authz, db, and observability.

| Profile | Description | Services |
|---------|-------------|----------|
| `core` | All core infrastructure | traefik, kratos, hydra, oathkeeper, keto, spicedb, postgres, redis, valkey, grafana, loki, mimir |

### Tier 2: Extended Observability

Extended observability components, opt-in based on needs.

| Profile | Description | Services |
|---------|-------------|----------|
| `o11y` | Meta: all observability | (includes all o11y-*) |
| `o11y-tracing` | Distributed tracing | tempo, jaeger, zipkin |
| `o11y-metrics` | Extended metrics | prometheus, thanos, alertmanager |
| `o11y-logging` | Log aggregation | fluentd, vector, logstash |
| `o11y-profiling` | Continuous profiling | pyroscope, beyla |
| `o11y-apm` | APM platforms | signoz, openobserve |
| `o11y-collector` | Telemetry collection | otel-collector, alloy |

### Tier 3: MCP Servers

MCP servers organized by scope and use case.

| Profile | Description | Services |
|---------|-------------|----------|
| `mcp` | Global/shared MCP servers | github, duckduckgo, fetch, time, dockerhub, etc. |
| `mcp-docs` | Documentation servers | context7, rust-docs, aws-docs, cloudflare, etc. |
| `mcp-project` | Project-scoped base | filesystem, ast-grep, filescope, bruno |
| `mcp-memory` | Memory & notes | graphiti, obsidian, zettelkasten |
| `mcp-workflow` | Workflow automation | n8n, task-manager, todoist, agent-mcp |
| `mcp-thinking` | Reasoning/thinking | sequential-thinking, code-reasoning |
| `mcp-search` | Search engines | arxiv, paper-search, meilisearch-mcp |

### Tier 4: Project-Scoped Profiles

These profiles are scoped to specific projects and generate project-specific
compose files tracked in the manifest.

| Profile | Description | Services |
|---------|-------------|----------|
| `project-cad` | CAD/EDA projects | freecad, kicad |
| `project-iac` | Infrastructure as Code | terraform, aws-core, aws-terraform, aws-diagram |
| `project-data` | Data/database MCP | supabase-mcp, surrealdb-mcp |

### Tier 5: Context/Workload Profiles

Context-based profiles for specific work environments.

| Profile | Description | Typical Includes |
|---------|-------------|------------------|
| `work` | Work machine base | work-specific services |
| `research` | Research workflow | research tools |
| `research-ml` | ML/AI research | ollama, huggingface |
| `dev-cicd` | CI/CD runners | gitlab-runner |

### Tier 6: Standalone Databases

Non-core databases for specific use cases.

| Profile | Description | Services |
|---------|-------------|----------|
| `db-elastic` | Elasticsearch stack | elasticsearch, kibana |
| `db-mongo` | MongoDB | mongodb |
| `db-influx` | Time series | influxdb |
| `db-graph` | Graph databases | falkordb |
| `db-vector` | Vector databases | qdrant |
| `db-search` | Search engines | meilisearch, opensearch |
| `db-supabase` | Supabase stack | supabase services |

## Deployment Model

### Infrastructure vs Project Scoping

Profiles are automatically categorized into two groups:

1. **Infrastructure profiles**: Generate named compose files (`core.yaml`, `mcp.yaml`)
   - `core`, `mcp`, `o11y`, `research`, `work`, `db-*`
   - Files stored at: `~/.local/state/docker/<profile>.yaml`

2. **Project profiles**: Generate project-scoped compose files (`<project_id>.yaml`)
   - `project-cad`, `project-iac`, `project-data`, `mcp-project`
   - Files stored at: `~/.local/state/docker/projects/<project_id>.yaml`

### Template Generation Flow

```
docker-compose.yaml (source)
        │
        ▼
   docker compose config (resolve includes, validate)
        │
        ▼
   envsubst (expand ${VAR} environment variables)
        │
        ▼
   <profile>.yaml (template with op:// URLs intact)
        │
        ▼
   op inject (expand secrets at deploy time only)
        │
        ▼
   docker compose -f - up -d
```

### Project ID Configuration

Project-scoped profiles require a project ID configured in git:

```bash
# Set project ID for a repository
git config project.id $(uuidgen)

# View current project ID
git config project.id
```

### Manifest Tracking

Deployed projects are tracked in `~/.local/state/docker/manifests.json`:

```json
{
  "projects": {
    "53D043D8-8D06-4156-8FFA-4D02371B461A": {
      "profiles": "mcp-project,project-iac",
      "path": "/Users/dev/repos/my-terraform-project",
      "deployed_at": "2025-12-10T19:11:49Z",
      "compose_file": "/Users/dev/.local/state/docker/projects/53D043D8-8D06-4156-8FFA-4D02371B461A.yaml"
    }
  }
}
```

## Usage Examples

### Using justfile Commands

```bash
# Deploy core infrastructure
just deploy core

# Deploy with multiple profiles
just deploy core,mcp,project-iac

# Build images for profiles
just build core,mcp

# Destroy specific profiles
just destroy mcp

# Destroy all project services for current directory
just destroy-project

# List all deployed projects
just list-projects

# List available profiles
just list-docker-profiles

# Test config validity
just docker-test core,mcp

# Generate template without deploying (for debugging)
just docker-template core,mcp
```

### Using dc Helper Script

```bash
# Apply a preset
dc dev

# List available presets
dc ls

# List services for a profile
dc services core

# Add profile to current environment
dc +mcp-docs up -d

# Pass through to docker compose
dc -- config --services
```

### Available Presets (dc)

| Preset | Profiles |
|--------|----------|
| `minimal` | (none) |
| `core` | core |
| `dev` | core,mcp,mcp-project,mcp-thinking |
| `dev-full` | core,mcp,mcp-project,mcp-thinking,mcp-docs,mcp-memory |
| `mcp` | mcp,mcp-project |
| `mcp-full` | mcp,mcp-project,mcp-docs,mcp-memory,mcp-workflow,mcp-thinking |
| `o11y` | o11y |
| `o11y-full` | o11y,o11y-metrics,o11y-tracing,o11y-logging,o11y-profiling |
| `research` | core,mcp,mcp-memory,research |
| `research-ml` | core,mcp,mcp-memory,research,research-ml |
| `work` | work,mcp,mcp-project |
| `cad` | core,mcp,mcp-project,project-cad |
| `iac` | core,mcp,mcp-project,project-iac |
| `data` | core,mcp,mcp-project,project-data |

## Directory Structure

```
~/.config/docker/                    # Source configuration
├── docker-compose.yaml              # Main compose file (includes modules)
├── modules/                         # Service definitions by category
│   ├── core/                        # Networks, base config
│   ├── authn/                       # Authentication (Ory)
│   ├── authz/                       # Authorization (Keto, SpiceDB)
│   ├── db/                          # Databases
│   ├── observability/               # Monitoring, logging, tracing
│   ├── mcp/                         # MCP servers
│   │   ├── global/                  # Always-useful MCP
│   │   ├── docs/                    # Documentation MCP
│   │   ├── project/                 # Project-scoped MCP
│   │   ├── memory/                  # Memory/notes MCP
│   │   ├── workflow/                # Workflow MCP
│   │   ├── thinking/                # Reasoning MCP
│   │   └── search/                  # Search MCP
│   └── ...
└── config/                          # Service configuration files

~/.local/state/docker/               # Generated state
├── manifests.json                   # Project deployment tracking
├── domains                          # Registered DNS domains
├── core.yaml                        # Generated: core profile template
├── mcp.yaml                         # Generated: mcp profile template
├── o11y.yaml                        # Generated: o11y profile template
└── projects/
    ├── <project-uuid-1>.yaml        # Project-specific template
    └── <project-uuid-2>.yaml
```

## Required Tools

The deployment system requires:

- `docker` and `docker compose` - Container runtime
- `op` (1Password CLI) - Secret injection at deploy time
- `envsubst` - Environment variable expansion
- `sponge` (from moreutils) - In-place file updates
- `jq` - JSON manipulation for manifests

Install moreutils on macOS:
```bash
brew install moreutils
```

## Dependencies

All profiles except `work` assume that `core` services exist or will exist.
Cross-profile dependencies are documented in service YAML files but not enforced
at the Docker Compose level.

Example dependency documentation:
```yaml
# NOTE: Requires postgres service from core profile
# Dependencies (must be running before this service):
#   - postgres (core profile)
services:
  my-service:
    ...
```

## Migration Notes

When migrating existing services to the new profile scheme:

1. The unified `core` profile replaces `core-auth`, `core-authz`, `core-db`, `core-o11y`
2. `mcp-global` is now just `mcp`
3. `mcp-project-*` are now `project-*` (e.g., `project-cad`, `project-iac`)
4. Test with `just docker-test <profiles>` before deploying
5. Templates are now stored with `op://` URLs intact - secrets only expanded at deploy time

---

> [!info] Metadata
> **Scope**: `= this.scope`
> **Type**: `= this.type`
> **Status**: `= this.status`
