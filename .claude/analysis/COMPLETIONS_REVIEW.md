# Completions Module ADR Review Report

**Review Date:** 2026-02-25  
**Module:** completions  
**Parent Issue:** dotfiles-adam-c4k.65  
**Phase:** 1

## Executive Summary

The `completions` module was reviewed against ADR-002 through ADR-007 checklists. **5 violations** were identified across 3 ADRs.

### Coverage Summary

| ADR | Status | Notes |
|-----|--------|-------|
| ADR-002 (Justfile Conventions) | PARTIAL | Missing shell settings and standard recipes |
| ADR-003 (Justfile Module Definition) | INCOMPLETE | Non-standard filename, missing documentation |
| ADR-004 (Configuration Templating) | N/A | Not applicable - no templating in module |
| ADR-005 (Data YAML Schema) | INCOMPLETE | Completions not defined per schema |
| ADR-006 (Secret Management) | PASS | No secrets required |
| ADR-007 (Service Conventions) | N/A | Not a service module |

## Module Overview

**File:** `/private/etc/dotfiles/adam/completions/mods.just`  
**Type:** Configuration data file defining shell completion directory paths  
**Lines:** 14  
**Purpose:** Defines directory paths for bash, zsh, fish, and powershell completions

### Current Content

```just
powershell_compd := '~/.config/powershell/Modules/'
nushell_compd := ''
elvish_compd := ''
bash_compd := '/etc/bash_completion.d/'
fish_compd := '~/.config/fish/completions/'
zsh_compd := '~/.zfunc/'

# Add to ~/.zshrc (before compinit):
# fpath=(~/.zfunc $fpath)
# autoload -Uz compinit && compinit

# Add to ~/.bashrc:
# source ~/.bash_completion.d/adrs
```

## Violations Found

### 1. Missing shell settings (Medium Severity)

**ID:** dotfiles-adam-c4k.65.1  
**ADR:** ADR-002, Section 2  
**Type:** bug

Per ADR-002 Section 2, all justfiles must include shell safety settings:

```just
set shell := ["bash", "-euo", "pipefail", "-c"]
```

**Current State:** Shell setting is missing from the file.

**Impact:** If this file is used as a justfile (imported or executed), it will use the default shell without safety flags (-e, -u, -o pipefail).

**Location:** `/private/etc/dotfiles/adam/completions/mods.just` (lines 1-6)

---

### 2. Unclear module type - non-standard filename (Low Severity)

**ID:** dotfiles-adam-c4k.65.2  
**ADR:** ADR-003, Section 5  
**Type:** style

Per ADR-003, modules should use standard naming conventions:
- Modules: `justfile`
- Helpers: `.build/just/*.just`
- Data: `data.yml`

**Current State:** File is named `mods.just` instead of following standard conventions.

**Issue:** Unclear whether this is:
- A module with its own justfile
- A helper justfile providing shared recipes
- Configuration data that should be in a different format

**Recommendation:** Rename to `justfile` if this is a module, or relocate to `.build/just/` if this is a helper.

**Location:** `/private/etc/dotfiles/adam/completions/mods.just`

---

### 3. No standard recipes defined (Medium Severity)

**ID:** dotfiles-adam-c4k.65.3  
**ADR:** ADR-002, Sections 5-6  
**Type:** chore

Per ADR-002 Sections 5-6, modules should implement standard recipes or null implementations:

**Lifecycle group:**
- `install` - Entry point for parent justfiles
- `clean` - Remove generated/installed symlinks
- `mktree` - Create directory structure

**Info group:**
- `health` - Check service/config health
- `ls` - List installed symlink paths
- `ls-net` - List component/tool configured ports/domains

**Build group:**
- `completions` - Generate/install/symlink shell completions
- `build` - Build/compile artifacts
- `template` - Generate config from templates
- `test` - Run tests/validation

**Current State:** File only defines variables, no recipes of any kind.

**Recommendation:** Implement recipes or provide null implementations:

```just
set shell := ["bash", "-euo", "pipefail", "-c"]

[group("lifecycle")]
install:
    @true

[group("lifecycle")]
clean:
    @true

[group("lifecycle")]
mktree:
    @true

[group("info")]
health:
    @true

[group("info")]
ls:
    @true

[group("build")]
completions:
    @true

[group("build")]
build:
    @true

[group("build")]
template:
    @true

[group("build")]
test:
    @true
```

**Location:** `/private/etc/dotfiles/adam/completions/mods.just`

---

### 4. Missing README documentation (Low Severity)

**ID:** dotfiles-adam-c4k.65.4  
**ADR:** ADR-003, Section 4  
**Type:** docs

Per ADR-003 Section 4, modules should include `README.md` documenting:
- Purpose of the module
- Directory structure
- How to add new completions
- Installation instructions

**Current State:** No README.md exists in the completions directory.

**Impact:** Users cannot understand the module's purpose or how to extend it without reading the source file.

**Recommendation:** Create `README.md` with:

```markdown
# Completions Module

Defines directory paths for shell completions across different shells (bash, zsh, fish, powershell, etc).

## Directory Structure

| Shell | Directory |
|-------|-----------|
| bash | `/etc/bash_completion.d/` |
| zsh | `~/.zfunc/` |
| fish | `~/.config/fish/completions/` |
| powershell | `~/.config/powershell/Modules/` |

## Adding Completions

1. Generate or create the completion file for your shell
2. Place it in the appropriate directory
3. Restart your shell or source the completion file

## Shell Setup Instructions

### Zsh
Add to `~/.zshrc` (before compinit):
```bash
fpath=(~/.zfunc $fpath)
autoload -Uz compinit && compinit
```

### Bash
Add to `~/.bashrc`:
```bash
source /etc/bash_completion.d/*
```
```

**Location:** `/private/etc/dotfiles/adam/completions/`

---

### 5. Consider data.yml schema definition (Low Severity)

**ID:** dotfiles-adam-c4k.65.5  
**ADR:** ADR-005, Sections 1-2  
**Type:** chore

Per ADR-005, shell-specific configuration should follow the standardized schema:

**Current State:** Completion directories are hardcoded as module-level variables.

**Schema Recommendation:** Define in `data.yml`:

```yaml
bash:
  completions:
    - /etc/bash_completion.d/

zsh:
  completions:
    - ~/.zfunc/

fish:
  completions:
    - ~/.config/fish/completions/
```

**Benefit:** Enables querying across all modules for completion configuration:

```bash
fd data.yml | xargs yq '.bash.completions[]' 2>/dev/null
```

**Note:** This recommendation is low priority as it depends on whether the module should follow the templating pipeline (ADR-004). If this is purely configuration data without templating, current approach may be acceptable.

**Location:** `/private/etc/dotfiles/adam/completions/mods.just`

---

## Statistics

| Category | Count |
|----------|-------|
| Total Violations | 5 |
| Critical | 0 |
| High | 0 |
| Medium | 2 |
| Low | 3 |
| ADR-002 Violations | 2 |
| ADR-003 Violations | 2 |
| ADR-005 Violations | 1 |

## Priority Recommendations

### High Priority (Implement First)
1. **Add shell safety setting** - Required for safe just execution
   - Add `set shell := ["bash", "-euo", "pipefail", "-c"]`

### Medium Priority (Implement Second)
2. **Clarify module type** - Rename to standard convention
   - Rename `mods.just` to `justfile` or move to `.build/just/`
3. **Implement standard recipes** - Per ADR-002 standards
   - Add standard recipes or null implementations

### Low Priority (Nice to Have)
4. **Add README documentation** - Improves usability
   - Create `/private/etc/dotfiles/adam/completions/README.md`
5. **Consider data.yml migration** - Enables cross-module querying
   - Optional: Move paths to `data.yml` if module follows templating pipeline

## Beads Issues Created

| ID | Title | Severity |
|----|-------|----------|
| dotfiles-adam-c4k.65.1 | completions: Missing shell settings in mods.just | medium |
| dotfiles-adam-c4k.65.2 | completions: Unclear module type (non-standard filename) | low |
| dotfiles-adam-c4k.65.3 | completions: No standard recipes defined | medium |
| dotfiles-adam-c4k.65.4 | completions: Missing README documentation | low |
| dotfiles-adam-c4k.65.5 | completions: Consider data.yml schema definition (ADR-005) | low |

## Conclusion

The completions module requires **2 medium-priority fixes** (shell settings and standard recipes) to comply with ADR-002 standards. Additional improvements (naming, documentation, schema) are recommended but lower priority.

The module's current approach as a configuration data file is acceptable, but requires clarification of its role (helper vs module) and proper documentation.

---

**Report Generated:** 2026-02-25  
**Reviewed Against:** ADR-002 through ADR-007  
**Review Scope:** Phase 1
