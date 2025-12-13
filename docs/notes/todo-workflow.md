---
id: c3d4e5f6-a7b8-9012-cdef-345678901234
title: Unified TODO Workflow
created: 2025-12-13T00:00:00
updated: 2025-12-13T00:00:00
project: dotfiles
scope:
  - obsidian
  - general
type: guide
status: ✅ active
publish: true
tags:
  - workflow
  - todo
  - tasks
  - productivity
aliases:
  - TODO Workflow
  - Task Aggregation
related:
  - ref: "[[obsidian-task-plugins]]"
    description: Plugin comparison
  - ref: "[[data-dashboard]]"
    description: Data visualizations
---

# Unified TODO Workflow

How to create TODOs throughout your repository and aggregate them in Obsidian.

---

## Overview

This workflow enables:

1. **Write TODOs anywhere** - in code comments, markdown files, or dedicated TODO.md files
2. **Aggregate in Obsidian** - see all TODOs across the repo in one dashboard
3. **Track progress** - use Tasks plugin for dates, priorities, and status

---

## TODO Formats

### In Markdown Files

Use Tasks plugin syntax:

```markdown
- [ ] Task description 📅 2025-01-15 ⏫
- [ ] Another task #todo
- [/] In progress task
```

### In Code Comments

Standard TODO comments (grep-able):

```python
# TODO: Implement error handling
# FIXME: This breaks with empty input
# XXX: Temporary workaround
# HACK: Quick fix, needs refactor
```

```typescript
// TODO(username): Add validation
// FIXME: Memory leak here
```

### In Dedicated TODO.md Files

Each directory can have a `TODO.md`:

```markdown
# TODO: Module Name

## High Priority
- [ ] Critical task ⏫

## Tasks
- [ ] Regular task

## Blocked
- [ ] Waiting on X ❌
```

---

## Obsidian Aggregation

### All Repo TODOs Dashboard

Create a dashboard to aggregate all TODOs:

````markdown
## All Open Tasks

```tasks
not done
path does not include .obsidian
path does not include node_modules
sort by priority
group by folder
limit 50
```
````

### By Scope/Area

````markdown
## Docker Tasks

```tasks
not done
path includes docker
sort by due
```

## MCP Tasks

```tasks
not done
path includes mcp
sort by priority
```
````

### Code TODOs (via Dataview)

Scan for TODO comments in code:

````markdown
```dataviewjs
const files = app.vault.getFiles()
  .filter(f => f.extension === 'md' && f.path.includes('TODO'));

dv.table(
  ["File", "Location"],
  files.map(f => [
    dv.fileLink(f.path),
    f.parent.path
  ])
);
```
````

---

## Quick Capture Workflow

### 1. Daily Note Capture

In your daily note template:

```markdown
## Quick Tasks

- [ ] #inbox

## Captured Ideas

-
```

### 2. Process Inbox

Weekly, process `#inbox` items:

```tasks
not done
tags include #inbox
sort by created
```

Move to appropriate location or add proper dates/priority.

### 3. Weekly Review

Review all tasks by status:

````markdown
## Overdue

```tasks
not done
due before today
```

## Due This Week

```tasks
not done
due after yesterday
due before next week
```

## In Progress

```tasks
status.type is IN_PROGRESS
```

## Recently Completed

```tasks
done
done after last week
```
````

---

## File Organization

### Recommended Structure

```
docs/
├── notes/
│   ├── todo-workflow.md      # This guide
│   └── obsidian-task-plugins.md
├── dashboards/
│   ├── data.md               # Data charts
│   └── tasks.md              # Task aggregation dashboard
└── todos/                     # Collected TODO files
    ├── docker.md
    ├── mcp.md
    └── backlog.md

# Component-level TODOs
docker/TODO.md
kube/TODO.md
zsh/TODO.md
```

### Create Tasks Dashboard

Create `docs/dashboards/tasks.md`:

````markdown
---
id: ...
title: Tasks Dashboard
type: dashboard
status: ✅ active
---

# Tasks Dashboard

## Overdue ⚠️

```tasks
not done
due before today
sort by due
```

## Due Today

```tasks
not done
due on today
sort by priority
```

## Due This Week

```tasks
not done
due after today
due before in 7 days
sort by due
```

## High Priority

```tasks
not done
priority is high
sort by due
```

## By Area

### Docker

```tasks
not done
(path includes docker) OR (tags include #docker)
limit 10
```

### MCP

```tasks
not done
(path includes mcp) OR (tags include #mcp)
limit 10
```

## Recently Completed ✅

```tasks
done
done after 7 days ago
sort by done reverse
limit 20
```
````

---

## External TODO Scanning

### Grep Script for Code TODOs

Create a script to scan code for TODOs:

```bash
#!/bin/bash
# scripts/scan-todos.sh

echo "# Code TODOs - $(date +%Y-%m-%d)"
echo ""

# Find TODOs in code files
grep -rn --include="*.py" --include="*.ts" --include="*.js" --include="*.go" --include="*.rs" \
  -E "(TODO|FIXME|XXX|HACK):" . 2>/dev/null | \
  grep -v node_modules | \
  grep -v ".git" | \
  while read line; do
    file=$(echo "$line" | cut -d: -f1)
    linenum=$(echo "$line" | cut -d: -f2)
    content=$(echo "$line" | cut -d: -f3-)
    echo "- [ ] \`$file:$linenum\` -$content"
  done
```

### Import to Obsidian

Run the script and save output to `docs/todos/code-todos.md`:

```bash
./scripts/scan-todos.sh > docs/todos/code-todos.md
```

---

## Tag Strategy

Use tags consistently for filtering:

| Tag | Purpose | Example |
|-----|---------|---------|
| `#todo` | Generic task | Any actionable item |
| `#inbox` | Unprocessed | Quick captures |
| `#blocked` | Waiting | Dependency on external |
| `#later` | Someday/Maybe | Low priority backlog |
| `#quick` | < 5 minutes | Quick wins |

### Query by Tag

```tasks
not done
tags include #quick
limit 5
```

---

## Keyboard Shortcuts

Configure in Obsidian:

| Action | Suggested Shortcut |
|--------|--------------------|
| Create task | `Cmd+Shift+T` |
| Toggle task | `Cmd+Enter` |
| Open Tasks modal | `Cmd+Shift+M` |
| Add due date | `Cmd+D` |

---

## Integration with Other Tools

### Just Command

Add to `justfile`:

```just
# Scan and update code TODOs
todos:
    ./scripts/scan-todos.sh > docs/todos/code-todos.md
    echo "Updated docs/todos/code-todos.md"
```

### Pre-commit Hook (Optional)

Warn on new TODOs without tickets:

```yaml
# .pre-commit-config.yaml
- repo: local
  hooks:
    - id: check-todos
      name: Check TODO format
      entry: ./scripts/check-todos.sh
      language: script
      types: [python, javascript, typescript]
```

---

## Summary

1. **Write TODOs** using Tasks plugin syntax in markdown
2. **Use standard comments** (`TODO:`, `FIXME:`) in code
3. **Aggregate in dashboards** using Tasks plugin queries
4. **Process weekly** using inbox/review workflow
5. **Scan code TODOs** with scripts for visibility

---

> [!info] Metadata
> **Scope**: `= this.scope`
> **Type**: `= this.type`
> **Status**: `= this.status`
