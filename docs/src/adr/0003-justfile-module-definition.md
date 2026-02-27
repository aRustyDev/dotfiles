---
number: 3
title: Justfile Module Definition
date: 2026-02-25
status: proposed
tags:
  - justfile
  - modules
  - architecture
---

# 3. Justfile Module Definition

Date: 2026-02-25

## Status

Proposed

## Context

The repository contains various types of justfiles serving different purposes:

- Leaf justfiles that manage specific tools/configs (e.g., `git/justfile`, `docker/justfile`)
- Parent justfiles that orchestrate child justfiles (e.g., root `justfile`, `databases/justfile`)
- Helper justfiles that provide shared recipes for import (e.g., `.build/just/lib.just`)

A clear distinction is needed to understand when a justfile constitutes a "module" versus a helper or orchestration file.

## Decision

### 1. Module Definition

A justfile is considered a **module** if it meets ANY of the following criteria:

- It can be independently installed
- It benefits from direct command syntax (e.g., `just docker run`, `just git hooks`)
- It has no child justfiles (leaf node in the justfile hierarchy)

### 2. Non-Module Justfiles

The following are explicitly NOT modules:

| Type | Description | Example |
|------|-------------|---------|
| Helper justfile | Provides shared recipes for import | `.build/just/lib.just` |
| Proxy justfile | Orchestrates calls to child justfiles | Root `justfile`, `databases/justfile` |

### 3. No Manifest Requirement

Modules do **not** require a manifest file (e.g., `.meta.json`). The `.meta.json` pattern is deprecated for new modules.

### 4. Typical Module Structure

While no files are strictly required beyond the justfile, typical modules may include:

```
<module>/
├── justfile        # Required: module orchestration
├── brewfile        # If brew dependencies exist
├── config.toml     # Config template (if applicable)
├── data.yml        # Template variables (if applicable)
└── README.md       # Recommended: documentation
```

### 5. Module Identification

To determine if a directory contains a module:

1. Check if it has a `justfile`
2. Check if that justfile has child justfiles it orchestrates
3. If no children → it's a module
4. If only orchestrates children → it's a proxy justfile

## Consequences

### Easier

- Clear mental model for repository structure
- Simplified module creation (no manifest required)
- Easier to identify what can be independently installed

### More Difficult

- Existing `.meta.json` files become technical debt
- Some edge cases may require judgment calls

## Anti-patterns

1. **Creating modules that only proxy to children**
   ```
   # Bad: databases/justfile is a proxy, not a module
   # It should not implement install logic itself, only call children
   ```

2. **Requiring .meta.json for new modules**
   ```
   # Bad: Creating .meta.json for new modules
   # The .meta.json pattern is deprecated
   ```

3. **Helper justfiles with install recipes**
   ```
   # Bad: lib.just should not have an install recipe
   # Helper justfiles provide shared utilities, not installation logic
   ```

## Migration Notes

Existing `.meta.json` files will remain but should not be created for new modules. A future cleanup effort may consolidate or remove these files.
