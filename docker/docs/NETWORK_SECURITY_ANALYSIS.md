# Network Security Analysis & Recommendations

This document analyzes the current Docker Compose configurations and provides recommendations for improving network security through proper port exposure and network segmentation.

## Executive Summary

**Key Findings:**
1. **~50+ services** expose ports to the host unnecessarily
2. **Most services behind Traefik** don't need host port mappings
3. **Current network topology is flat** - most services share `traefik-public`
4. **Defense-in-depth opportunities** exist through network segmentation

**Recommendation:** Convert host `ports:` to `expose:` for services accessed only via Traefik, and implement tiered network architecture.

## Understanding `ports:` vs `expose:`

| Directive | Behavior | Security |
|-----------|----------|----------|
| `ports: "8080:8080"` | Binds to host interface, accessible from outside | Less secure |
| `expose: ["8080"]` | Only accessible within Docker networks | More secure |

**Rule of Thumb:** If a service is accessed via Traefik (reverse proxy), it should use `expose:` not `ports:`.

---

## Port Analysis by Category

### 1. MUST Keep as `ports:` (External Access Required)

These services need direct host access:

| Service | File | Port | Reason |
|---------|------|------|--------|
| **Traefik** | `ingress/traefik.yaml` | 80, 443 | Reverse proxy entry point |
| **PostgreSQL** | `db/postgres.yaml` | 5432 | Direct DB client access (optional) |
| **Supabase Pooler** | `db/supabase.yaml` | 5432, 6543 | Direct DB client access |

### 2. SHOULD Convert to `expose:` (Traefik-Proxied Services)

These services are accessed via Traefik and don't need host port bindings:

#### MCP Services (~40 services)

| Service | Current Port | Action |
|---------|--------------|--------|
| graphiti | 8000 | `expose: ["8000"]` |
| context7 | 8210 | `expose: ["8080"]` |
| sequential-thinking | 8212 | `expose: ["8080"]` |
| github | 8213 | `expose: ["8080"]` |
| gitlab | 8214 | `expose: ["8080"]` |
| meilisearch-mcp | 8217 | `expose: ["8080"]` |
| arxiv | 8219 | `expose: ["8080"]` |
| paper-search | 8221 | `expose: ["8080"]` |
| bruno | 8221 | `expose: ["8080"]` |
| char-index | 8222 | `expose: ["8080"]` |
| astro-docs | 8224 | `expose: ["8080"]` |
| cloudflare-docs | 8225 | `expose: ["8080"]` |
| prometheus-mcp | 8225 | `expose: ["8080"]` |
| crate-docs | 8226 | `expose: ["8080"]` |
| rust-docs | 8227 | `expose: ["8080"]` |
| freecad | 8230 | `expose: ["8080"]` |
| filescope | 8231 | `expose: ["8080"]` |
| kicad | 8232 | `expose: ["8080"]` |
| obsidian | varies | `expose: ["8080"]` |
| zettelkasten | varies | `expose: ["8080"]` |
| duckduckgo | varies | `expose: ["8080"]` |
| time | varies | `expose: ["8080"]` |
| dockerhub | varies | `expose: ["8080"]` |
| fetch | varies | `expose: ["8080"]` |
| ... | ... | ... |

#### Database Services

| Service | Current Port | Recommendation |
|---------|--------------|----------------|
| FalkorDB | 6379, 3000 | `expose:` - access via Traefik |
| Meilisearch | 7700 | `expose:` - access via Traefik |
| SurrealDB | 8000 | `expose:` - access via Traefik |
| Qdrant | 6333, 6334 | `expose:` - access via Traefik |
| Redis/Valkey | 6379 | `expose:` unless direct client needed |
| MongoDB | 27017 | `expose:` unless direct client needed |

#### Auth Services

| Service | Current Port | Recommendation |
|---------|--------------|----------------|
| Hydra Public | 4444 | `expose:` - via Traefik |
| Hydra Admin | 4445 | `expose:` - via Traefik |
| Kratos Public | 4433 | `expose:` - via Traefik |
| Kratos Admin | 4434 | `expose:` - via Traefik |
| Oathkeeper | 4455, 4456 | `expose:` - via Traefik |
| Keto Read | 4466 | `expose:` - via Traefik |
| Keto Write | 4467 | `expose:` - via Traefik |
| SpiceDB HTTP | 8443 | `expose:` - via Traefik |
| SpiceDB gRPC | 50051 | **Keep `ports:`** if direct gRPC needed |

#### Workflow Services

| Service | Current Port | Recommendation |
|---------|--------------|----------------|
| n8n | 5678 | `expose:` - access via Traefik |

#### Supabase Stack

| Service | Current Port | Recommendation |
|---------|--------------|----------------|
| Kong | 8000, 8443 | `expose:` - via Traefik |
| Analytics | 4000 | `expose:` - internal only |
| Studio | 3000 | `expose:` - via Traefik |

### 3. Services That Need Special Consideration

| Service | Port | Notes |
|---------|------|-------|
| **Ollama** | 11434 | Keep `ports:` if non-Docker clients need access |
| **SpiceDB gRPC** | 50051 | Keep `ports:` for gRPC clients (zed, SDKs) |
| **Keto gRPC** | 4468, 4469 | Keep `ports:` if using gRPC clients |
| **Mailslurper** | 1025, 4437 | Dev only - `expose:` with Traefik UI route |

---

## Current Network Topology

```
┌─────────────────────────────────────────────────────────────┐
│                     traefik-public                          │
│  (FLAT - almost all services share this single network)     │
├─────────────────────────────────────────────────────────────┤
│ traefik, postgres, falkordb, meilisearch, graphiti,        │
│ n8n, ollama, ~40 MCP services, hydra, kratos,              │
│ oathkeeper, keto, spicedb, supabase-*, ...                 │
└─────────────────────────────────────────────────────────────┘

┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│      n8n        │  │ supabase-internal│  │     authz       │
│ (postgres, n8n) │  │ (supabase stack)│  │ (spicedb, keto) │
└─────────────────┘  └─────────────────┘  └─────────────────┘

┌─────────────────┐
│     authn       │
│ (hydra, kratos, │
│   oathkeeper)   │
└─────────────────┘

Problem: Even with separate networks, most services still join traefik-public,
creating a flat topology where any compromised service can reach others.
```

---

## Recommended Defense-in-Depth Network Architecture

### Tiered Network Design

```
                            ┌──────────────┐
                            │   INTERNET   │
                            └──────┬───────┘
                                   │
                            ┌──────▼───────┐
                            │   Traefik    │
                            │  (DMZ Tier)  │
                            └──────┬───────┘
                                   │
        ┌──────────────────────────┼──────────────────────────┐
        │                          │                          │
┌───────▼───────┐          ┌───────▼───────┐          ┌───────▼───────┐
│  frontend     │          │   backend     │          │    admin      │
│   network     │          │   network     │          │   network     │
├───────────────┤          ├───────────────┤          ├───────────────┤
│ - n8n UI      │          │ - MCP servers │          │ - Auth admin  │
│ - Supabase UI │          │ - API services│          │ - DB admin UI │
│ - Dashboards  │          │ - Workers     │          │ - Monitoring  │
└───────┬───────┘          └───────┬───────┘          └───────┬───────┘
        │                          │                          │
        └──────────────────────────┼──────────────────────────┘
                                   │
                    ┌──────────────┼──────────────┐
                    │              │              │
            ┌───────▼───────┐ ┌───▼────┐ ┌───────▼───────┐
            │   data-tier   │ │ authn  │ │    authz      │
            │   network     │ │network │ │   network     │
            ├───────────────┤ ├────────┤ ├───────────────┤
            │ - PostgreSQL  │ │- Kratos│ │ - SpiceDB     │
            │ - Redis       │ │- Hydra │ │ - Keto        │
            │ - FalkorDB    │ │- OIDC  │ │ - Permissions │
            └───────────────┘ └────────┘ └───────────────┘
```

### Network Definitions

```yaml
networks:
  # Tier 1: DMZ / Edge
  dmz:
    driver: bridge
    internal: false  # Can reach internet
    ipam:
      config:
        - subnet: 172.20.0.0/24

  # Tier 2: Application Networks
  frontend:
    driver: bridge
    internal: true   # No direct internet
    ipam:
      config:
        - subnet: 172.21.0.0/24

  backend:
    driver: bridge
    internal: true
    ipam:
      config:
        - subnet: 172.22.0.0/24

  admin:
    driver: bridge
    internal: true
    ipam:
      config:
        - subnet: 172.23.0.0/24

  # Tier 3: Data / Security Networks
  data-tier:
    driver: bridge
    internal: true
    ipam:
      config:
        - subnet: 172.24.0.0/24

  authn:
    driver: bridge
    internal: true
    ipam:
      config:
        - subnet: 172.25.0.0/24

  authz:
    driver: bridge
    internal: true
    ipam:
      config:
        - subnet: 172.26.0.0/24

  # MCP-specific networks (optional granularity)
  mcp-docs:
    driver: bridge
    internal: true

  mcp-tools:
    driver: bridge
    internal: true

  mcp-git:
    driver: bridge
    internal: true
```

### Service-to-Network Mapping

| Service Category | Networks | Notes |
|------------------|----------|-------|
| **Traefik** | dmz | Only service with external access |
| **UI Services** (n8n, Studio, dashboards) | frontend, dmz | Traefik routes to frontend |
| **MCP Servers** | backend, dmz | Traefik routes to backend |
| **API Services** | backend, dmz | Traefik routes to backend |
| **Auth Public** (Kratos, Hydra public) | authn, dmz | User-facing auth |
| **Auth Admin** (Kratos, Hydra admin) | authn, admin | Admin-only access |
| **Databases** | data-tier | No direct external access |
| **Authorization** (SpiceDB, Keto) | authz, backend | Backend services query authz |

### Example: Secured PostgreSQL

```yaml
services:
  postgres:
    image: postgres:16-alpine
    networks:
      - data-tier        # Internal data network
      # NOT in dmz or traefik-public
    expose:
      - "5432"           # Not ports:
    # Remove direct port binding for security
    # Access via pgAdmin in admin network, or SSH tunnel
```

### Example: Secured MCP Service

```yaml
services:
  github-mcp:
    image: github-mcp:http
    networks:
      - backend          # MCP services network
      - dmz              # For Traefik routing only
    expose:
      - "8080"           # Not ports:
    labels:
      traefik.enable: true
      traefik.docker.network: dmz
```

---

## Implementation Checklist

### Phase 1: Convert Ports to Expose (Low Risk)

- [ ] Update all MCP services to use `expose:` instead of `ports:`
- [ ] Update auth services (keep gRPC ports if needed)
- [ ] Update database UIs (FalkorDB browser, etc.)
- [ ] Test Traefik routing still works

### Phase 2: Network Segmentation (Medium Risk)

- [ ] Create new network definitions
- [ ] Update Traefik to connect to dmz + each tier
- [ ] Migrate services one category at a time
- [ ] Update inter-service DNS references

### Phase 3: Access Controls (Advanced)

- [ ] Add network policies (if using Docker Swarm or Kubernetes)
- [ ] Implement service mesh (optional)
- [ ] Add firewall rules between networks

---

## Quick Reference: Conversion Examples

### Before (Insecure)
```yaml
services:
  myservice:
    ports:
      - "8080:8080"
    networks:
      - traefik-public
```

### After (Secure)
```yaml
services:
  myservice:
    expose:
      - "8080"
    networks:
      - backend
      - dmz
    labels:
      traefik.enable: true
      traefik.docker.network: dmz
```

---

## Services That Should Keep `ports:`

Only these services have legitimate reasons for host port bindings:

1. **Traefik** (80, 443) - Entry point
2. **PostgreSQL** (5432) - Only if direct psql/pgAdmin access needed from host
3. **SpiceDB gRPC** (50051) - If using gRPC SDKs from host
4. **Keto gRPC** (4468, 4469) - If using gRPC SDKs from host
5. **Ollama** (11434) - If non-Docker clients need access
6. **Development tools** - When debugging locally

Everything else should use `expose:` and be accessed through Traefik.

---

## Security Benefits

1. **Reduced Attack Surface**: No unnecessary ports exposed to host/network
2. **Network Isolation**: Compromised service can't reach unrelated services
3. **Centralized Access Control**: All traffic flows through Traefik
4. **Audit Trail**: Traefik access logs capture all requests
5. **TLS Termination**: All external traffic encrypted via Traefik
6. **Rate Limiting**: Apply at Traefik layer
7. **Authentication**: Oathkeeper/ForwardAuth at edge

---

## References

- [Docker Networking Documentation](https://docs.docker.com/network/)
- [Traefik Docker Provider](https://doc.traefik.io/traefik/providers/docker/)
- [Docker Compose Networking](https://docs.docker.com/compose/networking/)
- [OWASP Docker Security](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html)
