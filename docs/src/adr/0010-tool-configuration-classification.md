---
number: 10
title: Tool Configuration Classification
date: 2026-02-26
status: proposed
tags:
  - modules
  - configuration
  - architecture
---

# 10. Tool Configuration Classification

Date: 2026-02-26

## Status

Proposed

## Context

When deciding whether a tool needs its own module or belongs in a group brewfile (see ADR-0009), we must understand the tool's configuration characteristics. Tools fall into three categories based on their configuration needs, and this affects how they should be organized in the repository.

## Decision

### 1. Configuration Categories

#### Category A: Needs Config

Tools that **require** configuration to function properly or at all.

| Characteristics | Examples |
|-----------------|----------|
| Won't work without setup | `git` (user.name, user.email) |
| Requires credentials/keys | `ssh` (keys, known_hosts), `1password-cli` |
| Requires connection info | `beads` (database), `kubectl` (kubeconfig) |
| Requires project-specific setup | `docker` (daemon.json, credential helpers) |

**Action**: Always create a dedicated module.

#### Category B: Takes Config

Tools that work with defaults but are commonly customized.

| Subcategory | Characteristics | Examples |
|-------------|-----------------|----------|
| **Likely to configure** | Most users customize these | `bat` (theme), `starship` (prompt), `tmux` (keybindings), `fzf` (FZF_DEFAULT_OPTS), `delta` (colors) |
| **Unlikely to configure** | Defaults are usually sufficient | `ripgrep` (.ripgreprc), `fd` (ignore patterns), `jq` (~/.jq library), `eza` (aliases only) |

**Action**: Create module if you will maintain config; otherwise group brewfile.

#### Category C: No Config

Tools with no configuration mechanism.

| Characteristics | Examples |
|-----------------|----------|
| Shell builtins | `cd`, `echo`, `test` |
| Simple POSIX utilities | `cat`, `grep`, `ls`, `cp`, `mv`, `rm`, `wc`, `head`, `tail` |
| Single-purpose binaries | Some CLI tools with only flags, no config files |

**Action**: Not applicable (system tools) or group brewfile (if installable).

### 2. Decision Flowchart

```
Is this tool installed via brew/cargo/etc?
│
├─ NO (system tool) ──→ Not managed in dotfiles
│
└─ YES
    │
    Does the tool REQUIRE config to function?
    │
    ├─ YES ──→ Category A ──→ Create module
    │
    └─ NO
        │
        Does the tool SUPPORT config files?
        │
        ├─ NO ──→ Category C ──→ Group brewfile
        │
        └─ YES
            │
            Will YOU maintain a config for this tool?
            │
            ├─ YES ──→ Category B (configured) ──→ Create module
            │
            └─ NO ──→ Category B (defaults) ──→ Group brewfile
```

### 3. Common Config Locations

When auditing whether a tool "takes config", check these locations:

| Location | Tools |
|----------|-------|
| `~/.config/<tool>/` | Modern XDG-compliant tools |
| `~/.<tool>rc` | Traditional Unix style |
| `~/.<tool>` | Simple config files |
| `~/.config/<tool>.toml` | Single-file configs |
| Environment variables | `FZF_DEFAULT_OPTS`, `BAT_THEME`, etc. |
| In other configs | `delta` in `.gitconfig`, integrations |

### 4. Audit Checklist

Before classifying a tool, verify:

1. **Check documentation**: `<tool> --help`, man pages, official docs
2. **Search for config**: `ls -la ~/.<tool>* ~/.config/<tool>* 2>/dev/null`
3. **Check XDG**: Common for modern tools
4. **Check env vars**: `<tool> --help | grep -i env` or docs
5. **Check if config exists on system**: Tool may have created defaults

## Consequences

### Easier

- Clear mental model for classifying tools
- Consistent decision-making across contributors
- Reduced guesswork when adding new tools
- Audit process for existing stub modules

### More Difficult

- Requires research for unfamiliar tools
- "Takes config" category requires personal judgment
- May need to revisit classifications as usage changes

## Examples

### Category A → Module Required

```
git/
├── justfile
├── brewfile          # brew "git"
├── config            # [user], [commit], etc.
└── allowed_signers/  # SSH signing keys
```

### Category B (configured) → Module Required

```
bat/
├── justfile
├── brewfile          # brew "bat"
└── config            # theme, pager settings
```

### Category B (defaults) → Group Brewfile

```ruby
# tools/brewfile
brew "ripgrep"    # Has .ripgreprc but I use defaults
brew "fd"         # Has config but I use defaults
brew "hyperfine"  # Benchmarking, no config needed
```

### Category C → Group Brewfile or N/A

```ruby
# tools/brewfile (if not system-provided)
brew "coreutils"  # GNU versions of cat, ls, etc.
brew "findutils"  # GNU find, xargs
```

## Anti-patterns

1. **Creating modules for Category C tools**
   ```
   # Bad: tools/cat/ module
   # cat has no config - use group brewfile or skip entirely
   ```

2. **Using group brewfile for Category A tools**
   ```
   # Bad: Adding git to tools/brewfile
   # git requires config - needs its own module
   ```

3. **Not auditing before deciding**
   ```
   # Bad: Assuming a tool has no config without checking
   # Many tools have optional configs that aren't obvious
   ```
