---
id: b2c3d4e5-f6a7-8901-bcde-f23456789012
title: Obsidian Task Plugin Comparison
created: 2025-12-13T00:00:00
updated: 2025-12-13T00:00:00
project: dotfiles
scope:
  - obsidian
type: reference
status: ✅ active
publish: true
tags:
  - obsidian
  - tasks
  - plugins
  - workflow
aliases:
  - Task Plugins
  - Tasks vs Checklist vs Reminder
related:
  - ref: "[[todo-workflow]]"
    description: Unified TODO workflow guide
---

# Obsidian Task Plugin Comparison

Comparison of task-related plugins to avoid feature overlap and define clear use cases.

---

## Plugin Overview

| Plugin | Primary Purpose | Query Language | Cross-File | Dates | Notifications |
|--------|-----------------|----------------|------------|-------|---------------|
| **Tasks** | Task queries & management | Custom DSL | ✅ Yes | ✅ Full | ❌ No |
| **Reminder** | Time-based alerts | None | ⚠️ Limited | ✅ Due dates | ✅ Yes |
| **Checklist** | Aggregated tag view | Tag-based | ✅ Yes | ❌ No | ❌ No |
| **Dataview** | General queries | DQL/JS | ✅ Yes | ✅ Full | ❌ No |

---

## Tasks Plugin

**Best For:** Complex task management with queries, recurring tasks, dependencies.

### Features

- Query tasks across vault with powerful filters
- Custom statuses (`/` in-progress, `-` cancelled)
- Date fields: due, scheduled, start, created, done, cancelled
- Recurring tasks
- Priority levels
- Task dependencies (experimental)

### Syntax

```markdown
- [ ] Task description 📅 2025-01-15 ⏫
- [/] In progress task
- [x] Completed ✅ 2025-01-10
- [-] Cancelled ❌ 2025-01-10
```

### Query Example

```tasks
not done
due before tomorrow
sort by priority
group by folder
```

### When to Use

- ✅ Project-wide task tracking
- ✅ Complex filtering (by date, priority, path)
- ✅ Recurring tasks
- ✅ Task dashboards

### When NOT to Use

- ❌ Simple checklists that don't need queries
- ❌ When you need real-time notifications

---

## Reminder Plugin

**Best For:** Time-sensitive tasks that need desktop/mobile notifications.

### Features

- Desktop notifications at specified times
- Integrates with Tasks plugin dates
- Reminder format options (Obsidian-native, Tasks emoji)
- Snooze functionality

### Syntax

```markdown
- [ ] Meeting prep (@2025-01-15 09:00)
- [ ] Call John 📅 2025-01-15 ⏰ 14:00
```

### When to Use

- ✅ Appointments and time-sensitive tasks
- ✅ Deadlines you must not miss
- ✅ Daily reminders

### When NOT to Use

- ❌ General task tracking
- ❌ Tasks without specific times

---

## Checklist Plugin

**Best For:** Quick aggregated view of tagged items across vault.

### Features

- Groups items by tag (#todo, #task, etc.)
- Sidebar panel view
- Auto-updates as you check items
- Simple, lightweight

### Syntax

```markdown
- [ ] Fix bug #todo
- [ ] Review PR #task
- [ ] Read article #later
```

### When to Use

- ✅ Quick overview of all tagged items
- ✅ Simple tag-based organization
- ✅ Lightweight todo scanning

### When NOT to Use

- ❌ Complex queries
- ❌ Date-based filtering
- ❌ Priority management

---

## Dataview (Task Queries)

**Best For:** Custom task views integrated with other metadata.

### Features

- Query any frontmatter or inline fields
- Full JavaScript support
- Combine task data with note metadata
- Maximum flexibility

### Query Example

```dataview
TASK
FROM "docs"
WHERE !completed AND contains(tags, "#todo")
SORT file.mtime DESC
```

### When to Use

- ✅ Tasks combined with note metadata
- ✅ Custom visualizations
- ✅ Complex logic not supported by Tasks plugin

### When NOT to Use

- ❌ Simple task lists (overkill)
- ❌ When Tasks plugin syntax suffices

---

## Recommended Configuration

### Avoid Overlap

| Use Case | Primary Plugin | Backup |
|----------|----------------|--------|
| Project tasks with dates | Tasks | Dataview |
| Time-based reminders | Reminder | - |
| Quick tag aggregation | Checklist | - |
| Dashboard visualizations | Dataview | Tasks |
| Recurring tasks | Tasks | - |
| Priority management | Tasks | - |

### Suggested Setup

1. **Tasks Plugin** - Primary task management
   - Use for all dated tasks
   - Use custom statuses (in-progress, cancelled)
   - Create task dashboards

2. **Reminder Plugin** - Notifications only
   - Add `⏰` times only to tasks needing alerts
   - Don't duplicate due dates

3. **Checklist Plugin** - Tag scanning only
   - Use for `#later`, `#maybe`, `#blocked` tags
   - Quick sidebar glance

4. **Dataview** - Advanced queries
   - Aggregate tasks with note metadata
   - Custom dashboard charts

---

## Task Syntax Standard

Use consistent syntax across all files:

```markdown
# Standard task (Tasks plugin)
- [ ] Description 📅 2025-01-15 ⏫

# With reminder time
- [ ] Description 📅 2025-01-15 ⏰ 09:00 ⏫

# Tag for Checklist aggregation
- [ ] Description #todo

# Combined
- [ ] Description 📅 2025-01-15 ⏫ #todo
```

### Priority Indicators

| Emoji | Meaning | Tasks Plugin |
|-------|---------|--------------|
| ⏫ | High | `priority: high` |
| 🔼 | Medium | `priority: medium` |
| 🔽 | Low | `priority: low` |

### Status Indicators

| Checkbox | Status | Symbol |
|----------|--------|--------|
| `[ ]` | Todo | space |
| `[x]` | Done | x |
| `[/]` | In Progress | / |
| `[-]` | Cancelled | - |

---

## See Also

- [[todo-workflow]] - Unified TODO aggregation workflow
- [[data-dashboard]] - Data visualization dashboard

---

> [!info] Metadata
> **Scope**: `= this.scope`
> **Type**: `= this.type`
> **Status**: `= this.status`
