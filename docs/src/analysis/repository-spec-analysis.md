# Dotfiles Repository Specification Analysis

**Date:** 2026-02-24
**Purpose:** Broad review to establish ADRs and identify violations

## Executive Summary

This analysis examines the dotfiles repository structure, patterns, and inconsistencies to inform the creation of Architecture Decision Records (ADRs) that will define the repository specification.

---

## 1. Repository Overview

| Metric | Value |
|--------|-------|
| Total Directories | 80+ visible, 12+ hidden |
| Justfiles | 100+ |
| Brewfiles | 9 |
| .meta.json files | 161 |
| Templated configs | 153+ (op:// references) |
| Existing ADRs | 5 |

**Core Infrastructure:**
- Nix-Darwin/Home-Manager as underlying system
- Just (command runner) for orchestration
- Homebrew for package management
- 1Password for secret management
- Beads/Dolt for issue tracking

---

## 2. Proposed ADR Topics (Priority Order)

### ADR-001: Justfile Conventions
**Status:** To Draft
**Scope:** Repository-wide

Key decisions needed:
1. Use just's built-in directory functions (`data_local_directory()`, `config_directory()`, etc.) NOT XDG env vars
2. Standard recipe names: `install`, `clean`, `status`, `health`
3. Recipe grouping conventions
4. Shared library imports (`lib.just`)
5. Shell settings (`set shell := ["bash", "-euo", "pipefail", "-c"]`)

**Observed Patterns:**
- Most justfiles import `.build/just/lib.just`
- `install` is the well-known entry point called by parent justfiles
- Recipe groups used inconsistently

**Anti-patterns to Document:**
- Using `env("XDG_*")` instead of just's built-in functions
- Direct `brew install` instead of `brew bundle`
- Inline secrets instead of op:// references

---

### ADR-002: Configuration Templating Pipeline
**Status:** To Draft
**Scope:** Repository-wide

The canonical pipeline should be:
```
source.toml (template)
  → mustache (data.yml)
  → envsubst (env vars)
  → op inject (secrets)
  → configd.toml (gitignored)
  → ln -s <dotdir>/<target>
```

**Observed Patterns (Inconsistent):**
1. `mustache data.yml config.toml | envsubst | op inject > configd.toml` (Meilisearch)
2. `cat config | envsubst | op inject -f -o` (Git)
3. `docker compose config | envsubst` (Docker)
4. Direct op:// in YAML (various)

**Anti-patterns:**
- Skipping stages of the pipeline
- Mixing templating syntaxes in same file (mustache + envsubst)
- Not gitignoring generated configs

---

### ADR-003: Directory Structure Conventions
**Status:** To Draft
**Scope:** Repository-wide

Standard module structure:
```
<module>/
├── justfile           # Required: orchestration
├── brewfile           # If has brew dependencies
├── config.toml        # Template config (mustache)
├── data.yml           # Template variables
├── README.md          # Documentation
├── .meta.json         # Module metadata
├── configs/           # Additional config templates (optional)
└── files/             # Static files to copy (optional)
```

**Observed Inconsistencies:**
- Some use `configs/`, others inline
- Some have `files/`, some have `data/`, some both
- Brewfile placement varies (root vs nested)

---

### ADR-004: Dependency Management (Brewfiles)
**Status:** To Draft
**Scope:** Repository-wide

Decisions needed:
1. Every module with brew dependencies MUST have a `brewfile`
2. `install` recipe MUST use `brew bundle` not `brew install`
3. Brewfile lives at module root
4. Brewfile format: simple `brew "formula"` lines

**Current State:**
- 9 brewfiles found
- Some modules use `brew install` directly
- Some reference brewfiles but don't invoke them

---

### ADR-005: Symlink and Install Patterns
**Status:** To Draft
**Scope:** Repository-wide

`install` recipe contract:
1. Called by parent justfiles via `just -f <module>/justfile install`
2. Accepts optional `dotdir` parameter for target location
3. Steps: dependencies → mktree → generate config → symlink
4. Must be idempotent

**Target locations use just functions:**
- `config_directory()` → ~/.config
- `data_local_directory()` → ~/.local/share
- `cache_directory()` → ~/.cache

---

### ADR-006: Secret Management with 1Password
**Status:** To Draft
**Scope:** Repository-wide

Pattern:
- Secrets referenced as `op://vault/item/field` in templates
- `op inject` called at runtime, never committed
- Generated configs with secrets are gitignored
- Dev configs may omit secrets for local testing

---

### ADR-007: Health Check and Status Recipes
**Status:** To Draft
**Scope:** Services (databases, background processes)

All service modules should have:
- `health` - Quick endpoint/process check
- `status` - Comprehensive state report
- `logs` - View logs (if applicable)
- `start` / `stop` / `restart` - Lifecycle management

---

### ADR-008: Staged Setup Pattern
**Status:** To Draft
**Scope:** Complex services

For services requiring incremental configuration:
- Stage 1: Basic install, insecure, validation
- Stage 2: Integration, health checks, API access
- Stage 3: Production hardening (SSL, auth, persistence)

Recipe groups: `[group("stage1")]`, `[group("stage2")]`, `[group("stage3")]`

---

## 3. Identified Violation Categories

For creating beads issues, violations fall into these categories:

| Category | Description | Severity |
|----------|-------------|----------|
| `justfile-convention` | Violates justfile patterns | Medium |
| `template-pipeline` | Incorrect templating approach | High |
| `directory-structure` | Non-standard module layout | Low |
| `dependency-mgmt` | Brewfile/install issues | Medium |
| `secret-handling` | Exposed or mismanaged secrets | Critical |
| `missing-recipe` | Required recipe not present | Low |
| `anti-pattern` | Uses deprecated/dropped pattern | Medium |

---

## 4. Known Anti-Patterns (Previous Partial Patterns)

These patterns were tried and should be avoided:

1. **XDG Env Var Pattern** (Dropped)
   - Using `env("XDG_CONFIG_HOME")` etc.
   - Replace with: `config_directory()`, `data_local_directory()`, etc.

2. **Direct brew install** (Dropped)
   - Using `brew install <formula>` in recipes
   - Replace with: `brew bundle` with brewfile

3. **Mixed Template Syntax** (Problematic)
   - Combining `{{mustache}}` and `${envsubst}` in same file
   - Solution: Clear pipeline stages

4. **Inline op:// in source** (Problematic)
   - Putting `op://` directly in tracked config files
   - Solution: Only in generated gitignored files OR properly templated

---

## 5. Analysis Plan (Iterative Deep Dive)

### Phase 1: Core Infrastructure
- [ ] `.build/just/lib.just` - Shared library review
- [ ] Root `justfile` - Orchestration patterns
- [ ] `.meta/` - Schema and validation

### Phase 2: High-Traffic Modules
- [ ] `git/` - Most commonly used
- [ ] `zsh/` - Shell configuration
- [ ] `docker/` - Complex orchestration example

### Phase 3: Database Modules
- [ ] `databases/meilisearch/` - Recently touched
- [ ] `databases/` - Parent justfile
- [ ] Other database modules (pattern propagation)

### Phase 4: Remaining Modules
- [ ] Batch analysis by category
- [ ] Completeness audit

---

## 6. Next Steps

1. **Review this analysis** with repository owner
2. **Draft ADRs** in conversation, get approval
3. **Create ADRs** using `adrs new` CLI
4. **Deep dive** into Phase 1 modules
5. **Create violation issues** using `bd create` with labels

---

## Appendix: Key Files Reference

| File | Purpose |
|------|---------|
| `.build/just/lib.just` | Shared justfile library |
| `.meta/schema.json` | Module metadata schema |
| `adrs.toml` | ADR CLI configuration |
| `.beads/config.yaml` | Beads issue tracking config |
| `docs/devrag/config.json` | DevRAG search config |
