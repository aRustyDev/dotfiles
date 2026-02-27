---
number: 5
title: Data YAML Schema Specification
date: 2026-02-25
status: proposed
tags:
  - schema
  - configuration
  - data
---

# 5. Data YAML Schema Specification

Date: 2026-02-25

## Status

Proposed

## Context

The `data.yml` files across modules contain configuration variables used in the templating pipeline (see ADR-004). Currently these files have inconsistent schemas, making it difficult to:

- Query configuration across modules (e.g., "what ports are in use?")
- Detect conflicts (e.g., duplicate port assignments)
- Build tooling for configuration management
- Understand module capabilities at a glance

A standardized schema enables treating `data.yml` files as a distributed "configuration database."

## Decision

### 1. Schema Structure

All `data.yml` files follow this schema. All fields are optional unless noted:

```yaml
# =============================================================================
# Network Configuration
# =============================================================================
port: 8080                    # Single port (integer)
ports:                        # Multiple ports
  - 8080
  - 8443

domain: "localhost"           # Single domain (string)
domains:                      # Multiple domains
  - "localhost"
  - "app.localhost"

# =============================================================================
# Shell Integration
# =============================================================================
bash:
  completions:                # Completion script filenames
    - "myapp.bash"
  functions:                  # Function script filenames
    - "myapp-helpers.bash"
  envs:                       # Environment variables
    - key: "MYAPP_HOME"
      value: "/opt/myapp"
    - key: "MYAPP_CONFIG"
      value: "$XDG_CONFIG_HOME/myapp"

zsh:
  completions:
    - "_myapp"
  functions:
    - "myapp-helpers.zsh"
  envs:
    - key: "MYAPP_HOME"
      value: "/opt/myapp"

fish:
  completions:
    - "myapp.fish"
  functions:
    - "myapp-helpers.fish"
  envs:
    - key: "MYAPP_HOME"
      value: "/opt/myapp"

# =============================================================================
# Aliases & Hotkeys
# =============================================================================
aliases:                      # Shell aliases
  - name: "ma"
    command: "myapp"
  - name: "mas"
    command: "myapp status"

hotkeys:                      # Keyboard shortcuts (app-specific format)
  - key: "ctrl+shift+m"
    action: "open_myapp"
    context: "global"

# =============================================================================
# Dependencies
# =============================================================================
deps:                         # Required dependencies
  - name: "jq"
    type: "brew"              # brew, cargo, npm, pip, etc.
  - name: "yq"
    type: "brew"

# =============================================================================
# Services
# =============================================================================
services:                     # Background services/daemons
  - name: "myapp"
    type: "launchd"           # launchd, systemd, docker, etc.
    port: 8080
    health_endpoint: "/health"

# =============================================================================
# Scheduled Tasks
# =============================================================================
crons:                        # Crontab entries
  - schedule: "0 * * * *"     # Every hour
    command: "myapp sync"
    description: "Sync myapp data"

# =============================================================================
# Target Directories
# =============================================================================
target-dir: "~/.config/myapp" # Simple string form

# OR structured form with named targets:
target-dir:
  config: "~/.config/myapp"
  data: "~/.local/share/myapp"
  cache: "~/.cache/myapp"

# =============================================================================
# Module-Specific Fields
# =============================================================================
# Additional fields specific to the module are allowed.
# Document custom fields in the module's README.
```

### 2. Field Specifications

| Field | Type | Description |
|-------|------|-------------|
| `port` | integer | Single port number |
| `ports` | integer[] | Multiple port numbers |
| `domain` | string | Single domain/hostname |
| `domains` | string[] | Multiple domains/hostnames |
| `<shell>.completions` | string[] | Completion script filenames |
| `<shell>.functions` | string[] | Function script filenames |
| `<shell>.envs` | object[] | Environment variable key-value pairs |
| `aliases` | object[] | Shell alias definitions |
| `hotkeys` | object[] | Keyboard shortcut definitions |
| `deps` | object[] | Dependency specifications |
| `services` | object[] | Service/daemon definitions |
| `crons` | object[] | Crontab entry definitions |
| `target-dir` | string \| object | Target directory path(s) |

### 3. Shell Identifiers

Valid shell identifiers for `<shell>.*` fields:
- `bash`
- `zsh`
- `fish`
- `sh` (POSIX)

### 4. Module-Specific Extensions

Modules may add custom fields not defined in this schema. Requirements:
- Custom fields should be documented in the module's README
- Custom fields should not conflict with reserved field names
- Consider proposing frequently-used custom fields for schema inclusion

### 5. Queryability

The schema enables queries across all `data.yml` files:

```bash
# Find all configured ports
fd data.yml | xargs yq '.port // .ports[]' 2>/dev/null | sort -u

# Find port conflicts
fd data.yml | xargs yq '.port // .ports[]' 2>/dev/null | sort | uniq -d

# List all aliases
fd data.yml | xargs yq '.aliases[].name' 2>/dev/null

# Find services on a specific port
fd data.yml | xargs yq 'select(.port == 8080 or .ports[] == 8080) | filename'
```

## Consequences

### Easier

- Query configuration across all modules
- Detect conflicts (duplicate ports, aliases)
- Build configuration management tooling
- Understand module capabilities from `data.yml`

### More Difficult

- Existing `data.yml` files need migration
- Contributors must learn the schema
- Schema evolution requires coordination

## Anti-patterns

1. **Flat port/domain without structure**
   ```yaml
   # Bad: ambiguous
   http: 8080
   https: 8443
   api_domain: api.localhost

   # Good: follows schema
   ports:
     - 8080
     - 8443
   domains:
     - api.localhost
   ```

2. **Shell-specific fields without shell prefix**
   ```yaml
   # Bad: unclear which shell
   completions:
     - myapp.bash

   # Good: explicit shell
   bash:
     completions:
       - myapp.bash
   ```

3. **Undocumented custom fields**
   ```yaml
   # Bad: what is this?
   special_config: true

   # Good: document in README or use standard field
   # README: special_config enables XYZ feature
   special_config: true
   ```
