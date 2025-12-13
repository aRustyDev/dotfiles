# Plan: Extend Manifest to Track Infrastructure Profiles

## Status: Planned (Not Implemented)

## Overview

Extend the manifest tracking system to include infrastructure profile deployments,
providing a complete picture of what's deployed without requiring container labels.

## 1. Updated Manifest Schema

```json
{
  "infrastructure": {
    "core": {
      "deployed_at": "2025-12-10T19:40:10Z",
      "compose_file": "/Users/dev/.local/state/docker/core.yaml",
      "services": ["traefik", "postgres", "redis", "grafana", "loki", "mimir"]
    },
    "mcp": {
      "deployed_at": "2025-12-10T19:41:00Z",
      "compose_file": "/Users/dev/.local/state/docker/mcp.yaml",
      "services": ["github", "fetch", "dockerhub", "sequential-thinking"]
    },
    "o11y": {
      "deployed_at": "2025-12-10T19:42:00Z",
      "compose_file": "/Users/dev/.local/state/docker/o11y.yaml",
      "services": ["prometheus", "tempo", "jaeger"]
    }
  },
  "projects": {
    "53D043D8-8D06-4156-8FFA-4D02371B461A": {
      "profiles": "mcp-project,project-iac",
      "path": "/Users/dev/repos/my-terraform-project",
      "deployed_at": "2025-12-10T19:45:00Z",
      "compose_file": "/Users/dev/.local/state/docker/projects/53D043D8-...",
      "services": ["terraform", "aws-core", "filesystem"]
    }
  }
}
```

## 2. Changes to `deploy` Recipe

After deploying each infrastructure profile, add to manifest:

```bash
# For each infra profile deployed
services=$(docker compose -f "${outfile}" config --services | tr '\n' ',' | sed 's/,$//')
jq --arg profile "$p" \
   --arg ts "{{ timestamp }}" \
   --arg file "{{ docker_state }}/${p}.yaml" \
   --arg svcs "$services" \
   '.infrastructure[$profile] = {
       "deployed_at": $ts,
       "compose_file": $file,
       "services": ($svcs | split(","))
   }' "{{ docker_manifests_file }}" | {{ sponge }} "{{ docker_manifests_file }}"
```

## 3. Changes to `destroy` Recipe

Remove infrastructure profile from manifest when destroyed:

```bash
jq --arg profile "$p" 'del(.infrastructure[$profile])' "{{ docker_manifests_file }}" | {{ sponge }} "{{ docker_manifests_file }}"
```

## 4. New `list-docker-deployments` Recipe

```just
[group("docker")]
list-docker-deployments:
    @echo "Infrastructure:"
    @jq -r '.infrastructure | to_entries[] | "  \(.key): \(.value.services | length) services (\(.value.deployed_at))"' "{{ docker_manifests_file }}" 2>/dev/null || echo "  (none)"
    @echo ""
    @echo "Projects:"
    @jq -r '.projects | to_entries[] | "  \(.key | .[0:8])...: \(.value.path) [\(.value.profiles)]"' "{{ docker_manifests_file }}" 2>/dev/null || echo "  (none)"
```

## 5. Initialize Manifest with New Schema

Update `mktree` to create manifest with both keys:

```just
[ -f "{{ docker_manifests_file }}" ] || echo '{"infrastructure":{},"projects":{}}' > "{{ docker_manifests_file }}"
```

## 6. Migration for Existing Manifests

Add a one-time migration in `mktree`:

```bash
# Migrate old manifest format if needed
jq 'if .infrastructure == null then .infrastructure = {} else . end' "{{ docker_manifests_file }}" | {{ sponge }} "{{ docker_manifests_file }}"
```

## Files to Modify

| File | Changes |
|------|---------|
| `justfile` | `deploy`, `destroy`, `mktree`, add `list-docker-deployments` |
| `docs/DOCKER_PROFILES.md` | Update manifest schema documentation |

## Alternatives Considered

1. **Custom Labels on Services** - Rejected due to maintenance burden (100+ services)
2. **Query Docker Runtime** - Docker Compose doesn't store profile info in container labels
3. **This Approach** - Leverages existing manifest system, single source of truth
