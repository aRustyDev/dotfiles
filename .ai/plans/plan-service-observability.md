# Plan: Service Observability Instrumentation

## Status: Completed

## Overview

Implement comprehensive observability (metrics, traces, logs) for all Docker Compose
services with environment variable toggles to enable/disable each signal type.

## Design Principles

### Environment Variable Convention

Each service will support three environment variables to toggle observability:

```bash
# Global defaults (can be overridden per-service)
O11Y_METRICS_ENABLED=true    # Enable Prometheus metrics collection
O11Y_TRACING_ENABLED=true    # Enable distributed tracing (OpenTelemetry)
O11Y_LOGGING_ENABLED=true    # Enable structured log collection to Loki

# Per-service override pattern
<SERVICE>_METRICS_ENABLED=true
<SERVICE>_TRACING_ENABLED=true
<SERVICE>_LOGGING_ENABLED=true
```

### Implementation Pattern

For each service, we'll add:

1. **Metrics**: Prometheus exporter sidecar or native metrics endpoint
2. **Tracing**: OpenTelemetry instrumentation or auto-instrumentation via Beyla
3. **Logging**: JSON structured logging with Docker logging driver to Loki

### Logging Driver Configuration

```yaml
# Standard logging configuration for all services
x-logging: &default-logging
  driver: "${O11Y_LOGGING_DRIVER:-json-file}"
  options:
    max-size: "${O11Y_LOG_MAX_SIZE:-10m}"
    max-file: "${O11Y_LOG_MAX_FILES:-3}"
    tag: "{{.Name}}"

# Loki logging driver (when enabled)
x-loki-logging: &loki-logging
  driver: loki
  options:
    loki-url: "http://loki:3100/loki/api/v1/push"
    loki-batch-size: "400"
    loki-retries: "2"
    loki-max-backoff: "800ms"
    loki-timeout: "1s"
    loki-tenant-id: "docker"
    labels: "container_name,compose_project,compose_service"
```

## Service Categories & Implementation Strategy

### Category 1: Databases (High Priority)

Services that need exporter sidecars for metrics.

| Service | Metrics Strategy | Tracing Strategy | Logging Strategy |
|---------|-----------------|------------------|------------------|
| postgres | postgres_exporter sidecar | pg_tracing extension | JSON log format |
| mongo | mongodb_exporter sidecar | N/A (app-level) | JSON log format |
| redis | redis_exporter sidecar | N/A (app-level) | Built-in logs |
| valkey | redis_exporter sidecar | N/A (app-level) | Built-in logs |
| elasticsearch | Built-in /_prometheus/metrics | Elastic APM | Built-in JSON |
| qdrant | Built-in /metrics | N/A | Built-in logs |
| surrealdb | N/A (no metrics endpoint) | N/A | Built-in JSON |
| meilisearch | Built-in /metrics | N/A | JSON mode enabled |
| influxdb | Built-in /metrics | N/A | Built-in logs |
| falkordb | redis_exporter compatible | N/A | Built-in logs |

### Category 2: Auth Services (Medium Priority)

ORY stack services with native observability support.

| Service | Metrics Strategy | Tracing Strategy | Logging Strategy |
|---------|-----------------|------------------|------------------|
| hydra | Built-in /metrics | OpenTelemetry env vars | JSON (enabled) |
| kratos | Built-in /metrics | OpenTelemetry env vars | JSON (enabled) |
| oathkeeper | Built-in /metrics | OpenTelemetry env vars | JSON (enabled) |
| keto | Built-in /metrics | OpenTelemetry env vars | JSON (enabled) |
| spicedb | Built-in :9090/metrics | Native OTEL support | JSON format |

### Category 3: Infrastructure (High Priority)

Core infrastructure services.

| Service | Metrics Strategy | Tracing Strategy | Logging Strategy |
|---------|-----------------|------------------|------------------|
| traefik | Built-in /metrics | Native OTEL | Access logs + JSON |

### Category 4: MCP Servers (Low Priority - Many Services)

Lightweight MCP servers - use uniform approach.

| Strategy | Implementation |
|----------|----------------|
| Metrics | Beyla eBPF auto-instrumentation |
| Tracing | Beyla eBPF auto-instrumentation |
| Logging | Docker JSON driver → Loki |

### Category 5: Observability Stack (Already Instrumented)

These services are part of the LGTM stack and self-monitor.

| Service | Status |
|---------|--------|
| prometheus | Self-monitoring |
| loki | Self-monitoring |
| tempo | Self-monitoring |
| mimir | Self-monitoring |
| grafana | Self-monitoring |
| otel-collector | Self-monitoring |

---

## Implementation Phases

### Phase 1: Logging Infrastructure (Foundation)

**Goal**: Centralize all container logs to Loki

**Tasks**:
1. Create logging extension YAML fragment (`modules/core/logging.yaml`)
2. Add Loki Docker logging driver support
3. Create Promtail/Alloy config for log collection
4. Add environment variable toggles

**Files to Create/Modify**:
- `modules/core/logging.yaml` (new)
- `config/alloy/config.alloy` (new)
- `config/promtail/config.yaml` (new)

**Environment Variables**:
```bash
O11Y_LOGGING_ENABLED=true
O11Y_LOGGING_DRIVER=json-file  # or "loki"
O11Y_LOG_MAX_SIZE=10m
O11Y_LOG_MAX_FILES=3
```

### Phase 2: Database Exporters (Metrics)

**Goal**: Add Prometheus exporters for all databases

**Tasks**:
1. Create postgres_exporter sidecar service
2. Create mongodb_exporter sidecar service
3. Create redis_exporter sidecar service
4. Enable built-in metrics for services that support it
5. Add scrape configs to Prometheus

**Files to Create/Modify**:
- `modules/db/postgres.yaml` - Add exporter sidecar
- `modules/db/mongo.yaml` - Add exporter sidecar
- `modules/db/redis.yaml` - Add exporter sidecar
- `modules/db/valkey.yaml` - Add exporter sidecar
- `modules/db/elasticsearch.yaml` - Enable metrics endpoint
- `modules/db/qdrant.yaml` - Enable metrics endpoint
- `modules/search/meilisearch.yaml` - Enable metrics endpoint
- `config/prometheus/prometheus.yml` - Add scrape configs

**New Services**:
```yaml
# Example: postgres_exporter
postgres-exporter:
  image: prometheuscommunity/postgres-exporter:v0.15.0
  profiles: ["${O11Y_METRICS_ENABLED:-true}" == "true" ? "o11y" : "disabled"]
  environment:
    DATA_SOURCE_NAME: "postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres:5432/postgres?sslmode=disable"
```

### Phase 3: Auth Service Observability

**Goal**: Enable native observability in ORY stack and SpiceDB

**Tasks**:
1. Add OpenTelemetry environment variables to ORY services
2. Enable metrics endpoints
3. Configure SpiceDB OTEL provider
4. Add scrape configs to Prometheus

**Files to Modify**:
- `modules/authn/hydra.yaml`
- `modules/authn/kratos.yaml`
- `modules/authn/oathkeeper.yaml`
- `modules/authz/keto.yaml`
- `modules/authz/spicedb.yaml`
- `config/prometheus/prometheus.yml`

**Environment Variables for ORY Services**:
```yaml
environment:
  # Metrics (all ORY services expose /metrics by default)
  SERVE_ADMIN_METRICS_PORT: "4471"

  # Tracing
  TRACING_PROVIDER: "${O11Y_TRACING_ENABLED:-true}" == "true" ? "otel" : "none"
  TRACING_PROVIDERS_OTLP_ENDPOINT: "otel-collector:4317"
  TRACING_PROVIDERS_OTLP_INSECURE: "true"
  TRACING_SERVICE_NAME: "hydra"
```

### Phase 4: Beyla Auto-Instrumentation

**Goal**: Automatic metrics and tracing for MCP servers and other services

**Tasks**:
1. Deploy Grafana Beyla as a privileged container
2. Configure target process discovery
3. Add to observability profile

**Files to Create/Modify**:
- `modules/observability/beyla.yaml` (enhance existing)
- `config/beyla/config.yaml` (new)

**Beyla Configuration**:
```yaml
# Beyla auto-instruments HTTP/gRPC services via eBPF
beyla:
  image: grafana/beyla:1.6
  privileged: true
  pid: host
  environment:
    BEYLA_OPEN_PORT: "80,443,3000-9999"
    BEYLA_PROMETHEUS_PORT: "9400"
    OTEL_EXPORTER_OTLP_ENDPOINT: "http://otel-collector:4317"
```

### Phase 5: Traefik Observability

**Goal**: Full observability for the ingress layer

**Tasks**:
1. Enable Traefik metrics endpoint
2. Enable Traefik access logs
3. Enable Traefik tracing to Tempo

**Files to Modify**:
- `config/traefik/traefik.yaml`
- `modules/core/traefik.yaml` (if exists)

**Traefik Configuration**:
```yaml
# traefik.yaml additions
metrics:
  prometheus:
    addEntryPointsLabels: true
    addRoutersLabels: true
    addServicesLabels: true
    entryPoint: metrics

tracing:
  otlp:
    grpc:
      endpoint: "otel-collector:4317"
      insecure: true

accessLog:
  format: json
  filters:
    statusCodes:
      - "200-599"
```

### Phase 6: MCP Server Logging

**Goal**: Structured logging for all MCP servers

**Tasks**:
1. Add logging configuration to all MCP services
2. Ensure JSON log format where possible
3. Add service labels for log filtering

**Pattern for MCP Services**:
```yaml
services:
  mcp-example:
    logging:
      driver: "${O11Y_LOGGING_DRIVER:-json-file}"
      options:
        max-size: "10m"
        max-file: "3"
        tag: "{{.Name}}"
        labels: "com.docker.compose.service"
    labels:
      prometheus.scrape: "${O11Y_METRICS_ENABLED:-false}"
      prometheus.port: "8080"
      prometheus.path: "/metrics"
```

### Phase 7: Grafana Dashboards

**Goal**: Pre-configured dashboards for all services

**Tasks**:
1. Create dashboard provisioning structure
2. Add database dashboards (PostgreSQL, Redis, MongoDB)
3. Add auth service dashboards
4. Add infrastructure dashboards
5. Add service overview dashboard

**Files to Create**:
- `config/grafana/provisioning/dashboards/dashboards.yaml`
- `config/grafana/dashboards/databases.json`
- `config/grafana/dashboards/auth-services.json`
- `config/grafana/dashboards/infrastructure.json`
- `config/grafana/dashboards/service-overview.json`

---

## Service-by-Service Implementation Details

### PostgreSQL

```yaml
# modules/db/postgres.yaml additions
services:
  postgres:
    environment:
      # Enable query logging for observability
      POSTGRES_INITDB_ARGS: "--data-checksums"
    command:
      - postgres
      - -c
      - log_statement=${POSTGRES_LOG_STATEMENT:-none}
      - -c
      - log_min_duration_statement=${POSTGRES_LOG_MIN_DURATION:-1000}
      - -c
      - log_destination=stderr
      - -c
      - logging_collector=off
    logging: *default-logging

  # Metrics exporter sidecar
  postgres-exporter:
    image: prometheuscommunity/postgres-exporter:v0.15.0
    container_name: postgres-exporter
    profiles: ["o11y-metrics", "o11y"]
    networks:
      - data-tier
      - backend
    environment:
      DATA_SOURCE_NAME: "postgresql://${POSTGRES_USER:-postgres}:${POSTGRES_PASSWORD}@postgres:5432/postgres?sslmode=disable"
    expose:
      - "9187"
    depends_on:
      postgres:
        condition: service_healthy
    deploy:
      resources:
        limits:
          cpus: "0.25"
          memory: 128M
        reservations:
          cpus: "0.05"
          memory: 32M
```

### MongoDB

```yaml
# modules/db/mongo.yaml additions
services:
  mongodb-exporter:
    image: percona/mongodb_exporter:0.40
    container_name: mongodb-exporter
    profiles: ["o11y-metrics", "o11y"]
    networks:
      - data-tier
      - backend
    environment:
      MONGODB_URI: "mongodb://${MONGO_INITDB_ROOT_USERNAME}:${MONGO_INITDB_ROOT_PASSWORD}@mongo:27017/admin"
    command:
      - --collect-all
      - --compatible-mode
    expose:
      - "9216"
    depends_on:
      mongo:
        condition: service_healthy
    deploy:
      resources:
        limits:
          cpus: "0.25"
          memory: 128M
```

### Redis/Valkey

```yaml
# modules/db/redis.yaml additions
services:
  redis-exporter:
    image: oliver006/redis_exporter:v1.58.0
    container_name: redis-exporter
    profiles: ["o11y-metrics", "o11y"]
    networks:
      - data-tier
      - backend
    environment:
      REDIS_ADDR: "redis://redis:6379"
      REDIS_PASSWORD: "${REDIS_PASSWORD}"
    expose:
      - "9121"
    depends_on:
      redis:
        condition: service_healthy
    deploy:
      resources:
        limits:
          cpus: "0.25"
          memory: 64M
```

### ORY Hydra (Pattern for all ORY services)

```yaml
# modules/authn/hydra.yaml additions
services:
  hydra:
    environment:
      # Existing environment variables...

      # Metrics
      SERVE_ADMIN_HOST: "0.0.0.0"
      SERVE_ADMIN_PORT: "4445"

      # Tracing (conditional on O11Y_TRACING_ENABLED)
      TRACING_PROVIDER: "${HYDRA_TRACING_PROVIDER:-${O11Y_TRACING_ENABLED:+otel}}"
      TRACING_PROVIDERS_OTLP_ENDPOINT: "${OTEL_COLLECTOR_ENDPOINT:-otel-collector:4317}"
      TRACING_PROVIDERS_OTLP_INSECURE: "true"
      TRACING_SERVICE_NAME: "hydra"

      # Logging
      LOG_LEVEL: "${HYDRA_LOG_LEVEL:-info}"
      LOG_FORMAT: "json"
      LOG_LEAK_SENSITIVE_VALUES: "false"

    logging: *default-logging

    labels:
      prometheus.scrape: "true"
      prometheus.port: "4445"
      prometheus.path: "/admin/metrics/prometheus"
```

### SpiceDB

```yaml
# modules/authz/spicedb.yaml additions
services:
  spicedb:
    environment:
      # Metrics (always enabled, port 9090)
      SPICEDB_GRPC_PRESHARED_KEY: "${SPICEDB_PRESHARED_KEY}"

      # Tracing
      SPICEDB_OTEL_PROVIDER: "${SPICEDB_TRACING_PROVIDER:-${O11Y_TRACING_ENABLED:+otlpgrpc}}"
      SPICEDB_OTEL_ENDPOINT: "${OTEL_COLLECTOR_ENDPOINT:-otel-collector:4317}"
      SPICEDB_OTEL_INSECURE: "true"
      SPICEDB_OTEL_SERVICE_NAME: "spicedb"

      # Logging
      SPICEDB_LOG_LEVEL: "${SPICEDB_LOG_LEVEL:-info}"
      SPICEDB_LOG_FORMAT: "json"

    logging: *default-logging

    labels:
      prometheus.scrape: "true"
      prometheus.port: "9090"
      prometheus.path: "/metrics"
```

---

## Prometheus Scrape Configuration

```yaml
# config/prometheus/prometheus.yml additions
scrape_configs:
  # Database Exporters
  - job_name: 'postgres'
    static_configs:
      - targets: ['postgres-exporter:9187']
        labels:
          service: 'postgres'

  - job_name: 'mongodb'
    static_configs:
      - targets: ['mongodb-exporter:9216']
        labels:
          service: 'mongodb'

  - job_name: 'redis'
    static_configs:
      - targets: ['redis-exporter:9121']
        labels:
          service: 'redis'

  # Auth Services (ORY Stack)
  - job_name: 'ory-hydra'
    static_configs:
      - targets: ['hydra:4445']
        labels:
          service: 'hydra'
    metrics_path: '/admin/metrics/prometheus'

  - job_name: 'ory-kratos'
    static_configs:
      - targets: ['kratos:4434']
        labels:
          service: 'kratos'
    metrics_path: '/admin/metrics/prometheus'

  - job_name: 'ory-oathkeeper'
    static_configs:
      - targets: ['oathkeeper:4456']
        labels:
          service: 'oathkeeper'
    metrics_path: '/metrics'

  - job_name: 'ory-keto'
    static_configs:
      - targets: ['keto:4467']
        labels:
          service: 'keto'
    metrics_path: '/metrics'

  - job_name: 'spicedb'
    static_configs:
      - targets: ['spicedb:9090']
        labels:
          service: 'spicedb'

  # Infrastructure
  - job_name: 'traefik'
    static_configs:
      - targets: ['traefik:8080']
        labels:
          service: 'traefik'
    metrics_path: '/metrics'

  # Beyla Auto-instrumentation
  - job_name: 'beyla'
    static_configs:
      - targets: ['beyla:9400']
        labels:
          service: 'beyla'

  # Database Native Metrics
  - job_name: 'elasticsearch'
    static_configs:
      - targets: ['elasticsearch:9200']
        labels:
          service: 'elasticsearch'
    metrics_path: '/_prometheus/metrics'

  - job_name: 'qdrant'
    static_configs:
      - targets: ['qdrant:6333']
        labels:
          service: 'qdrant'
    metrics_path: '/metrics'

  - job_name: 'meilisearch'
    static_configs:
      - targets: ['meilisearch:7700']
        labels:
          service: 'meilisearch'
    metrics_path: '/metrics'
```

---

## Environment Variables Summary

### Global Toggles

| Variable | Default | Description |
|----------|---------|-------------|
| `O11Y_METRICS_ENABLED` | `true` | Enable/disable metrics collection |
| `O11Y_TRACING_ENABLED` | `true` | Enable/disable distributed tracing |
| `O11Y_LOGGING_ENABLED` | `true` | Enable/disable structured logging |
| `O11Y_LOGGING_DRIVER` | `json-file` | Docker logging driver (`json-file` or `loki`) |
| `O11Y_LOG_MAX_SIZE` | `10m` | Max log file size |
| `O11Y_LOG_MAX_FILES` | `3` | Max number of log files |
| `OTEL_COLLECTOR_ENDPOINT` | `otel-collector:4317` | OpenTelemetry Collector gRPC endpoint |

### Per-Service Overrides

| Pattern | Example | Description |
|---------|---------|-------------|
| `<SERVICE>_METRICS_ENABLED` | `POSTGRES_METRICS_ENABLED=false` | Disable metrics for specific service |
| `<SERVICE>_TRACING_ENABLED` | `HYDRA_TRACING_ENABLED=false` | Disable tracing for specific service |
| `<SERVICE>_LOG_LEVEL` | `KRATOS_LOG_LEVEL=debug` | Set log level for specific service |

---

## Files to Create/Modify

### New Files

| File | Purpose |
|------|---------|
| `modules/core/logging.yaml` | YAML extensions for logging |
| `modules/db/exporters.yaml` | Database exporter sidecars |
| `config/alloy/config.alloy` | Grafana Alloy log collection |
| `config/beyla/config.yaml` | Beyla auto-instrumentation |
| `config/grafana/provisioning/dashboards/dashboards.yaml` | Dashboard provisioning |
| `config/grafana/dashboards/*.json` | Pre-built dashboards |

### Modified Files

| File | Changes |
|------|---------|
| `modules/db/postgres.yaml` | Add logging, exporter reference |
| `modules/db/mongo.yaml` | Add logging, exporter reference |
| `modules/db/redis.yaml` | Add logging, exporter reference |
| `modules/db/valkey.yaml` | Add logging, exporter reference |
| `modules/db/elasticsearch.yaml` | Enable metrics endpoint |
| `modules/db/qdrant.yaml` | Add logging |
| `modules/search/meilisearch.yaml` | Add logging |
| `modules/authn/hydra.yaml` | Add tracing env vars |
| `modules/authn/kratos.yaml` | Add tracing env vars |
| `modules/authn/oathkeeper.yaml` | Add tracing env vars |
| `modules/authz/keto.yaml` | Add tracing env vars |
| `modules/authz/spicedb.yaml` | Enable OTEL tracing |
| `modules/mcp/**/*.yaml` | Add logging configuration |
| `config/prometheus/prometheus.yml` | Add scrape configs |
| `config/traefik/traefik.yaml` | Enable metrics and tracing |

---

## Validation Checklist

After implementation, verify:

- [ ] All services produce structured JSON logs
- [ ] Logs appear in Grafana Loki
- [ ] Database metrics appear in Grafana (PostgreSQL, Redis, MongoDB dashboards)
- [ ] Auth service metrics appear in Grafana
- [ ] Traces flow through to Tempo
- [ ] Service map shows topology in Grafana
- [ ] Environment variable toggles work (disable and verify)
- [ ] Resource usage is acceptable with observability enabled

---

## Rollback Strategy

Each phase can be rolled back independently:

1. **Logging**: Remove `logging:` sections, revert to default driver
2. **Exporters**: Stop exporter containers, remove from compose files
3. **Tracing**: Set `*_TRACING_ENABLED=false` or `TRACING_PROVIDER=none`
4. **Dashboards**: Remove dashboard JSON files

Use git to track changes:
```bash
git checkout -- modules/db/postgres.yaml  # Rollback single file
git checkout -- modules/                   # Rollback all module changes
```
