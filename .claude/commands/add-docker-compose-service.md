---
id: 7f8a9b0c-1d2e-3f4a-5b6c-7d8e9f0a1b2c
title: Add Docker Compose Service
created: 2025-12-13T00:00:00
updated: 2025-12-13T00:00:00
project: dotfiles
scope: ai
type: reference
status: ✅ active
publish: false
tags:
  - claude
  - docker
  - compose
aliases:
  - Add Docker Compose Service
  - Add Docker Service
related: []
---

# Add Docker Compose Service

Create a new Docker Compose service configuration with Traefik routing, observability integration, and proper resource limits.

## Arguments

`$ARGUMENTS` should be one of:
- A Docker image name: `ghcr.io/org/image:tag`
- A Docker Hub image: `nginx:latest`
- A GitHub repository URL: `https://github.com/owner/repo`
- A service description: `"ollama - LLM inference server"`

## Overview

This command creates:
1. A Docker Compose module file in `docker/modules/<category>/`
2. A service configuration file in `docker/config/<service>/` (if the service requires configuration)
3. A Traefik dynamic routing config in `docker/config/traefik/dynamic/`
4. Updates `docker/config/traefik/dynamic/core.routes.yaml` if a new root router is needed
5. An issue file in `docs/notes/issues/` if metrics are not available

## Execution Steps

### 1. Research the Service

Before creating any files, research the service to gather:

```bash
# If GitHub URL provided, fetch README and docs
# Look for:
# - Default ports
# - Health check endpoints
# - Metrics endpoints (/metrics, /prometheus, etc.)
# - Environment variables
# - Volume requirements
# - Resource recommendations
```

**Key information to find:**
- **Image**: Full image reference (registry/org/image:tag)
- **Ports**: Which ports the service exposes
- **Health endpoint**: Common patterns: `/health`, `/healthz`, `/ready`, `/-/healthy`, `/api/health`
- **Metrics endpoint**: Common patterns: `/metrics`, `/prometheus`, `/-/metrics`
- **Volumes**: Data directories, config mounts
- **Environment**: Required and optional env vars
- **Resources**: CPU/memory recommendations from docs or community
- **Configuration**: Config file format (YAML, JSON, TOML, etc.), required settings, example configs

### 2. Determine Module Category

Place the compose file in the appropriate directory based on service type:

| Category | Directory | Examples |
|----------|-----------|----------|
| LLM/AI | `docker/modules/llm/` | ollama, vllm, text-generation-inference |
| Database | `docker/modules/db/` | postgres, redis, mongo, qdrant |
| Observability | `docker/modules/observability/` | prometheus, grafana, loki |
| Authentication | `docker/modules/authn/` | keycloak, hydra, kratos |
| Authorization | `docker/modules/authz/` | spicedb, keto, casbin |
| MCP Server | `docker/modules/mcp/<subcategory>/` | github, fetch, memory |
| Search | `docker/modules/search/` | meilisearch, elasticsearch |
| Ingress | `docker/modules/ingress/` | traefik, nginx, caddy |
| CI/CD | `docker/modules/cicd/` | gitlab-runner, drone |
| Streaming | `docker/modules/streaming/` | kafka, nats, pulsar |
| App Definition | `docker/modules/app-def/` | helm, kustomize |

### 3. Determine Network Tier

Based on service function, assign to appropriate network(s):

| Network | Use For |
|---------|---------|
| `backend` | API services, MCP servers, internal services |
| `frontend` | User-facing web UIs, dashboards |
| `admin` | Admin interfaces, management UIs |
| `data-tier` | Databases, caches, storage |
| `authn` | Authentication services |
| `authz` | Authorization services |

Most services should use `backend`. Databases should use `data-tier`. Add multiple networks if service needs to communicate across tiers.

### 4. Determine Profile(s)

Assign profiles based on service purpose:

| Profile | Use For |
|---------|---------|
| `core` | Essential infrastructure (always needed) |
| `o11y` | Observability stack (metrics, logs, traces) |
| `o11y-metrics` | Metrics-only observability |
| `o11y-tracing` | Tracing-only observability |
| `llm`, `ai` | LLM and AI services |
| `mcp` | MCP servers |
| `db-*` | Specific database types (db-vector, db-graph, etc.) |
| `research`, `research-ml` | Research and ML workloads |

### 5. Create the Compose File

Create `docker/modules/<category>/<service-name>.yaml`:

```yaml
---
# id: <generate-uuid-v4>
# =============================================================================
# <Service Name> - <Brief Description>
# =============================================================================
#
# <Longer description of what this service does>
#
# Source: <GitHub URL or official docs>
# Image: <full image reference>
#
# Features:
#   - <Feature 1>
#   - <Feature 2>
#   - <Feature 3>
#
# Environment Variables:
#   <VAR_NAME>     - <Description> (default: <value>)
#
# Data Persistence:
#   - <Volume description>: ${XDG_DATA_HOME}/<service>/
#
# Traefik Routing:
#   - Host: <service>.localhost (via svc.<category>.<service>.yaml)
#   - <Additional route info>
#
# Metrics:
#   - Endpoint: <endpoint or "Not available">
#   - See: <issue link if not available>
#
# Usage:
#   docker-compose -f <service>.yaml up
#   docker-compose -f <service>.yaml --profile <profile> up
#
# =============================================================================

services:
  <service-name>:
    image: <image>:<tag>
    container_name: <service-name>
    hostname: <service-name>
    profiles: ["<profile1>", "<profile2>"]
    networks:
      - <network>        # <Network description>
    restart: unless-stopped
    expose:
      - "<port>"
    volumes:
      # <Volume description>
      - ${XDG_DATA_HOME:-$HOME/.local/share}/<service>:<container-path>
      # Config (if needed)
      # - ${XDG_CONFIG_HOME:-$HOME/.config}/docker/config/<service>:<config-path>:ro
    environment:
      - <VAR>=<value>
    labels:
      # Traefik routing (Docker provider)
      traefik.enable: true
      traefik.docker.network: <network>
      traefik.http.services.<service>.loadbalancer.server.port: <port>
      traefik.http.routers.<service>.rule: Host(`<service>.${DOMAIN:-localhost}`)
      traefik.http.routers.<service>.entrypoints: websecure
      traefik.http.routers.<service>.tls: true
      # =========================================================================
      # Observability Labels
      # =========================================================================
      # <Comment about metrics availability>
      # =========================================================================
      prometheus.scrape: "<true|false>"
      prometheus.port: "<metrics-port>"
      prometheus.path: "<metrics-path>"
      o11y.service: "<service-name>"
      o11y.component: "<component-type>"
      # Resource review flags (remove if resources are confirmed)
      # needs.review.resource: "<cpu|mem>"
    logging:
      driver: "${O11Y_LOGGING_DRIVER:-json-file}"
      options:
        max-size: "${O11Y_LOG_MAX_SIZE:-10m}"
        max-file: "${O11Y_LOG_MAX_FILES:-3}"
        tag: "{{.Name}}"
    # Resource Tier: <Tier description>
    deploy:
      resources:
        limits:
          cpus: "<cpu-limit>"
          memory: <mem-limit>
        reservations:
          cpus: "<cpu-reservation>"
          memory: <mem-reservation>
    healthcheck:
      test: ["CMD-SHELL", "<health-check-command>"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: <start-period>

```

### 6. Resource Tier Guidelines

Use these tiers as starting points, adjust based on research:

| Tier | Description | CPU Limit | Memory Limit | CPU Reserve | Memory Reserve |
|------|-------------|-----------|--------------|-------------|----------------|
| 1 | Minimal (sidecars, init) | 0.25 | 128M | 0.05 | 32M |
| 2 | Lightweight (proxies, small APIs) | 0.5 | 256M | 0.1 | 64M |
| 3 | Standard (typical services) | 1.0 | 512M | 0.25 | 128M |
| 4 | Medium (larger services) | 2.0 | 1G | 0.5 | 256M |
| 5 | Database Standard | 2.0 | 4G | 0.5 | 1G |
| 6 | ML/Inference | 4.0 | 8G | 1.0 | 2G |
| 7 | Heavy (data processing) | 4.0 | 16G | 2.0 | 4G |

If resource requirements cannot be determined:
1. Add label: `needs.review.resource: cpu` or `needs.review.resource: mem`
2. Use Tier 3 (Standard) as default
3. Add comment explaining uncertainty

### 7. Health Check Patterns

Common health check patterns by service type:

```yaml
# HTTP health endpoint
test: ["CMD-SHELL", "curl -f http://localhost:<port>/health || exit 1"]

# HTTP with wget (Alpine images)
test: ["CMD-SHELL", "wget --spider -q http://localhost:<port>/healthz || exit 1"]

# TCP port check
test: ["CMD-SHELL", "nc -z localhost <port> || exit 1"]

# PostgreSQL
test: ["CMD-SHELL", "pg_isready -h localhost -U ${POSTGRES_USER}"]

# Redis/Valkey
test: ["CMD-SHELL", "redis-cli ping | grep -q PONG"]

# MongoDB
test: ["CMD-SHELL", "mongosh --eval 'db.runCommand(\"ping\").ok' --quiet"]

# Elasticsearch
test: ["CMD-SHELL", "curl -f http://localhost:9200/_cluster/health?wait_for_status=yellow || exit 1"]

# Node.js TCP check
test: ["CMD", "node", "-e", "require('net').connect(<port>, 'localhost').on('error', () => process.exit(1)).on('connect', () => process.exit(0))"]
```

Recommended intervals:
- `interval`: 30s (standard), 10s (critical services)
- `timeout`: 10s (standard), 5s (fast services)
- `retries`: 3
- `start_period`: 10s-60s (based on startup time)

### 8. Create Service Configuration File (if needed)

Many services require configuration files. If the service needs a config file:

1. **Create the config directory:**
```bash
mkdir -p docker/config/<service>/
```

2. **Create the configuration file** at `docker/config/<service>/<config-file>`:

**Common configuration patterns by service type:**

#### YAML Configuration (most common)
```yaml
# =============================================================================
# <Service Name> Configuration
# =============================================================================
# <Brief description of what this config controls>
#
# Documentation: <link to official docs>
#
# Environment variables are referenced with: ${VAR_NAME} or os.environ/VAR_NAME
# =============================================================================

# Example structure - adapt to service requirements
settings:
  # Core settings
  setting_name: value

  # Feature flags
  feature_enabled: true

  # Integration settings (e.g., upstream services)
  upstream:
    url: "http://<upstream-service>:<port>"
    api_key: "${API_KEY:-}"

# =============================================================================
# Environment Variables Reference
# =============================================================================
# List all environment variables used in this config:
#
# Required:
#   VAR_NAME          - Description
#
# Optional:
#   OPTIONAL_VAR      - Description (default: value)
# =============================================================================
```

#### JSON Configuration
```json
{
  "$schema": "<schema-url-if-available>",
  "_comment": "<Service Name> Configuration",
  "setting": "value",
  "nested": {
    "option": true
  }
}
```

#### TOML Configuration
```toml
# <Service Name> Configuration
# Documentation: <link>

[section]
setting = "value"
enabled = true

[section.nested]
option = "value"
```

#### INI Configuration
```ini
# <Service Name> Configuration
# Documentation: <link>

[section]
setting = value
enabled = true
```

3. **Mount the config in the compose file:**
```yaml
volumes:
  # Service configuration
  - ${XDG_CONFIG_HOME:-$HOME/.config}/docker/config/<service>/<config-file>:/app/config.<ext>:ro
```

4. **Add command to use config (if needed):**
```yaml
command:
  - "--config=/app/config.<ext>"
```

**Configuration file guidelines:**

| Guideline | Description |
|-----------|-------------|
| Use environment variables | Reference secrets via `${VAR}` or `os.environ/VAR` |
| Document all settings | Add comments explaining each option |
| Include defaults | Show default values in comments |
| Reference upstream services | Use Docker service names (e.g., `http://ccflare:8080`) |
| Add schema reference | Include `$schema` for JSON configs if available |
| Group related settings | Use sections/objects to organize |

**Example: LLM Gateway config with upstream integration:**
```yaml
# Route requests through load balancer proxy
model_list:
  - model_name: claude-sonnet
    litellm_params:
      model: anthropic/claude-sonnet-4-20250514
      api_base: http://ccflare:8080  # Route through ccflare
      api_key: "${ANTHROPIC_API_KEY}"
```

### 9. Create Traefik Routing Config

Create `docker/config/traefik/dynamic/svc.<category>.<service>.yaml` (see Section 3 in Overview):

```yaml
# =============================================================================
# <Service Name> - Traefik Routing Configuration
# =============================================================================
# HTTP routing for <service description> (Traefik v3.6+)
#
# Routing hierarchy:
#   <service>@file (root)  -> Host(`<service>.localhost`)
#     ├── <service>-api    -> PathPrefix(`/api`) [API endpoints]
#     ├── <service>-health -> PathPrefix(`/health`) [Health check]
#     └── <service>-ui     -> PathPrefix(`/`) [Web UI, catch-all]
#
# Container: <service> (<image>)
#   - HTTP endpoint: port <port>
#   - Health check: <health-path>
#   - Metrics: <metrics-path or "N/A">
# =============================================================================

http:
  routers:
    # =========================================================================
    # Health Check Router
    # =========================================================================
    <service>-health:
      rule: "PathPrefix(`/health`) || PathPrefix(`/healthz`) || PathPrefix(`/ready`)"
      service: <service>
      parentRefs:
        - <service>@file

    # =========================================================================
    # API Router (if applicable)
    # =========================================================================
    <service>-api:
      rule: "PathPrefix(`/api`)"
      service: <service>
      parentRefs:
        - <service>@file

    # =========================================================================
    # UI Router - Web interface (catch-all)
    # =========================================================================
    <service>-ui:
      rule: "PathPrefix(`/`)"
      service: <service>
      parentRefs:
        - <service>@file

  services:
    <service>:
      loadBalancer:
        servers:
          - url: "http://<service>:<port>"
        healthCheck:
          path: <health-path>
          interval: 30s
          timeout: 10s
```

### 10. Update Core Routes (if needed)

If this is a new service category needing a root router, add to `docker/config/traefik/dynamic/core.routes.yaml`:

```yaml
    # <Category description>
    <service>:
      rule: "Host(`<service>.localhost`)"
      entryPoints:
        - websecure
      tls: {}
```

### 11. Handle Missing Metrics

If the service does NOT expose a `/metrics` endpoint:

1. **Set labels in compose file:**
```yaml
labels:
  # NOTE: <service> does NOT expose a /metrics endpoint natively.
  # Prometheus scraping is disabled. HTTP metrics are available through Traefik.
  # See: docs/notes/issues/issue-<service>-metrics.md
  prometheus.scrape: "false"
  o11y.service: "<service>"
  o11y.metrics.source: "traefik"
```

2. **Create issue file** at `docs/notes/issues/issue-<service>-metrics.md`:

```yaml
---
id: <generate-uuid-v4>
title: "Add Prometheus Metrics to <Service Name>"
created: <current-datetime>
updated: <current-datetime>
project: dotfiles
scope:
  - docker
  - observability
type: issue
status: 🚧 wip
publish: false
tags:
  - issue
  - metrics
  - prometheus
  - <service>
aliases:
  - <Service> Metrics Issue
related:
  - ref: "[[<service>.yaml]]"
    description: Docker compose config for <service>
issue:
  type: improvement
  priority: p3-low
  status: open
  assignee: null
  labels: [upstream-contribution, observability]
  github_issue: null
---

# Add Prometheus Metrics to <Service Name>

## Description

The `<service>` service does not currently expose Prometheus-compatible metrics.
This limits observability to Traefik-level HTTP metrics only.

## Acceptance Criteria

- [ ] Service exposes `/metrics` endpoint with Prometheus-format metrics
- [ ] Metrics include service-specific telemetry (not just HTTP)
- [ ] Docker compose config updated to enable Prometheus scraping
- [ ] Grafana dashboard created (optional)

## Context

### Background

<Service description> is deployed via Docker Compose at:
- `docker/modules/<category>/<service>.yaml`

Currently, the only metrics available are through Traefik:
- `traefik_service_requests_total{service="<service>@docker"}`
- `traefik_service_request_duration_seconds_bucket{service="<service>@docker"}`

### Source Repository

- **Repository**: <GitHub URL>
- **Issues**: <GitHub issues URL>
- **Existing Metrics PR/Issue**: <link if found, or "None found">

## Technical Details

### Affected Components

- `docker/modules/<category>/<service>.yaml`
- `docker/config/prometheus/prometheus.yml` (scrape config)

### Proposed Solution

#### Option 1: Upstream Contribution

If the upstream project accepts contributions:

1. Fork the repository
2. Add Prometheus metrics instrumentation:
   - For Node.js: Use `prom-client`
   - For Go: Use `prometheus/client_golang`
   - For Python: Use `prometheus-client`
   - For Rust: Use `prometheus` crate
3. Expose `/metrics` endpoint
4. Submit PR upstream

#### Option 2: Metrics Sidecar

If upstream doesn't support metrics:

1. Add a metrics exporter sidecar container
2. Configure the exporter to scrape application-specific metrics
3. Example exporters:
   - Generic: `prom/statsd-exporter`
   - Process: `ncabatoff/process-exporter`
   - Custom: Build service-specific exporter

#### Option 3: Log-Based Metrics

Extract metrics from application logs:

1. Configure structured logging (JSON)
2. Use Loki with LogQL to generate metrics
3. Create recording rules in Loki

### Metrics to Expose

Recommended metrics for <service type>:

| Metric | Type | Description |
|--------|------|-------------|
| `<service>_requests_total` | Counter | Total requests processed |
| `<service>_request_duration_seconds` | Histogram | Request latency |
| `<service>_errors_total` | Counter | Total errors |
| `<service>_<specific>_*` | * | Service-specific metrics |

## Tasks

- [ ] Research if upstream has metrics support planned
- [ ] Open issue in upstream repository requesting metrics
- [ ] Implement metrics (upstream or sidecar)
- [ ] Update Docker compose config
- [ ] Add Prometheus scrape config
- [ ] Create Grafana dashboard

## Notes

- Traefik metrics provide basic HTTP-level observability as a fallback
- Query Traefik metrics: `traefik_service_*{service="<service>@docker"}`

---

> [!info] Metadata
> **Issue Type**: `= this.issue.type`
> **Priority**: `= this.issue.priority`
> **Issue Status**: `= this.issue.status`
```

## Output Summary

After completion, output a summary:

```markdown
## Docker Service Added: <service-name>

### Files Created

| File | Description |
|------|-------------|
| `docker/modules/<category>/<service>.yaml` | Docker Compose configuration |
| `docker/config/<service>/<config-file>` | Service configuration (if applicable) |
| `docker/config/traefik/dynamic/svc.<category>.<service>.yaml` | Traefik routing |
| `docker/config/traefik/dynamic/core.routes.yaml` | Updated with root router (if applicable) |
| `docs/notes/issues/issue-<service>-metrics.md` | Metrics issue (if no /metrics endpoint) |

### Configuration Summary

- **Image**: `<image>:<tag>`
- **Profile(s)**: `<profiles>`
- **Network(s)**: `<networks>`
- **Port(s)**: `<ports>`
- **Health Check**: `<health-endpoint>`
- **Metrics**: `<available/unavailable via traefik>`

### Access

```bash
# Start the service
docker-compose -f docker/modules/<category>/<service>.yaml --profile <profile> up -d

# Access via Traefik
https://<service>.localhost/
```

### Traefik Metrics (if native metrics unavailable)

```promql
# Request count
traefik_service_requests_total{service="<service>@docker"}

# Request duration
traefik_service_request_duration_seconds_bucket{service="<service>@docker"}
```
```

## Reference Files

- Example compose: `/Users/arustydev/repos/configs/dotfiles/docker/modules/llm/ccflare.yaml`
- Example compose with config: `/Users/arustydev/repos/configs/dotfiles/docker/modules/llm/litellm.yaml`
- Example service config: `/Users/arustydev/repos/configs/dotfiles/docker/config/litellm/config.yaml`
- Example traefik config: `/Users/arustydev/repos/configs/dotfiles/docker/config/traefik/dynamic/svc.llm.ccflare.yaml`
- Core routes: `/Users/arustydev/repos/configs/dotfiles/docker/config/traefik/dynamic/core.routes.yaml`
- Networks: `/Users/arustydev/repos/configs/dotfiles/docker/modules/core/networks.yaml`
- Issue template: `/Users/arustydev/repos/configs/dotfiles/.obsidian/templates/issue`
- Prometheus config: `/Users/arustydev/repos/configs/dotfiles/docker/config/prometheus/prometheus.yml`

## Examples

### Add a service from GitHub URL
```
/add-docker-compose-service https://github.com/qdrant/qdrant
```

### Add a service from Docker image
```
/add-docker-compose-service ghcr.io/open-webui/open-webui:latest
```

### Add a service with description
```
/add-docker-compose-service "minio - S3-compatible object storage"
```
