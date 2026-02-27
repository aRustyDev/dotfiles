# Scripts Module ADR Review

**Module:** scripts  
**Parent Issue:** dotfiles-adam-c4k.84  
**Phase:** 1  
**Review Date:** 2026-02-25  
**Reviewer:** Claude Code ADR Audit

## Summary

The scripts module contains 8 violations across ADRs 002, 003, and 006. The primary issues are:

- **High Severity (3):** Missing shell settings, no standard recipes, no recipe groups
- **Medium Severity (5):** Deprecated .meta.json files, missing documentation, unclear module purpose, missing secret patterns

## Violations by ADR

### ADR-002: Justfile Conventions (3 violations - HIGH severity)

#### 1. Missing Shell Settings
- **Severity:** HIGH
- **Location:** `/private/etc/dotfiles/adam/scripts/justfile`
- **Issue:** ADR-002 Section 2 requires all justfiles to use safe shell settings
- **Current State:** No shell settings defined; inherits from lib.just (zsh)
- **Expected:** `set shell := ["bash", "-euo", "pipefail", "-c"]`
- **Type:** missing_configuration

#### 2. No Standard Recipes Implemented
- **Severity:** HIGH
- **Location:** `/private/etc/dotfiles/adam/scripts/justfile`
- **Issue:** ADR-002 Section 5 defines 10 standard recipes. Current justfile is empty.
- **Current State:** scripts/justfile only contains: `import '../.build/just/lib.just'`
- **Expected:** All 10 recipes with null implementations:
  - `install`, `clean`, `mktree` (lifecycle)
  - `health`, `ls`, `ls-net` (info)
  - `completions`, `build`, `template`, `test` (build)
- **Type:** missing_recipes

#### 3. No Recipe Groups Defined
- **Severity:** HIGH
- **Location:** `/private/etc/dotfiles/adam/scripts/justfile`
- **Issue:** ADR-002 Section 7 requires standardized recipe groups
- **Current State:** No recipes exist to organize
- **Expected:** All recipes must use `[group()]` attribute
- **Type:** missing_organization

### ADR-003: Justfile Module Definition (3 violations - MEDIUM severity)

#### 1. Deprecated .meta.json Files
- **Severity:** MEDIUM
- **Location:** Multiple locations in scripts/ hierarchy
- **Issue:** ADR-003 Section 3 states .meta.json is DEPRECATED. Section 4.2 lists as anti-pattern.
- **Current State:** Found 6 .meta.json files
- **Expected:** Remove all .meta.json files
- **Type:** deprecated_pattern
- **Affected Files:**
  - `/private/etc/dotfiles/adam/scripts/.meta.json`
  - `/private/etc/dotfiles/adam/scripts/active/.meta.json`
  - `/private/etc/dotfiles/adam/scripts/active/nix-darwin/.meta.json`
  - `/private/etc/dotfiles/adam/scripts/archive/.meta.json`
  - `/private/etc/dotfiles/adam/scripts/archive/dotfiles-evolution-project/.meta.json`
  - `/private/etc/dotfiles/adam/scripts/archive/npm-to-volta-migration/.meta.json`

#### 2. No README.md Documentation
- **Severity:** MEDIUM
- **Location:** `/private/etc/dotfiles/adam/scripts/`
- **Issue:** ADR-003 Section 4 lists README.md as "Recommended" module documentation
- **Current State:** No README.md found in scripts/ or subdirectories
- **Expected:** Create README.md documenting:
  - Module purpose and scope
  - Contained scripts and their functions
  - Usage instructions
  - Dependencies
- **Type:** missing_documentation

#### 3. Module Identification Unclear
- **Severity:** MEDIUM
- **Location:** `/private/etc/dotfiles/adam/scripts/`
- **Issue:** ADR-003 Section 5 provides identification criteria. scripts/ structure is ambiguous.
- **Current State:** Has subdirectories (active/, archive/, examples/) suggesting proxy/orchestration role
- **Expected:** Clarify purpose - if proxy, justify structure in README
- **Type:** unclear_purpose

### ADR-004: Configuration Templating Pipeline (No violations - N/A)

- **Status:** Not Applicable
- **Reason:** scripts module contains shell scripts and utilities, not configuration files
- **Note:** If module generates configs in future, follow mustache → envsubst → op inject pipeline

### ADR-005: Data YAML Schema Specification (No violations - N/A)

- **Status:** Not Applicable
- **Reason:** No data.yml file present
- **Note:** If module defines dependencies/ports/services, create data.yml following schema

### ADR-006: Secret Management with 1Password (1 violation - MEDIUM severity)

#### 1. Shell Scripts Lack Secret Injection Patterns
- **Severity:** MEDIUM
- **Location:** `/private/etc/dotfiles/adam/scripts/active/nix-darwin/`
- **Issue:** ADR-006 defines secret management via 1Password injection
- **Current State:** Scripts have no op:// or op inject patterns
- **Expected:** If scripts require secrets, use op inject pattern and document in README
- **Type:** missing_pattern
- **Affected Files:**
  - `/private/etc/dotfiles/adam/scripts/active/nix-darwin/backup-configs.sh`
  - `/private/etc/dotfiles/adam/scripts/active/nix-darwin/initial-setup.sh`
  - `/private/etc/dotfiles/adam/scripts/active/nix-darwin/undo-initial-setup.sh`

### ADR-007: Service Module Conventions (No violations - N/A)

- **Status:** Not Applicable
- **Reason:** scripts module does not manage background services/daemons
- **Note:** Only applicable if module scope expands to include service management

## Critical Findings

1. **Non-functional justfile:** Current justfile is effectively empty, just an import
2. **No recipe discovery:** `just scripts --list` returns nothing
3. **Deprecated metadata:** 6 .meta.json files using deprecated pattern
4. **No documentation:** Missing README explaining module purpose and structure
5. **Ambiguous scope:** Unclear if this is a utility collection or orchestration proxy

## Recommended Actions

### Priority 1: Implement Standard Recipes (ADR-002)
Add shell settings and all 10 standard recipes to scripts/justfile:

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

[group("info")]
ls-net:
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

### Priority 2: Remove Deprecated .meta.json Files (ADR-003)
Delete all 6 .meta.json files from scripts hierarchy.

### Priority 3: Create README.md Documentation (ADR-003)
Create comprehensive README at `/private/etc/dotfiles/adam/scripts/README.md` documenting:
- Module classification (proxy vs. module vs. collection)
- Purpose of scripts/ directory
- Description of active/, archive/, examples/ subdirectories
- Individual script purposes and usage
- Dependencies and requirements
- How to use justfile recipes

### Priority 4: Clarify Module Purpose (ADR-003)
Determine and document whether scripts/ is:
- A proxy justfile orchestrating child modules
- A true module with its own functionality
- A collection directory with mixed purposes

### Priority 5: Document Secret Handling (ADR-006)
Review nix-darwin scripts to determine if they need secrets. If so:
- Add op:// references to config files
- Document op inject pipeline in README
- Add secret injection step to justfile recipes

### Priority 6: Review for Additional Compliance
After implementing above, check for:
- Relative import paths (ADR-002 Section 4)
- brewfile if brew dependencies exist (ADR-002 Section 8)
- data.yml if module has ports/services (ADR-005)

## Files Reviewed

### Main Module Files
- `/private/etc/dotfiles/adam/scripts/justfile` - EMPTY (only import)
- `/private/etc/dotfiles/adam/.build/just/lib.just` - Library import target

### Subdirectories
- `/private/etc/dotfiles/adam/scripts/active/` - Active scripts and utilities
- `/private/etc/dotfiles/adam/scripts/archive/` - Archived scripts
- `/private/etc/dotfiles/adam/scripts/examples/` - Example scripts

### Metadata Files (Deprecated)
- 6 .meta.json files across hierarchy
- 1 .todo/ directory

### Shell Scripts
- `restart-nix.sh` - Nix daemon restart utility
- `create-github-issues.sh` - GitHub issue creation
- `create-all-issues.sh` - Bulk issue creation
- `assign-milestones.sh` - Milestone assignment
- `validate-frontmatter.py` - Frontmatter validation
- And others in active/nix-darwin/, archive/

## Next Steps

1. Create beads issues using `bd create --parent dotfiles-adam-c4k.84` for each violation
2. Implement fixes in priority order
3. Re-run ADR audit to verify compliance
4. Archive completed findings with issue links

## Statistics

- **Total Violations:** 8
- **High Severity:** 3
- **Medium Severity:** 5
- **Low Severity:** 0
- **Not Applicable:** 3 ADRs (004, 005, 007)
- **Applicable ADRs:** 4 (002, 003, 006, 007 partial)
- **.meta.json Files Found:** 6 (deprecated)
- **Recipes Implemented:** 0 (required: 10)
