---
id: b2c3d4e5-f6a7-8901-bcde-f23456789012
title: "Plan: Standardize Markdown Frontmatter Across Repository"
created: 2025-12-13T00:00:00
updated: 2025-12-13T00:00:00
project: dotfiles
scope:
  - obsidian
  - general
type: plan
status: 🚧 in-progress
publish: false
tags:
  - frontmatter
  - standardization
  - obsidian
  - metadata
aliases:
  - Frontmatter Standardization Plan
related:
  - ref: "[[adr-frontmatter-standard]]"
    description: Frontmatter schema definition
plan:
  phase: execution
  priority: high
  effort: L
---

# Plan: Standardize Markdown Frontmatter Across Repository

## Objective

Add standardized YAML frontmatter to all markdown files in the repository (excluding `.ai/*` and `.claude/.wip/*`) to enable proper Obsidian knowledge graph visualization.

---

## Scope

### Included Directories
- `docs/` - Documentation (74 files, 42 already have frontmatter)
- `.obsidian/` - Obsidian config (9 files, all have frontmatter - verify only)
- `.context/` - Context files (25 files, 0 have frontmatter)
- `git/` - Git configurations and commands
- `kube/` - Kubernetes configurations
- `docker/` - Docker configurations
- `nix-darwin/` - Nix configurations
- `terraform/` - Terraform configurations
- `gix/` - Gix configurations
- `.data/` - Data/bookmarks
- `.claude/commands/` - Claude commands (not .wip)
- Root level markdown files

### Excluded Directories
- `.ai/*` - Per user request (WIP files need review)
- `.claude/.wip/*` - Per user request (WIP files need review)

### Estimated File Count
- ~270-300 files to process (646 total minus ~237 .claude/.wip minus ~100+ .ai)

---

## Frontmatter Schema (from ADR-003)

### Required Fields
```yaml
---
id: <uuid-v4>                     # Unique identifier
title: "<Document Title>"          # From H1 or filename
created: <ISO-8601>               # Creation date
updated: <ISO-8601>               # Last modified
project: dotfiles                 # Project name
scope:
  - <category>                    # Domain areas
type: <document-type>             # Classification
status: <emoji> <status>          # Current state
publish: false                    # Publication flag
tags:
  - <tag>                         # Topic tags
aliases:
  - <alias>                       # Alternative names
related: []                       # Links to other docs
---
```

### Type Mappings (by directory/content)
| Directory/Pattern | Type | Default Scope |
|-------------------|------|---------------|
| `docs/notes/adr/` | adr | architecture |
| `docs/notes/analysis/` | analysis | varies |
| `docs/notes/plans/` | plan | varies |
| `**/README.md` | reference | varies by parent |
| `**/TODO.md` | plan | varies by parent |
| `**/CHANGELOG.md` | changelog | varies by parent |
| `git/commands/` | reference | git |
| `kube/plugin/` | reference | kubernetes |
| `docker/` | reference | docker |
| `.data/bookmarks/` | reference | general |
| `.context/` | reference | ai |

### Status Defaults
- Files with no existing status → `📝 draft`
- README files → `✅ active`
- TODO files → `🚧 in-progress`

---

## Execution Strategy

### Phase 1: High-Value Documents (docs/)
Process `docs/` directory first - highest visibility, some already standardized.

1. `docs/notes/adr/` - ADR documents (add adr-specific fields)
2. `docs/notes/analysis/` - Analysis documents
3. `docs/notes/plans/` - Plan documents (add plan-specific fields)
4. `docs/notes/` - Other notes
5. `docs/src/` - Source documentation
6. `docs/` root files

### Phase 2: Configuration Documentation
Process tool/config directories.

1. `git/` - Git configs and commands
2. `kube/` - Kubernetes documentation
3. `docker/` - Docker documentation
4. `nix-darwin/` - Nix documentation
5. `terraform/` - Terraform configurations

### Phase 3: Support Files
Process remaining directories.

1. `.context/` - Context files
2. `.data/` - Bookmarks and data files
3. `.claude/commands/` - Command documentation (not .wip)
4. `gix/` - Gix documentation
5. Root level files (README.md, etc.)

### Phase 4: Verification
1. Run frontmatter validator on all processed files
2. Verify Obsidian graph shows proper connections
3. Fix any validation errors

---

## Implementation Details

### For Each File

1. **Read current content**
2. **Check for existing frontmatter**
   - If complete: skip or verify only
   - If partial: merge with standard fields
   - If none: generate new frontmatter
3. **Determine metadata**:
   - `id`: Generate new UUID v4
   - `title`: Extract from H1 heading or derive from filename
   - `created`: Use git first commit date or file creation date
   - `updated`: Use git last commit date or current date
   - `type`: Infer from directory/content pattern
   - `scope`: Infer from directory hierarchy
   - `tags`: Extract from content keywords or directory
   - `status`: Default based on file type
4. **Write updated file**

### Commit Strategy
- Commit after each phase (4 commits total)
- Commit message format: `docs: standardize frontmatter for <directory>`

---

## Critical Files Reference

### Schema Definition
- `docs/notes/adr/adr-frontmatter-standard.md`

### Validation Script
- `scripts/validate-frontmatter.py`

### Templates (for reference)
- `.obsidian/templates/`

### FileClass Definitions
- `.obsidian/fileClasses/`

---

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Overwrite existing valid frontmatter | Check and merge, don't replace |
| Wrong type/scope inference | Use conservative defaults, can refine later |
| Break existing Obsidian links | Preserve aliases and related fields |
| Large commit size | Batch by directory/phase |

---

## Success Criteria

- [ ] All markdown files (in scope) have valid frontmatter
- [ ] Frontmatter validator passes on all files
- [ ] Obsidian graph shows connected nodes by scope/type
- [ ] No broken links in existing documents

---

> [!info] Metadata
> **Phase**: `= this.plan.phase`
> **Priority**: `= this.plan.priority`
> **Effort**: `= this.plan.effort`
