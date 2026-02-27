---
number: 9
title: Module vs Group Brewfile
date: 2026-02-26
status: proposed
tags:
  - brewfile
  - modules
  - architecture
---

# 9. Module vs Group Brewfile

Date: 2026-02-26

## Status

Proposed

## Context

The repository contains many tools and packages. Some require configuration files, environment setup, or custom installation logic. Others simply need to be installed with no additional setup.

Creating a full module directory for every package leads to:
- Directory bloat (e.g., `tools/ripgrep/` containing only a brewfile)
- Maintenance overhead for trivial packages
- Inconsistent structure (some modules are stubs with no real content)

A clearer policy is needed for when to create a dedicated module versus adding a package to a shared group brewfile.

## Decision

### 1. Module Requirement

A package/tool **requires its own module** if it has ANY of the following:

| Requirement | Examples |
|-------------|----------|
| Configuration files | `~/.config/tool/config.toml`, dotfiles |
| Secret injection | 1Password references via `op inject` |
| Post-install setup | Shell integration, plugin installation |
| Custom recipes | Tool-specific commands beyond install |
| Service management | LaunchAgents, systemd units, docker-compose |

### 2. Group Brewfile

A package/tool should be added to a **group brewfile** if:

- It requires no configuration
- Installation is simply `brew install <package>`
- No post-install steps are needed

### 3. Group Brewfile Location

Each category directory should have a `brewfile` at its root for config-less packages:

```
tools/
├── brewfile              # Config-less tools: ripgrep, fd, jq, etc.
├── git/                  # Has config → own module
│   ├── justfile
│   ├── brewfile
│   └── config
└── helm/                 # Has config → own module
    ├── justfile
    ├── brewfile
    └── ...

terminals/
├── brewfile              # Config-less terminal utils (if any)
├── ghostty/              # Has config → own module
└── kitty/                # Has config → own module
```

### 4. Group Brewfile Justfile

Each category with a group brewfile should have a minimal justfile to install it:

```just
# tools/justfile (proxy justfile)
set shell := ["bash", "-euo", "pipefail", "-c"]

# Install config-less tools from group brewfile
install-group:
    brew bundle --file=brewfile --no-lock

# Note: Individual modules are imported via root justfile `mod` directives
```

### 5. Brewfile Syntax

Group brewfiles can use any supported Homebrew Bundle syntax:

```ruby
# tools/brewfile
brew "ripgrep"
brew "fd"
brew "jq"
brew "yq"
cargo "eza"
go "github.com/charmbracelet/gum"
```

## Consequences

### Easier

- Reduced directory count (fewer stub modules)
- Clear decision criteria for module creation
- Simpler maintenance for trivial packages
- Single location for "just install these tools"

### More Difficult

- Must maintain group brewfiles alongside module brewfiles
- Need to decide which category a config-less tool belongs to
- Two installation paths: `just tools::install-group` vs `just git install`

## Examples

### Should be in group brewfile

```ruby
# tools/brewfile
brew "ripgrep"      # No config needed
brew "fd"           # No config needed
brew "jq"           # No config needed (unless building jq library)
brew "bat"          # No config needed
brew "eza"          # No config needed
cargo "hyperfine"   # No config needed
```

### Should have own module

```
tools/git/          # Has config, SSH signing, allowed_signers
tools/helm/         # Has plugins, repositories to configure
tools/docker/       # Has daemon.json, credential helpers
shells/zsh/         # Has .zshrc, plugins, aliases
```

## Anti-patterns

1. **Creating modules for config-less tools**
   ```
   # Bad: tools/ripgrep/ with only a brewfile
   # Good: Add `brew "ripgrep"` to tools/brewfile
   ```

2. **Putting configured tools in group brewfile**
   ```
   # Bad: Adding git to tools/brewfile when you have custom config
   # Good: Create tools/git/ module with config files
   ```

3. **Duplicating packages**
   ```
   # Bad: Same package in both group brewfile and module brewfile
   # Pick one location based on whether config exists
   ```

## Migration

Existing stub modules (justfile with only `install: @echo "no config"`) should be:
1. Reviewed for actual config requirements
2. If no config: delete module, add to group brewfile
3. If has config: implement properly or mark as TODO
