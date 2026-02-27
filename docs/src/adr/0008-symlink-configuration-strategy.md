---
number: 8
title: Symlink Configuration Strategy
status: accepted
date: 2026-02-26
---

# Symlink Configuration Strategy

## Context and Problem Statement

Configuration files need to be installed from the dotfiles repository to their target locations. The strategy must support templating (variable substitution, secret injection) while maintaining clear separation between source templates, generated configs, and installed locations.

## Decision Drivers

* Configs must be symlinked, not copied, to enable easy updates
* Templates need hydration (mustache, envsubst, op inject) before installation
* Clear naming conventions for source vs generated files
* Support for both single files and directories
* Target paths (dotdir) should be data-driven, not hardcoded in justfiles

## Considered Options

* Copy files directly to target
* Symlink source files directly to target
* Template → Generate → Symlink pipeline

## Decision Outcome

Chosen option: "Template → Generate → Symlink pipeline", because it separates concerns and supports the full templating workflow.

### File Naming Conventions

| Type | Single File | Directory |
|------|-------------|-----------|
| Source template | `template.{ext}` | `templates.d/` |
| Generated config | `configd.{ext}` | `config.d/` |
| Target | Symlink to configd.* | Symlink to config.d/ |

### Pipeline Flow

```
template.toml ──[hydrate]──> configd.toml ──[symlink]──> $dotdir/config.toml
templates.d/  ──[hydrate]──> config.d/    ──[symlink]──> $dotdir/
```

### Hydration Command

```bash
mustache data.yml template.foo | envsubst | op inject > configd.foo
```

### Target Path Configuration

The `dotdir` (target installation path) MUST be defined in `data.yml`, not hardcoded in the justfile:

```yaml
# data.yml
dotdir: "{{xdg_config}}/myapp"
```

### Standard Justfile Recipes

```just
install: config

config: mktree
    # Hydrate template
    mustache data.yml template.toml | envsubst | op inject > configd.toml
    # Symlink to target
    ln -sf "$(pwd)/configd.toml" "$(yq '.dotdir' data.yml)/config.toml"

mktree:
    mkdir -p "$(yq '.dotdir' data.yml)"
```

### Empty/Stub Modules

Modules without configuration files yet should use the `[group(stubs)]` attribute:

```just
[group(stubs)]
install:
    @echo "No config files to install yet"
```

### Consequences

* Good, because source templates remain unchanged and reusable
* Good, because generated configs are gitignored and machine-specific
* Good, because symlinks allow instant updates when regenerating
* Good, because data.yml centralizes all module metadata
* Bad, because requires regeneration after template changes
* Bad, because symlinks may not work on all filesystems (e.g., some network mounts)

### Confirmation

* All module justfiles follow the template → configd → symlink pattern
* `dotdir` is defined in data.yml, not justfile
* Generated files (configd.*) are in .gitignore
* `just install` creates symlinks, not copies

## More Information

Related ADRs:
- ADR-002: Justfile Conventions
- ADR-004: Configuration Templating Pipeline
- ADR-005: Data YAML Schema Specification
- ADR-006: Secret Management with 1Password
