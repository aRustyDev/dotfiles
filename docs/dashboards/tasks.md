---
id: d4e5f6a7-b8c9-0123-def0-456789012345
title: Tasks Dashboard
created: 2025-12-13T00:00:00
updated: 2025-12-13T00:00:00
project: dotfiles
scope:
  - obsidian
  - meta
type: dashboard
status: ✅ active
publish: true
tags:
  - dashboard
  - tasks
  - todo
aliases:
  - Task Overview
  - TODO Dashboard
related:
  - ref: "[[todo-workflow]]"
    description: TODO workflow guide
  - ref: "[[obsidian-task-plugins]]"
    description: Plugin comparison
  - ref: "[[data]]"
    description: Data analytics dashboard
---

# Tasks Dashboard

Aggregated view of all tasks across the repository.

---

## Overdue ⚠️

```tasks
not done
due before today
path does not include .obsidian
path does not include node_modules
sort by due
limit 20
```

---

## Due Today 📅

```tasks
not done
due on today
path does not include .obsidian
sort by priority
```

---

## Due This Week 📆

```tasks
not done
due after today
due before in 7 days
path does not include .obsidian
sort by due
limit 20
```

---

## High Priority ⏫

```tasks
not done
priority is high
path does not include .obsidian
sort by due
limit 15
```

---

## In Progress 🔄

```tasks
status.type is IN_PROGRESS
path does not include .obsidian
sort by due
```

---

## By Area

### Docker 🐳

```tasks
not done
(path includes docker) OR (description includes #docker)
path does not include .obsidian
limit 10
```

### MCP 🔌

```tasks
not done
(path includes mcp) OR (path includes .ai/mcp)
path does not include .obsidian
limit 10
```

### Kubernetes ☸️

```tasks
not done
(path includes kube) OR (description includes #kubernetes)
path does not include .obsidian
limit 10
```

### Shell/Zsh 🐚

```tasks
not done
(path includes zsh) OR (path includes shell)
path does not include .obsidian
limit 10
```

### Obsidian 📝

```tasks
not done
(path includes obsidian) OR (path includes docs/notes)
path does not include .obsidian/plugins
limit 10
```

---

## Unprocessed Inbox 📥

```tasks
not done
(description includes #inbox) OR (description includes #later)
sort by created
limit 20
```

---

## Blocked ❌

```tasks
not done
(description includes #blocked) OR (description includes ❌)
sort by created
```

---

## Recently Completed ✅

```tasks
done
done after 7 days ago
path does not include .obsidian
sort by done reverse
limit 25
```

---

## Task Statistics

```dataviewjs
const tasks = dv.pages()
  .where(p => !p.file.path.includes('.obsidian'))
  .file.tasks;

const total = tasks.length;
const done = tasks.where(t => t.completed).length;
const open = total - done;
const today = new Date();
today.setHours(0, 0, 0, 0);

const overdue = tasks.where(t => !t.completed && t.due && t.due < today).length;
const dueToday = tasks.where(t => !t.completed && t.due &&
  t.due.toISOString().split('T')[0] === today.toISOString().split('T')[0]).length;

dv.table(
  ["Metric", "Count"],
  [
    ["Total Tasks", total],
    ["Open", open],
    ["Completed", done],
    ["Overdue", overdue],
    ["Due Today", dueToday],
    ["Completion Rate", `${Math.round((done/total)*100)}%`]
  ]
);
```

---

## Quick Actions

- [[todo-workflow|📋 TODO Workflow Guide]]
- [[obsidian-task-plugins|🔌 Plugin Reference]]
- Create new task: `Cmd+Shift+T`

---

> [!info] Metadata
> **Type**: `= this.type`
> **Status**: `= this.status`
