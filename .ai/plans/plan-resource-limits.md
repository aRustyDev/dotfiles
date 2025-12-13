# Plan: Docker Compose Resource Limits Audit

## Status: Implemented

## Overview

Audit all 102 Docker Compose service files in `modules/**` and define sane resource
requests/limits for each service based on their workload characteristics.

## Current State

- **Total service files**: 102
- **With resource limits**: 82
- **Missing resource limits**: 20

### Services Missing Resource Limits

| File | Category | Priority |
|------|----------|----------|
| `db/postgres.yaml` | Database | High |
| `db/qdrant.yaml` | Database | High |
| `db/surrealdb.yaml` | Database | High |
| `mcp/docs/aws.yaml` | MCP | Medium |
| `mcp/docs/context7.yaml` | MCP | Medium |
| `mcp/global/aws-api.yaml` | MCP | Medium |
| `mcp/global/aws-cloudtrail.yaml` | MCP | Medium |
| `mcp/global/aws-core.yaml` | MCP | Medium |
| `mcp/global/aws-diagram.yaml` | MCP | Medium |
| `mcp/global/aws-terraform.yaml` | MCP | Medium |
| `mcp/global/terraform.yaml` | MCP | Medium |
| `mcp/notes/zettelkasten.yaml` | MCP | Medium |
| `mcp/observability/prometheus-server.yaml` | MCP | Medium |
| `mcp/project/filesystem.yaml` | MCP | Medium |
| `mcp/util/mcp-proxy.yaml` | MCP | Medium |
| `mcp/workflow/agent-mcp.yaml` | MCP | Medium |
| `mcp/workflow/n8n.yaml` | Workflow | High |
| `search/meilisearch.yaml` | Search | High |
| `core/networks.yaml` | Infra | N/A (no services) |
| `mcp/TODO.yaml` | N/A | N/A (placeholder) |

## Resource Tier Definitions

### Tier 1: Minimal (MCP Lightweight)
For simple MCP servers that primarily proxy requests or do light processing.

```yaml
deploy:
  resources:
    limits:
      cpus: "0.5"
      memory: 256M
    reservations:
      cpus: "0.1"
      memory: 64M
```

**Services**: time, fetch, dockerhub, github, gitlab, editorconfig, todoist,
checklist, obsidian, zettelkasten, webhooks

### Tier 2: Light (MCP Standard)
For MCP servers with moderate processing or caching needs.

```yaml
deploy:
  resources:
    limits:
      cpus: "0.5"
      memory: 512M
    reservations:
      cpus: "0.1"
      memory: 128M
```

**Services**: aws-*, terraform, arxiv, duckduckgo, paper-search, context7,
astro, cloudflare, crate, rust, typst, markitdown, huggingface

### Tier 3: Medium (Processing)
For services that do significant computation or maintain state.

```yaml
deploy:
  resources:
    limits:
      cpus: "1.0"
      memory: 1G
    reservations:
      cpus: "0.25"
      memory: 256M
```

**Services**: sequential-thinking, code-reasoning, multi-agent-system,
ast-grep, filescope, bruno, graphiti, n8n, agent-mcp, task-master,
task-orchestrator, task-manager, mcp-proxy, prometheus-server

### Tier 4: Heavy (Databases Light)
For lightweight databases and caches.

```yaml
deploy:
  resources:
    limits:
      cpus: "1.0"
      memory: 2G
    reservations:
      cpus: "0.25"
      memory: 512M
```

**Services**: redis, valkey, falkor, graphite, influxdb, alertmanager,
vector, fluentd, alloy, otel-collector, zipkin, beyla

### Tier 5: Database Standard
For standard database workloads.

```yaml
deploy:
  resources:
    limits:
      cpus: "2.0"
      memory: 4G
    reservations:
      cpus: "0.5"
      memory: 1G
```

**Services**: postgres, mongo, surrealdb, qdrant, meilisearch,
prometheus, loki, tempo, jaeger, pyroscope

### Tier 6: Database Heavy
For memory-intensive databases and search engines.

```yaml
deploy:
  resources:
    limits:
      cpus: "2.0"
      memory: 8G
    reservations:
      cpus: "1.0"
      memory: 2G
```

**Services**: elasticsearch, opensearch, kibana, logstash, thanos,
mimir, grafana (with many dashboards), signoz, openobserve

### Tier 7: Specialized
For services with unique requirements.

**Ollama (LLM)**:
```yaml
deploy:
  resources:
    limits:
      cpus: "4.0"
      memory: 16G
    reservations:
      cpus: "1.0"
      memory: 4G
```

**Traefik (Ingress)**:
```yaml
deploy:
  resources:
    limits:
      cpus: "1.0"
      memory: 512M
    reservations:
      cpus: "0.25"
      memory: 128M
```

**Auth Services (Ory Stack)**:
```yaml
deploy:
  resources:
    limits:
      cpus: "0.5"
      memory: 512M
    reservations:
      cpus: "0.1"
      memory: 128M
```

**SpiceDB**:
```yaml
deploy:
  resources:
    limits:
      cpus: "1.0"
      memory: 1G
    reservations:
      cpus: "0.25"
      memory: 256M
```

## Implementation Phases

### Phase 1: Critical Missing (Priority: High)

Add resource limits to services currently without them that are high-impact:

1. `db/postgres.yaml` - Tier 5
2. `db/qdrant.yaml` - Tier 5
3. `db/surrealdb.yaml` - Tier 5
4. `search/meilisearch.yaml` - Tier 5
5. `mcp/workflow/n8n.yaml` - Tier 3

### Phase 2: MCP Servers Missing Limits

Add resource limits to remaining MCP servers:

1. `mcp/docs/aws.yaml` - Tier 2
2. `mcp/docs/context7.yaml` - Tier 2
3. `mcp/global/aws-*.yaml` (6 files) - Tier 2
4. `mcp/global/terraform.yaml` - Tier 2
5. `mcp/notes/zettelkasten.yaml` - Tier 1
6. `mcp/observability/prometheus-server.yaml` - Tier 3
7. `mcp/project/filesystem.yaml` - Tier 1
8. `mcp/util/mcp-proxy.yaml` - Tier 3
9. `mcp/workflow/agent-mcp.yaml` - Tier 3

### Phase 3: Audit Existing Limits

Review and adjust existing resource limits:

1. **Verify against actual usage** - Use `docker stats` to collect real metrics
2. **Identify over-provisioned** - Services with limits much higher than usage
3. **Identify under-provisioned** - Services hitting limits or OOM kills
4. **Standardize tiers** - Ensure consistent limits across similar services

### Phase 4: Documentation

1. Add resource tier reference to `docs/DOCKER_PROFILES.md`
2. Document how to monitor resource usage
3. Add comments in YAML files explaining tier choice

## Monitoring Strategy

### Collect Baseline Metrics

```bash
# Run for 24-48 hours under normal usage
docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}" \
  --no-stream >> ~/.local/state/docker/resource-stats.log
```

### Analyze with Script

```bash
# Create analysis recipe in justfile
docker-resource-report:
    @echo "=== Top CPU Consumers ==="
    @docker stats --no-stream --format "{{.Name}}: {{.CPUPerc}}" | sort -t: -k2 -rn | head -10
    @echo ""
    @echo "=== Top Memory Consumers ==="
    @docker stats --no-stream --format "{{.Name}}: {{.MemUsage}}" | sort -t: -k2 -rh | head -10
    @echo ""
    @echo "=== Near Memory Limit (>80%) ==="
    @docker stats --no-stream --format "{{.Name}}: {{.MemPerc}}" | awk -F: '$2 > 80 {print}'
```

## Service-by-Service Recommendations

### Databases

| Service | Current | Recommended | Notes |
|---------|---------|-------------|-------|
| postgres | None | Tier 5 (4G) | Connection pooling, query cache |
| elasticsearch | Tier 6 | Tier 6 (8G) | JVM heap = 50% of limit |
| mongo | ? | Tier 5 (4G) | WiredTiger cache |
| redis | ? | Tier 4 (2G) | In-memory, adjust per dataset |
| qdrant | None | Tier 5 (4G) | Vector index in memory |
| surrealdb | None | Tier 5 (4G) | Depends on storage engine |
| meilisearch | None | Tier 5 (4G) | Index size dependent |

### Observability

| Service | Current | Recommended | Notes |
|---------|---------|-------------|-------|
| prometheus | Tier 3 | Tier 5 (4G) | TSDB in memory, retention dependent |
| grafana | Tier 3 | Tier 3 (1G) | Dashboard count dependent |
| loki | Tier 4 | Tier 5 (4G) | Log volume dependent |
| tempo | Tier 4 | Tier 5 (4G) | Trace volume dependent |
| jaeger | Tier 4 | Tier 5 (4G) | Similar to tempo |
| otel-collector | Tier 2 | Tier 4 (2G) | Pipeline complexity dependent |

### MCP Servers

| Service | Current | Recommended | Notes |
|---------|---------|-------------|-------|
| fetch | Tier 1 | Tier 1 (256M) | Stateless proxy |
| github/gitlab | Tier 1 | Tier 1 (256M) | API proxy |
| graphiti | Tier 3 | Tier 3 (1G) | Knowledge graph ops |
| sequential-thinking | Tier 2 | Tier 3 (1G) | LLM context processing |
| context7 | None | Tier 2 (512M) | Doc indexing |

### Auth

| Service | Current | Recommended | Notes |
|---------|---------|-------------|-------|
| hydra | ? | Tier 3 (1G) | Token storage, crypto |
| kratos | ? | Tier 2 (512M) | Identity management |
| oathkeeper | ? | Tier 2 (512M) | Decision proxy |
| keto | ? | Tier 2 (512M) | Permission checks |
| spicedb | ? | Tier 3 (1G) | Graph traversal |

## JVM-Based Services

Services using JVM need special consideration:

```yaml
environment:
  # Set JVM heap to ~50% of memory limit
  JAVA_OPTS: "-Xms512m -Xmx2g"
  # Or for newer JVMs
  JAVA_TOOL_OPTIONS: "-XX:MaxRAMPercentage=50.0"
```

**JVM Services**: elasticsearch, logstash, kibana, opensearch

## Files to Modify

### Phase 1
- `modules/db/postgres.yaml`
- `modules/db/qdrant.yaml`
- `modules/db/surrealdb.yaml`
- `modules/search/meilisearch.yaml`
- `modules/mcp/workflow/n8n.yaml`

### Phase 2
- `modules/mcp/docs/aws.yaml`
- `modules/mcp/docs/context7.yaml`
- `modules/mcp/global/aws-api.yaml`
- `modules/mcp/global/aws-cloudtrail.yaml`
- `modules/mcp/global/aws-core.yaml`
- `modules/mcp/global/aws-diagram.yaml`
- `modules/mcp/global/aws-terraform.yaml`
- `modules/mcp/global/terraform.yaml`
- `modules/mcp/notes/zettelkasten.yaml`
- `modules/mcp/observability/prometheus-server.yaml`
- `modules/mcp/project/filesystem.yaml`
- `modules/mcp/util/mcp-proxy.yaml`
- `modules/mcp/workflow/agent-mcp.yaml`

### Phase 3
- All 82 files with existing limits (audit)

### Phase 4
- `docs/DOCKER_PROFILES.md`
- `justfile` (add monitoring recipes)

## Validation

After implementation:

1. Run `docker compose config --quiet` to validate syntax
2. Deploy each profile and verify services start
3. Monitor for OOM kills: `dmesg | grep -i "killed process"`
4. Check for CPU throttling: `docker stats`
5. Run load tests on critical services

## Rollback Strategy

Keep original files:
```bash
# Before making changes
cp modules/db/postgres.yaml modules/db/postgres.yaml.bak

# To rollback
mv modules/db/postgres.yaml.bak modules/db/postgres.yaml
```

Or use git:
```bash
git checkout -- modules/db/postgres.yaml
```
