# Keebs Module ADR Review Report

**Review Date:** 2026-02-25
**Module:** keebs
**Parent Issue:** dotfiles-adam-c4k.76
**Location:** `/private/etc/dotfiles/adam/keebs/`

## Executive Summary

The keebs module has **CRITICAL VIOLATIONS** across multiple ADRs (002-005). The module is missing foundational infrastructure required by the architecture decisions:

- **Missing justfile** - violates ADR-002 and ADR-003
- **No standard recipes** - violates ADR-002
- **Non-compliant data structure** - violates ADR-005
- **No templating pipeline** - violates ADR-004

**Overall Status:** NON_COMPLIANT with 5 violations (3 critical, 2 moderate)

---

## Detailed Findings

### Current Module State

**Files Present:**
- `hotkeys.yaml` - Contains keyboard shortcut requirements (not schema-compliant)

**Files Missing:**
- `justfile` - Required for module orchestration
- `data.yml` - Required for configuration metadata
- `brewfile` - May be needed if dependencies exist
- `README.md` - Documentation of module purpose

### ADR-002: Justfile Conventions

**Status:** CRITICAL VIOLATION
**Issue:** dotfiles-adam-c4k.76.1, dotfiles-adam-c4k.76.4

**Violations:**
1. Module has NO justfile
2. No shell settings: `set shell := ["bash", "-euo", "pipefail", "-c"]`
3. No import statement for shared library: `import '../.build/just/lib.just'`
4. No standard recipes implemented

**Standard Recipes Required (per ADR-002):**
```
Lifecycle group:
  - install (entry point for parent justfiles)
  - clean (remove generated/installed symlinks)
  - mktree (create directory structure)

Info group:
  - health (check module health)
  - ls (list installed symlink paths)
  - ls-net (list configured ports/domains, if applicable)

Build group:
  - completions (generate/install shell completions)
  - build (build/compile artifacts, if applicable)
  - template (generate config from templates, if applicable)
  - test (run tests/validation, if applicable)
```

**Required Action:**
- Create `/private/etc/dotfiles/adam/keebs/justfile`
- Implement all standard recipes with `[group()]` attributes
- Use null implementations (`@true` or explanatory message) for non-applicable recipes

---

### ADR-003: Justfile Module Definition

**Status:** CRITICAL VIOLATION
**Issue:** dotfiles-adam-c4k.76.1

**Violations:**
1. No justfile present → cannot establish module definition
2. Module cannot be independently installed
3. Module lacks required orchestration file

**Required Action:**
- Add justfile to establish module definition per ADR-003 section 1
- Ensure justfile can orchestrate module independently

---

### ADR-004: Configuration Templating Pipeline

**Status:** VIOLATION (moderate)
**Issue:** dotfiles-adam-c4k.76.5

**Violations:**
1. No template files found (config.toml, config.yaml, etc.)
2. No data.yml file for template variables
3. No template recipe in justfile
4. Configuration generation pipeline not implemented

**Expected Pipeline (if templating needed):**
```bash
mustache data.yml config.toml | envsubst | op inject > generated.toml
ln -s "$(pwd)/generated.toml" "<target-path>/config.toml"
```

**Generated Files:**
- Must use `generated.*` naming convention
- Must be gitignored
- All secrets injected by `op inject` stage (never committed)

**Required Action:**
- Evaluate if hotkeys configuration requires templating
- If yes: implement template recipe following ADR-004 pipeline
- If no: document this decision in README

---

### ADR-005: Data YAML Schema Specification

**Status:** VIOLATION (moderate)
**Issues:** dotfiles-adam-c4k.76.2, dotfiles-adam-c4k.76.3

**Violations:**
1. No `data.yml` file exists following ADR-005 schema
2. `hotkeys.yaml` exists but doesn't conform to schema structure
3. Current hotkeys.yaml is list-based, not schema-compliant:
   ```yaml
   # Current structure (non-compliant)
   zed:
     - evenly distribute current panes
     - quickly change settings...
   ```
4. Missing structured metadata for queryability

**Required Schema Structure (ADR-005):**
```yaml
# =============================================================================
# Aliases & Hotkeys
# =============================================================================
hotkeys:                      # Keyboard shortcuts (app-specific format)
  - key: "ctrl+shift+m"
    action: "open_myapp"
    context: "global"

# =============================================================================
# Target Directories
# =============================================================================
target-dir: "~/.config/hotkeys"

# OR structured form with named targets:
target-dir:
  config: "~/.config/hotkeys"
  data: "~/.local/share/hotkeys"
```

**Required Action:**
- Create `/private/etc/dotfiles/adam/keebs/data.yml`
- Migrate `hotkeys.yaml` data into proper schema format
- Ensure fields follow ADR-005 specifications for queryability
- Document any custom fields in README

---

### ADR-006: Secret Management with 1Password

**Status:** NOT APPLICABLE

The keebs module does not require secret management. No 1Password references needed.

---

### ADR-007: Service Module Conventions

**Status:** NOT APPLICABLE

The keebs module is NOT a service module. It manages keyboard shortcuts/hotkeys, not background processes. No start/stop/restart recipes needed.

---

## Issues Created

All violations have been tracked as beads issues under parent issue `dotfiles-adam-c4k.76`:

| Issue ID | Title | Severity | ADR |
|----------|-------|----------|-----|
| dotfiles-adam-c4k.76.1 | keebs: Missing justfile (ADR-002, ADR-003) | CRITICAL | 002, 003 |
| dotfiles-adam-c4k.76.2 | keebs: Missing data.yml schema (ADR-005) | MODERATE | 005 |
| dotfiles-adam-c4k.76.3 | keebs: hotkeys.yaml structure non-compliant (ADR-005) | MODERATE | 005 |
| dotfiles-adam-c4k.76.4 | keebs: No standard recipes implemented (ADR-002) | CRITICAL | 002 |
| dotfiles-adam-c4k.76.5 | keebs: Missing templating pipeline (ADR-004) | MODERATE | 004 |

---

## Remediation Roadmap

### Priority 1: Critical Infrastructure
1. **Create justfile** (addresses dotfiles-adam-c4k.76.1)
   - Add import statement
   - Add shell settings
   - Stub out all standard recipes

2. **Implement standard recipes** (addresses dotfiles-adam-c4k.76.4)
   - Add all recipes with [group()] attributes
   - Use null implementations for non-applicable recipes

### Priority 2: Data Compliance
3. **Create data.yml** (addresses dotfiles-adam-c4k.76.2)
   - Follow ADR-005 schema structure
   - Include hotkeys array
   - Define target directories

4. **Migrate hotkeys.yaml** (addresses dotfiles-adam-c4k.76.3)
   - Convert list-based structure to schema-compliant format
   - Update data.yml with hotkey entries
   - Consider archiving or removing old file

### Priority 3: Documentation
5. **Implement templating pipeline** (addresses dotfiles-adam-c4k.76.5)
   - Evaluate if needed for configuration generation
   - If yes: implement template recipe
   - If no: document decision

6. **Create README.md**
   - Explain module purpose (keyboard shortcuts/hotkeys)
   - Document configuration options
   - Explain any custom fields in data.yml

---

## Conformance Summary

| ADR | Status | Compliance |
|-----|--------|-----------|
| ADR-002 (Justfile Conventions) | NON_COMPLIANT | 0/100 |
| ADR-003 (Justfile Module Definition) | NON_COMPLIANT | 0/100 |
| ADR-004 (Configuration Templating Pipeline) | NON_COMPLIANT | 0/100 |
| ADR-005 (Data YAML Schema Specification) | NON_COMPLIANT | 0/100 |
| ADR-006 (Secret Management) | N/A | N/A |
| ADR-007 (Service Module Conventions) | N/A | N/A |

**Overall Module Conformance:** 0% (before remediation)

---

## Example Justfile Template

Here's a template justfile for the keebs module following all ADR requirements:

```just
import '../.build/just/lib.just'

set shell := ["bash", "-euo", "pipefail", "-c"]

# Lifecycle recipes
[group("lifecycle")]
install:
    @true

[group("lifecycle")]
clean:
    @true

[group("lifecycle")]
mktree:
    @mkdir -p "{{ config_directory() }}/hotkeys"

# Info recipes
[group("info")]
health:
    @true

[group("info")]
ls:
    @echo "Hotkeys module installed at: {{ justfile_directory() }}"

[group("info")]
ls-net:
    @echo "No network services"

# Build recipes
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

---

## Next Steps

1. Review this report and issues with team
2. Create justfile using template above
3. Create data.yml following ADR-005 schema
4. Migrate hotkeys.yaml data into data.yml
5. Create README.md with module documentation
6. Mark issues as completed as remediation progresses

---

**Report Generated:** 2026-02-25
**Review Tool:** ADR Module Review Agent
**Data File:** `/private/etc/dotfiles/adam/keebs_adr_review_summary.json`
