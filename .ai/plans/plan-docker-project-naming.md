# Plan: Docker Compose Project Naming for Docker Desktop Grouping

## Status: Draft

## Overview

Control Docker Desktop container grouping by using the `--project-name` (`-p`) flag
with docker compose. This allows containers to be visually grouped in Docker Desktop
by profile or workspace.

## Goal

Docker Desktop shows containers collapsed under project names:

```
▼ core (5 containers)
    traefik, postgres, redis, grafana, loki

▼ mcp (20 containers)
    github, fetch, dockerhub, sequential-thinking...

▼ o11y (8 containers)
    prometheus, tempo, jaeger...

▼ myworkspace-project-iac (3 containers)
    terraform, aws-core, filesystem
```

Or with workspace prefix:

```
▼ homelab-core (5 containers)
▼ homelab-mcp (20 containers)
▼ homelab-o11y (8 containers)
▼ homelab-project-iac (3 containers)
```

## Implementation

### 1. Add Workspace Variable to Justfile

```just
# Docker workspace name (optional prefix for project names)
# Set via: DOCKER_WORKSPACE=homelab just deploy core,mcp
docker_workspace := env("DOCKER_WORKSPACE", "")

# Generate project name: "<workspace>-<profile>" or just "<profile>"
# This is a helper function pattern since justfile doesn't have functions
```

### 2. Update `gen-infra-compose` Recipe

No changes needed - template generation stays the same.

### 3. Update `deploy` Recipe

```just
deploy profiles="core": mktree
    #!/usr/bin/env bash
    set -euo pipefail

    # Categorize profiles
    eval $(just -f "{{ justfile() }}" categorize-profiles "{{ profiles }}")

    # Determine project name prefix
    workspace="{{ docker_workspace }}"

    # Generate and deploy infrastructure profiles
    if [[ -n "$INFRA" ]]; then
        just -f "{{ justfile() }}" gen-infra-compose "$INFRA"
        for p in $(echo "$INFRA" | tr ',' ' '); do
            [[ -z "$p" ]] && continue

            # Build project name
            if [[ -n "$workspace" ]]; then
                project_name="${workspace}-${p}"
            else
                project_name="$p"
            fi

            echo "Deploying infrastructure profile: $p (project: $project_name)"
            op inject -i "{{ docker_state }}/${p}.yaml" | docker compose -p "$project_name" -f - up -d
        done
    fi

    # Generate and deploy project-scoped profiles
    if [[ -n "$PROJECT" ]]; then
        just -f "{{ justfile() }}" gen-project-compose "$PROJECT"

        # Build project name for project-scoped deploys
        if [[ -n "$workspace" ]]; then
            project_name="${workspace}-{{ project_id }}"
        else
            # Use short UUID for cleaner display
            project_name="project-${project_id:0:8}"
        fi

        echo "Deploying project profile: {{ project_id }} (project: $project_name)"
        op inject -i "{{ project_state }}" | docker compose -p "$project_name" -f - up -d

        # Update manifest with project name
        jq '.projects["{{ project_id }}"] = {
               "profiles": "{{ profiles }}",
               "path": "{{ project_path }}",
               "deployed_at": "{{ timestamp }}",
               "compose_file": "{{ project_state }}",
               "docker_project": "'"$project_name"'"
           }' "{{ docker_manifests_file }}" | {{ sponge }} "{{ docker_manifests_file }}"
    fi

    echo "✓ Deployment complete"
```

### 4. Update `destroy` Recipe

```just
destroy profiles="core":
    #!/usr/bin/env bash
    set -euo pipefail

    eval $(just -f "{{ justfile() }}" categorize-profiles "{{ profiles }}")

    workspace="{{ docker_workspace }}"

    # Destroy project-scoped services first
    if [[ -n "$PROJECT" ]]; then
        if [[ -n "{{ project_id }}" ]] && [[ -f "{{ project_state }}" ]]; then
            # Get project name from manifest or reconstruct
            stored_project=$(jq -r '.projects["{{ project_id }}"].docker_project // empty' "{{ docker_manifests_file }}")
            if [[ -n "$stored_project" ]]; then
                project_name="$stored_project"
            elif [[ -n "$workspace" ]]; then
                project_name="${workspace}-{{ project_id }}"
            else
                project_name="project-${project_id:0:8}"
            fi

            echo "Destroying project services: {{ project_id }} (project: $project_name)"
            op inject -i "{{ project_state }}" | docker compose -p "$project_name" -f - down
            jq 'del(.projects["{{ project_id }}"])' "{{ docker_manifests_file }}" | {{ sponge }} "{{ docker_manifests_file }}"
        else
            echo "WARN: No project compose file found for current directory"
        fi
    fi

    # Destroy infrastructure services
    if [[ -n "$INFRA" ]]; then
        for p in $(echo "$INFRA" | tr ',' ' '); do
            [[ -z "$p" ]] && continue
            if [[ -f "{{ docker_state }}/${p}.yaml" ]]; then
                if [[ -n "$workspace" ]]; then
                    project_name="${workspace}-${p}"
                else
                    project_name="$p"
                fi

                echo "Destroying infrastructure profile: $p (project: $project_name)"
                op inject -i "{{ docker_state }}/${p}.yaml" | docker compose -p "$project_name" -f - down
            else
                echo "WARN: No compose file found for profile: $p"
            fi
        done
    fi

    echo "✓ Destroy complete"
```

### 5. Update `build` Recipe

Same pattern - add `-p "$project_name"` to docker compose commands.

### 6. Update `destroy-project` Recipe

```just
destroy-project:
    #!/usr/bin/env bash
    set -euo pipefail

    if [[ -f "{{ project_state }}" ]]; then
        workspace="{{ docker_workspace }}"

        # Get project name from manifest or reconstruct
        stored_project=$(jq -r '.projects["{{ project_id }}"].docker_project // empty' "{{ docker_manifests_file }}")
        if [[ -n "$stored_project" ]]; then
            project_name="$stored_project"
        elif [[ -n "$workspace" ]]; then
            project_name="${workspace}-{{ project_id }}"
        else
            project_name="project-${project_id:0:8}"
        fi

        echo "Destroying all services for project: {{ project_id }} (project: $project_name)"
        op inject -i "{{ project_state }}" | docker compose -p "$project_name" -f - down
        jq 'del(.projects["{{ project_id }}"])' "{{ docker_manifests_file }}" | {{ sponge }} "{{ docker_manifests_file }}"
        rm -f "{{ project_state }}"
        echo "✓ Project services destroyed"
    else
        echo "No services deployed for this project"
    fi
```

## Usage Examples

### Without Workspace (Default)

```bash
just deploy core,mcp,o11y
```

Docker Desktop shows:
```
▼ core
▼ mcp
▼ o11y
```

### With Workspace

```bash
DOCKER_WORKSPACE=homelab just deploy core,mcp,o11y
```

Docker Desktop shows:
```
▼ homelab-core
▼ homelab-mcp
▼ homelab-o11y
```

### Project-Scoped Deploy

```bash
# In a git repo with project.id set
just deploy mcp-project,project-iac
```

Docker Desktop shows:
```
▼ project-53D043D8
```

Or with workspace:
```bash
DOCKER_WORKSPACE=homelab just deploy mcp-project,project-iac
```

Docker Desktop shows:
```
▼ homelab-53D043D8-8D06-4156-8FFA-4D02371B461A
```

## Critical: Network Sharing Across Projects

### The Problem

When using different `--project-name` values, Docker Compose treats networks differently:

**Without `external: true`:**
```
$ docker compose -p alpha -f compose.yaml up --dry-run
WARN: a network with name backend exists but was not created for project "alpha".
      Set `external: true` to use an existing network
```

Docker Compose will:
1. Warn about the network not belonging to the project
2. Try to remove/recreate the network (potentially breaking other containers)
3. Cause conflicts between projects

**With `external: true`:**
```
$ docker compose -p alpha -f compose.yaml up --dry-run
Container alpha-test-svc-1  Creating
Container alpha-test-svc-1  Created
```

No warnings, uses existing network seamlessly.

### Current Setup Analysis

Your `networks.yaml` uses fixed `name:` attributes but **NOT** `external: true`:

```yaml
networks:
  backend:
    name: backend       # Fixed name, not project-prefixed
    driver: bridge
    internal: true
    # external: false   # <-- IMPLICIT, network owned by first project
```

The `network-init` service ensures networks exist, but the **first project to deploy owns them**.

### Impact on Project Naming Plan

| Scenario | Behavior |
|----------|----------|
| `just deploy core` then `just deploy mcp` (same project) | Works - same project owns networks |
| `-p core` then `-p mcp` (different projects) | **WARNING** - mcp doesn't own networks |
| Network in `-p core`, container in `-p mcp` | **DANGER** - `down` on core removes network while mcp uses it |

### Solution Options

#### Option A: Mark All Networks as External (Recommended)

Change `networks.yaml`:

```yaml
networks:
  backend:
    name: backend
    external: true  # <-- Add this
```

**Pros:**
- Networks survive `down` on any project
- No ownership conflicts
- Clean separation between network lifecycle and service lifecycle

**Cons:**
- Networks must be created before any deploy (need `docker network create` or init step)
- Networks persist after all projects are removed

**Implementation:**
```just
# Add to mktree or new init-networks recipe
init-networks:
    #!/usr/bin/env bash
    for net in dmz frontend backend admin data-tier authn authz n8n supabase-internal; do
        docker network inspect "$net" >/dev/null 2>&1 || \
            docker network create "$net" --driver bridge
    done
```

#### Option B: Keep network-init Service (Current)

Keep the `network-init` service but accept warnings:
- First profile deployed owns the networks
- Other profiles see warnings but still work
- `down` on the first profile is risky

**Implementation:**
- Document that `core` must be deployed first and destroyed last
- Add checks to prevent destroying `core` while other profiles are up

#### Option C: Single Project, Profile Grouping for Desktop

Don't use different `--project-name` values. Instead, use container labels for Docker Desktop grouping (if supported):

```yaml
services:
  traefik:
    labels:
      com.docker.desktop.group: core
```

**Cons:** Docker Desktop may not support this label for grouping.

### Recommended Approach

**Use Option A** - Mark all shared networks as `external: true`:

1. Update `networks.yaml` to add `external: true` to all networks
2. Add `init-networks` recipe to create networks before first deploy
3. Update `mktree` to call `init-networks`
4. Networks become independent of any compose project lifecycle

This cleanly separates:
- **Network lifecycle**: Created once, persist until explicitly removed
- **Service lifecycle**: Managed per-project with `--project-name`

### Network Lifecycle Commands

```bash
# Create networks (run once or in init)
just init-networks

# Deploy with project grouping
just deploy core      # -p core
just deploy mcp       # -p mcp  (no warnings, uses external networks)

# Destroy services (networks untouched)
just destroy mcp      # only removes mcp containers
just destroy core     # only removes core containers

# Explicit network cleanup (when truly done)
just clean-networks   # removes all networks
```

## Considerations

### Destroying Across Workspaces

If you deploy with `DOCKER_WORKSPACE=homelab` but try to destroy without it,
the project names won't match. Options:

1. **Store workspace in manifest** - Track which workspace was used for each deploy
2. **Require consistent usage** - Document that workspace must match
3. **Query docker** - Look up actual project names from running containers

### Manifest Extension

Consider extending manifest to track workspace:

```json
{
  "infrastructure": {
    "core": {
      "workspace": "homelab",
      "docker_project": "homelab-core",
      "deployed_at": "...",
      "compose_file": "..."
    }
  }
}
```

## Files to Modify

| File | Changes |
|------|---------|
| `justfile` | Add `docker_workspace` variable, update `deploy`, `destroy`, `build`, `destroy-project` |
| `docs/DOCKER_PROFILES.md` | Document workspace usage |

## Alternative: Use COMPOSE_PROJECT_NAME

Instead of `-p`, could set environment variable:

```just
deploy profiles="core": mktree
    #!/usr/bin/env bash
    # ...
    export COMPOSE_PROJECT_NAME="$project_name"
    op inject -i "..." | docker compose -f - up -d
```

Same effect, slightly different approach. `-p` flag is more explicit.
