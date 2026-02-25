---
id: beads-ops-skill
title: Beads Operations Skill
created: 2026-02-24T00:00:00
updated: 2026-02-24T00:00:00
project: dotfiles
scope: ai
type: reference
status: active
publish: false
tags:
  - beads
  - issues
  - tracking
aliases:
  - beads
  - bd
  - issue tracking
related:
  - gastown-ops
---

# Beads Operations Skill

Comprehensive reference for `bd` CLI operations - issue tracking, hierarchies, labels, and database management.

## Activation Triggers

- "create issue"
- "beads"
- "bd"
- "track issue"
- "log finding"
- "issue hierarchy"
- "epic"
- "subtask"

## Core Concepts

### Issue Hierarchy

```
Epic (dotfiles-abc)
├── Task (dotfiles-abc.1)
│   ├── Subtask (dotfiles-abc.1.1)
│   └── Subtask (dotfiles-abc.1.2)
└── Task (dotfiles-abc.2)
```

- **Epic**: Top-level container for related work
- **Task**: Individual work items under an epic
- **Subtask**: Granular pieces of a task

### Issue ID Format

```
<prefix>-<hash>[.<child>][.<subchild>]

Examples:
  dotfiles-pmz        # Epic
  dotfiles-pmz.10     # Task under epic
  dotfiles-pmz.10.1   # Subtask under task
```

## Essential Commands

### Creating Issues

```bash
# Basic issue
bd create "Title of issue"

# With parent (creates hierarchy)
bd create "module: Description" --parent dotfiles-pmz.10

# Full options
bd create "module: Short description" \
  --parent <parent-id> \
  -d "Detailed description with context" \
  -l "label1,label2,severity" \
  --silent

# With specific type
bd create "Title" --type task
bd create "Title" --type epic
bd create "Title" --type bug
```

### Viewing Issues

```bash
# List all issues
bd list
bd list --limit 0        # Show all (no limit)
bd list --status open    # Filter by status

# Show single issue
bd show dotfiles-pmz.10

# Show children of an issue
bd children dotfiles-pmz.10

# Search issues
bd search "keyword"
bd search "module: keyword" --json
```

### Updating Issues

```bash
# Add notes
bd update <id> --notes "Progress update"

# Change status
bd close <id>
bd close <id> --notes "Reason for closing"
bd reopen <id>

# Modify labels
bd label add <id> "new-label"
bd label remove <id> "old-label"
```

### Database Management

```bash
# Initialize beads in a repo
bd init --prefix dotfiles

# Health check
bd doctor
bd doctor --fix
bd doctor --fix --yes   # Auto-fix without prompts

# Sync operations
bd sync                 # Sync JSONL <-> Dolt

# Version control (Dolt)
bd vc status
bd vc commit -m "message"
bd vc log
```

### Configuration

```bash
# View config
bd config get issue-prefix

# Set config
bd config set issue-prefix dotfiles-adam

# Config file location
.beads/config.yaml
```

## Labels & Severity

### Severity Scale

| Level | Criteria |
|-------|----------|
| S0 | Major refactor, breaking changes, cross-module impact |
| S1 | Significant work, architectural consideration |
| S2 | Moderate effort, multiple files |
| S3 | Simple change, single file |
| S4 | Trivial fix, one-liner |

### Type Labels

| Label | Meaning |
|-------|---------|
| `violation` | Directly contradicts spec/ADR |
| `misalignment` | Uses old/deprecated pattern |
| `gap` | Missing required element |
| `refine` | Works but could be improved |
| `bug` | Broken functionality |
| `cleanup` | Dead code, unused files |

### Scope Labels

| Label | Meaning |
|-------|---------|
| `repo-wide` | Affects entire repository |
| `review` | Needs review/inspection |

## Configuration File

Location: `.beads/config.yaml`

```yaml
# Backend selection
backend: dolt          # or: sqlite, jsonl

# Sync settings
sync:
  mode: dolt-native    # or: jsonl-primary
  branch: beads-sync

# Hooks (optional)
hooks:
  chain_strategy: before
  chain_timeout_ms: 5000
```

## Common Patterns

### Module Review Issues

```bash
# Create module review task
bd create "Review: module-name" \
  --parent dotfiles-pmz \
  -l "review" \
  --silent

# Create finding under module
bd create "module: Finding description" \
  --parent dotfiles-pmz.10 \
  -d "File: path/to/file, Line: N. Current: X, Expected: Y" \
  -l "violation,S2" \
  --silent
```

### Deduplication Check

```bash
# Before creating, check if exists
bd search "module: keyword" --json | jq '.[] | .id'
```

### Batch Updates

```bash
# Update parent after creating children
bd update dotfiles-pmz.10 --notes "Review complete. Created N issues."
```

## Troubleshooting

### "database not initialized"

```bash
# Initialize with prefix
bd init --prefix <prefix>

# Or fix existing
bd doctor --fix --yes
```

### "issue_prefix config is missing"

```bash
bd config set issue-prefix <prefix>
```

### "table not found: issues"

Database schema is incomplete:

```bash
bd doctor --fix --yes
bd sync
```

### "Dolt server unreachable"

For embedded mode, ensure `.beads/config.yaml` doesn't specify server mode.

For server mode:
```bash
gt dolt start    # If using gastown
# or
bd dolt start    # Direct beads
```

### Count Mismatch (Dolt vs JSONL)

```bash
bd sync
bd vc commit -m "sync"
```

## Integration with Gastown

When using beads within gastown rigs:

1. **Rig beads use redirect**: Check `.beads/redirect` for path to actual database
2. **Prefix matters**: Each rig needs its own `issue-prefix` configured
3. **Dolt server shared**: All rigs use the workspace Dolt server

### Rig Database Setup

```bash
# From rig directory
cd /path/to/rig/mayor/rig
bd init --prefix <rig-prefix>
bd config set issue-prefix <rig-prefix>
```

## Epic IDs Reference (dotfiles)

| Epic | ID | Purpose |
|------|-----|---------|
| Dotfiles Review | dotfiles-pmz | Module coverage tracking |
| Justfile Review | dotfiles-4th | ADR-002 violations, lib.just issues |
| Module Review | dotfiles-1pw | ADR-003 module classification |
| Template Review | dotfiles-02p | ADR-004 pipeline issues |
| Data Schema | dotfiles-iok | ADR-005 schema issues |
| Secrets Review | dotfiles-c0q | ADR-006 secret management |
| Services Review | dotfiles-k35 | ADR-007 service conventions |

## Formulas & Molecules

Beads includes formula/molecule workflow capabilities for structured work.

### Formula Commands

```bash
# List available formulas
bd formula list

# Show formula details
bd formula show <name>

# Cook formula into proto (template bead)
bd cook <formula> --persist          # Persist to DB
bd cook <formula> --dry-run          # Preview only
bd cook <formula> --var key=value    # With variables
```

### Molecule Commands

```bash
# Pour proto into persistent molecule
bd mol pour <proto> --var key=value

# Create ephemeral wisp
bd mol wisp <proto> --var key=value

# List molecules/protos
bd mol list

# Show molecule details
bd mol show <id>

# Squash molecule to digest
bd mol squash <id>

# Burn (discard) wisp
bd mol burn <id>
```

### Workflow

```
Formula (.formula.toml)
    ↓ bd cook --persist
Proto (template in DB with "template" label)
    ↓ bd mol pour / bd mol wisp
Mol (persistent) or Wisp (ephemeral)
```

## MCP Integration

If using beads MCP server:

```bash
# Tools available
mcp__beads__create_issue
mcp__beads__search_issues
mcp__beads__update_issue
```

## Best Practices

1. **Always use `--silent`** in automated scripts to suppress interactive prompts
2. **Check for duplicates** before creating issues
3. **Use hierarchical IDs** for related work (parent → child → grandchild)
4. **Include file/line references** in descriptions for code issues
5. **Update parent notes** after completing child issue creation
6. **Use appropriate severity** - S0/S1 for architectural, S3/S4 for simple fixes
