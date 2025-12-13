# Convert Traefik Labels to File Provider

Convert the docker-compose file at `$ARGUMENTS` from label-based Traefik configuration to file provider configuration.

## Steps

1. **Read the source docker-compose file** and extract:
   - Container name (used as service name in Traefik)
   - Service port from `traefik.http.services.*.loadbalancer.server.port` label
   - Router rules from `traefik.http.routers.*.rule` labels
   - Any parentRefs from `traefik.http.routers.*.parentRefs` labels

2. **Create Traefik dynamic config** at `/Users/arustydev/repos/configs/dotfiles/docker/config/traefik/dynamic/svc.mcp.<service-name>.yaml` following this template:

```yaml
# =============================================================================
# <Service Name> MCP Server - Traefik Routing Configuration
# =============================================================================
# Multi-layer routing with parentRefs (Traefik v3.6+)
#
# Routing hierarchy:
#   tools@file (root)    -> Host(`tool.localhost`)
#     └── mcp@file       -> PathPrefix(`/mcp`)
#           └── <name>   -> Header(`X-Service`, `<name>`) [THIS FILE]
#
# Container: <container_name> (<image>)
#   - MCP endpoint: port <port>
# =============================================================================

http:
  routers:
    # Leaf router for <Service Name> MCP server
    # Matches: Host(tool.localhost) && PathPrefix(/mcp) && Header(X-Service: <name>)
    <name>:
      rule: "Header(`X-Service`, `<name>`)"
      service: <name>
      parentRefs:
        - mcp@file
        - tools@file

    # Health check router
    # Matches: Host(tool.localhost) && PathPrefix(/health) && Header(X-Service: <name>)
    <name>-health:
      rule: "Header(`X-Service`, `<name>`)"
      service: <name>
      parentRefs:
        - health@file
        - tools@file

  services:
    <name>:
      loadBalancer:
        servers:
          - url: "http://<container_name>:<port>"
```

3. **Update the docker-compose file**:
   - Add `networks: - traefik-public` if not present
   - Replace all Traefik labels with:
```yaml
    labels:
      # =======================================================================
      # Traefik Configuration - Streamable HTTP MCP
      # =======================================================================
      # NOTE: Routing is defined in file provider (svc.mcp.<service-name>.yaml)
      # because parentRefs (multi-layer routing) is not supported in Docker labels.
      # =======================================================================
      traefik.enable: true
      traefik.docker.network: traefik-public
```

## Reference Files

- Example Traefik config: `/Users/arustydev/repos/configs/dotfiles/docker/config/traefik/dynamic/svc.mcp.github.yaml`
- Example docker-compose: `/Users/arustydev/repos/configs/dotfiles/docker/modules/mcp/global/fetch.yaml`
