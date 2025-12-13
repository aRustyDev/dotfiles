---
id: 00000000-0000-0000-0000-000000000001
title: Validation Dashboard
created: 2025-12-12T00:00:00
updated: 2025-12-12T00:00:00
project: dotfiles
scope:
  - obsidian
type: reference
status: ✅ active
publish: false
tags:
  - docs
  - meta
  - validation
aliases:
  - Frontmatter Validation
related:
  - ref:
    description:
---

# Validation Dashboard

This dashboard identifies documents with non-compliant frontmatter.

---

## Invalid Status Values

Documents with status not matching the allowed emoji format:

```dataview
TABLE status AS "Current Status", type, scope
FROM "docs/notes"
WHERE status AND !contains(["📝 draft", "✅ active", "🔍 review", "📦 archived", "🚧 wip", "⚠️ deprecated"], status)
SORT file.name ASC
```

---

## Missing Required Fields

### Missing ID
```dataview
LIST
FROM "docs/notes"
WHERE !id
```

### Missing Project
```dataview
LIST
FROM "docs/notes"
WHERE !project
```

### Missing Scope
```dataview
LIST
FROM "docs/notes"
WHERE !scope
```

### Missing Type
```dataview
LIST
FROM "docs/notes"
WHERE !type
```

### Missing Status
```dataview
LIST
FROM "docs/notes"
WHERE !status
```

---

## Valid Status Reference

| Emoji | Status | Meaning |
|-------|--------|---------|
| 📝 | draft | Initial creation, incomplete |
| 🚧 | wip | Work in progress, actively being written |
| 🔍 | review | Ready for review/feedback |
| ✅ | active | Current, accurate, ready for use |
| ⚠️ | deprecated | Outdated, kept for reference |
| 📦 | archived | No longer relevant, historical |

---

## Valid Type Reference

| Type | Purpose |
|------|---------|
| guide | How-to walkthrough |
| reference | Quick lookup material |
| tutorial | Step-by-step learning |
| adr | Architecture Decision Record |
| runbook | Operational procedures |
| cheatsheet | Commands/syntax reference |
| note | General notes |

---

## Valid Scope Reference

| Scope | Description |
|-------|-------------|
| docker | Docker/containers |
| git | Version control |
| just | Justfile/task runner |
| k9s | Kubernetes CLI |
| zsh | Shell config |
| tmux | Terminal multiplexer |
| nvim | Neovim editor |
| nix | Nix/nix-darwin |
| terraform | Infrastructure |
| mcp | Model Context Protocol |
| ai | AI/ML tooling |
| obsidian | Obsidian config |
| general | Cross-cutting |

---

## Stats

Total docs: `$= dv.pages('"docs/notes"').length`
Valid status: `$= dv.pages('"docs/notes"').where(p => ["📝 draft", "✅ active", "🔍 review", "📦 archived", "🚧 wip", "⚠️ deprecated"].includes(p.status)).length`
