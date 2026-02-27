---
number: 2
title: Justfile Conventions
date: 2026-02-25
status: proposed
tags:
  - justfile
  - conventions
  - standards
---

# 2. Justfile Conventions

Date: 2026-02-25

## Status

Proposed

## Context

The repository contains 100+ justfiles across various modules. Inconsistent patterns have emerged including:

- Mixed use of XDG environment variables vs just's built-in directory functions
- Direct `brew install` commands instead of `brew bundle` with brewfiles
- Inconsistent recipe naming and grouping
- Global values passed as parameters instead of imported from shared libraries

A consistent convention is needed to ensure maintainability and predictability across all justfiles.

## Decision

### 1. Directory Functions

Use just's built-in directory functions instead of XDG environment variables:

| Function | Path | Replaces |
|----------|------|----------|
| `config_directory()` | `~/.config` | `env("XDG_CONFIG_HOME")` |
| `data_local_directory()` | `~/.local/share` | `env("XDG_DATA_HOME")` |
| `cache_directory()` | `~/.cache` | `env("XDG_CACHE_HOME")` |
| `home_directory()` | `~` | `env("HOME")` |
| `config_local_directory()` | User-specific local config | - |
| `data_directory()` | User-specific data | - |
| `executable_directory()` | User-specific executables | - |

### 2. Shell Settings

All justfiles must use safe shell settings:

```just
set shell := ["bash", "-euo", "pipefail", "-c"]
```

### 3. Global Configuration

Global values (such as `dotdir`, common paths) are defined in the shared library (`.build/just/lib.just`) and imported by modules. Global values should NOT be passed as recipe parameters.

### 4. Import Paths

Always use **relative import paths** from the module to the shared library:

```just
# Good: relative path
import '../.build/just/lib.just'
import '../../.build/just/lib.just'

# Bad: absolute path
import '/etc/dotfiles/adam/.build/just/lib.just'
```

### 5. Standard Recipes

The following recipes are standard. Null implementations are allowed when a recipe is not applicable to a module:

| Recipe | Purpose | Group |
|--------|---------|-------|
| `install` | Entry point for parent justfiles; installs tools/configs via symlink | lifecycle |
| `clean` | Remove generated/installed symlinks | lifecycle |
| `mktree` | Create directory structure for target paths | lifecycle |
| `health` | Check service/config health | info |
| `ls` | List installed symlink paths | info |
| `ls-net` | List component/tool configured ports/domains | info |
| `completions` | Generate/install/symlink shell completions | build |
| `build` | Build/compile artifacts | build |
| `template` | Generate config from templates | build |
| `test` | Run tests/validation | build |

### 6. Null Recipe Implementation

When a standard recipe is not applicable to a module, implement it as a null recipe:

```just
# Null recipe - this module has no completions
[group("build")]
completions:
    @true

# Alternative: with comment explaining why
[group("build")]
completions:
    @echo "No completions for this module"
```

### 7. Recipe Groups

Recipes should be organized into standardized groups:

| Group | Purpose |
|-------|---------|
| `lifecycle` | Install, clean, setup recipes |
| `info` | Status, listing, health check recipes |
| `build` | Compilation, templating, generation recipes |
| `service` | Start, stop, restart recipes (service modules only) |

```just
[group("lifecycle")]
install:
    ...

[group("info")]
health:
    ...

[group("build")]
template:
    ...

[group("service")]
start:
    ...
```

### 8. Dependencies

Use `brew bundle` with a brewfile instead of direct `brew install` commands:

```just
# Good
install:
    brew bundle --file=brewfile

# Bad
install:
    brew install foo bar baz
```

### 9. Recipe Arguments

Use the `[arg()]` attribute for recipe arguments with clear defaults and documentation:

```just
# Good: explicit argument with default
[arg('verbose', help: 'Enable verbose output', default: 'false')]
build verbose='false':
    #!/usr/bin/env bash
    if [[ "{{ verbose }}" == "true" ]]; then
        set -x
    fi
    ...

# Good: boolean argument pattern
[arg('force', help: 'Force overwrite existing files')]
install force='false':
    #!/usr/bin/env bash
    if [[ "{{ force }}" == "true" ]]; then
        rm -f "{{ target }}"
    fi
    ln -s "{{ source }}" "{{ target }}"

# Bad: undocumented argument
install x:
    ...
```

**Boolean argument convention:**
- Use string `'true'` / `'false'` (not empty string)
- Default to `'false'`
- Check with `[[ "{{ arg }}" == "true" ]]`

## Consequences

### Easier

- Consistent patterns across all modules make onboarding easier
- Recipe discovery via `just --list --groups` works predictably
- Shared library updates propagate to all modules
- Cross-platform compatibility through just's built-in functions

### More Difficult

- Existing justfiles need migration to new patterns
- Contributors must learn the conventions
- Null recipe implementations may seem verbose

## Anti-patterns

The following patterns are deprecated and should not be used:

1. **XDG Environment Variables**
   ```just
   # Bad
   config := env("XDG_CONFIG_HOME", home_directory() / ".config")

   # Good
   config := config_directory()
   ```

2. **Direct brew install**
   ```just
   # Bad
   install:
       brew install foo

   # Good
   install:
       brew bundle --file=brewfile
   ```

3. **Global values as parameters**
   ```just
   # Bad
   install dotdir:
       ln -s config.toml "{{ dotdir }}/config.toml"

   # Good (import from lib.just)
   import '../.build/just/lib.just'
   install:
       ln -s config.toml "{{ dotdir }}/config.toml"
   ```

4. **Absolute import paths**
   ```just
   # Bad
   import '/etc/dotfiles/adam/.build/just/lib.just'

   # Good
   import '../.build/just/lib.just'
   ```

5. **Undocumented arguments**
   ```just
   # Bad: what does 'x' mean?
   build x:
       ...

   # Good: documented with [arg()]
   [arg('verbose', help: 'Enable verbose output')]
   build verbose='false':
       ...
   ```
