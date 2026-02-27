---
number: 4
title: Configuration Templating Pipeline
date: 2026-02-25
status: proposed
tags:
  - templating
  - configuration
  - pipeline
---

# 4. Configuration Templating Pipeline

Date: 2026-02-25

## Status

Proposed

## Context

The repository uses multiple templating approaches inconsistently:

- Mustache templates with `{{variable}}` syntax
- Shell environment variable expansion via `envsubst` (`$VAR` or `${VAR}`)
- 1Password secret injection via `op inject` (`op://vault/item/field`)
- Go templates in some Docker configs
- Direct `op://` references in tracked source files

This inconsistency makes it difficult to:
- Understand how a configuration is generated
- Ensure secrets are properly managed
- Maintain a predictable build process

## Decision

### 1. Source of Truth

The template file (`config.toml`, `config.yaml`, etc.) is the source of truth and is tracked in git. It may contain:
- Mustache variables: `{{variable}}`
- Environment variable references: `$VAR` or `${VAR}`
- 1Password secret references: `op://vault/item/field`

### 2. Template Variables

Non-secret configuration variables are stored in `data.yml` (see ADR-005 for schema specification). This file:
- Is tracked in git
- Follows a global schema for queryability
- Contains module-specific configuration values

### 3. Pipeline Pattern

The canonical templating pipeline is:

```bash
mustache data.yml config.toml | envsubst | op inject > generated.toml
ln -s "$(pwd)/generated.toml" "<target-path>/config.toml"
```

**Pipeline stages:**

| Stage | Tool | Purpose |
|-------|------|---------|
| 1 | `mustache` | Expand template variables from `data.yml` |
| 2 | `envsubst` | Expand environment variables |
| 3 | `op inject` | Inject 1Password secrets |
| 4 | Output | Write to `generated.*` file |
| 5 | Symlink | Link generated file to target location |

### 4. Pipeline Characteristics

- **Replicated per module:** Each module implements its own pipeline in its justfile
- **Best practice, not strict:** Modules may modify the pipeline as needed
- **Documented deviations:** Non-standard pipelines should be documented in the module's README

### 5. Generated File Naming

Generated configuration files use the `generated.*` prefix:
- `generated.toml`
- `generated.yaml`
- `generated.conf`
- `generated.json`

This enables simple global gitignore patterns.

### 6. Gitignore

All `generated.*` files must be gitignored. Add to root `.gitignore`:

```
generated.*
```

## Consequences

### Easier

- Predictable configuration generation process
- Clear separation of template vs generated files
- Simple gitignore pattern for all generated configs
- Secrets never committed to git

### More Difficult

- Requires `mustache`, `envsubst`, and `op` CLI tools
- Each module must implement the pipeline
- Debugging requires understanding pipeline stages

## Anti-patterns

1. **Direct op:// in tracked source files**
   ```toml
   # Bad: op:// in tracked config.toml
   api_key = "op://vault/item/key"

   # Good: op:// in template, generates to gitignored file
   # config.toml (tracked, template)
   api_key = "op://vault/item/key"
   # → generated.toml (gitignored, after op inject)
   ```

2. **Inconsistent generated file naming**
   ```bash
   # Bad: various naming patterns
   configd.toml
   config.generated.toml
   .config.toml

   # Good: consistent prefix
   generated.toml
   ```

3. **Skipping pipeline stages without documentation**
   ```just
   # Bad: undocumented deviation
   template:
       cp config.toml generated.toml

   # Good: documented reason
   # NOTE: No secrets or variables needed, direct copy
   template:
       cp config.toml generated.toml
   ```
