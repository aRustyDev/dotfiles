---
id: 7a8b9c0d-1e2f-3a4b-5c6d-7e8f9a0b1c2d
title: "MCP Comparison: Memory (Graphiti) vs SimpleCheckList"
created: 2025-12-13T00:00:00
updated: 2025-12-13T01:25
project: dotfiles
scope:
  - mcp
  - ai
type: reference
status: 📝 draft
publish: false
tags:
  - mcp
  - graphiti
  - knowledge-graph
  - task-management
aliases:
  - Tasks vs Memory MCP
  - Graphiti vs SimpleCheckList
related:
  - ref: "[[graphiti-strategy]]"
    description: Graphiti custom entity types
  - ref: "[[mcp-transports]]"
    description: MCP transport mechanisms
---

# MCP Comparison: Memory (Graphiti) vs SimpleCheckList

A comprehensive comparison of two complementary MCP servers for AI assistants.

---

## Architecture & Technology

| Aspect             | Memory (Graphiti)                   | SimpleCheckList                  |
| ------------------ | ----------------------------------- | -------------------------------- |
| **Database**       | FalkorDB (Redis-based graph DB)     | SQLite (relational DB)           |
| **Data Model**     | Temporal knowledge graph            | Hierarchical tree structure      |
| **AI Integration** | Uses Ollama for LLM + embeddings    | Traditional CRUD only            |
| **Transport**      | HTTP (port 8000) + stdio            | HTTP REST API (8355) + stdio MCP |
| **Web UI**         | No UI                               | React frontend (port 80)         |

---

## Purpose & Use Cases

### Memory (Graphiti) - Unstructured Knowledge & Context

- **What it does**: Maintains persistent memory across conversations
- **Data stored**:
  - Episodes (conversations, interactions)
  - Entities (people, places, concepts)
  - Facts (relationships, attributes)
  - Temporal context (when things happened)

**Example uses:**
- "Remember that Sarah prefers morning meetings"
- "John mentioned he's working on the API project"
- "Last week we discussed migrating to Kubernetes"
- Search: "What did we discuss about databases?"

### SimpleCheckList - Structured Task Management

- **What it does**: Organizes actionable work items
- **Data stored**:
  - Projects
  - Groups (within projects)
  - Task Lists (within groups)
  - Tasks (within task lists)
  - Subtasks (within tasks)

**Example uses:**
- "Create a project called 'Q1 Migration'"
- "Add task: Review API documentation by Friday"
- "Mark task as complete"
- "Show all tasks in 'Backend' project"
- Track completion statistics

---

## Tools Comparison

### Memory (Graphiti) - 6 Tools

| Tool | Description |
|------|-------------|
| `add_memory` | Store episodes/interactions in knowledge graph |
| `search_facts` | Find relevant facts and relationships (semantic) |
| `search_nodes` | Search entity summaries (semantic) |
| `get_episodes` | Retrieve recent episodes for context |
| `delete_episode` | Remove episodes from graph |
| `clear_graph` | Reset entire knowledge graph |

### SimpleCheckList - 20 Tools

| Category | Tools |
|----------|-------|
| Projects | `list_projects`, `create_project`, `get_project`, `update_project`, `delete_project` |
| Groups | `list_groups`, `create_group` |
| Task Lists | `list_task_lists`, `create_task_list` |
| Tasks | `list_tasks`, `create_task`, `toggle_task_completion`, `update_task`, `delete_task` |
| Subtasks | `list_subtasks`, `create_subtask`, `toggle_subtask_completion`, `delete_subtask` |
| Stats | `get_project_stats`, `get_all_tasks` |

---

## Key Differences

| Feature                 | Memory (Graphiti)                         | SimpleCheckList              |
| ----------------------- | ----------------------------------------- | ---------------------------- |
| **Search Type**         | Semantic similarity (AI-powered)          | Exact match / filters        |
| **Temporal Awareness**  | Timeline-based, "when did X happen?"      | Static snapshots             |
| **Structure**           | Flexible graph (entities + relationships) | Rigid hierarchy (5 levels)   |
| **Learning**            | Extracts entities/facts automatically     | Manual data entry            |
| **Actionability**       | Low (stores context/memory)               | High (tracks concrete tasks) |
| **Completion Tracking** | N/A                                       | Boolean completion status    |
| **Statistics**          | N/A                                       | Project completion stats     |

---

## Are They Complementary or Redundant?

### HIGHLY COMPLEMENTARY

They serve fundamentally different purposes and work well together.

### Workflow Example

```
1. CONVERSATION (Memory stores context):
   User: "I need to migrate our API to use the new auth system"
   AI: *stores in Memory*
      - Entity: "API migration project"
      - Fact: "User wants new auth system"
      - Relationship: "API → needs → auth migration"

2. ACTION PLANNING (SimpleCheckList tracks tasks):
   AI: "I'll create a task list for this"
   *creates in SimpleCheckList*
      Project: "API Migration"
      └── Group: "Authentication"
          └── TaskList: "Implementation"
              ├── Task: "Research auth providers"
              ├── Task: "Update API endpoints"
              └── Task: "Write migration tests"

3. FOLLOW-UP (Memory provides context):
   User: "What was that auth thing we talked about?"
   AI: *searches Memory* → retrieves conversation context
   AI: *checks SimpleCheckList* → shows current task status
```

### Complementary Strengths

| Use Case                      | Memory             | SimpleCheckList |
| ----------------------------- | ------------------ | --------------- |
| "What did we discuss?"        | Primary            |                 |
| "What tasks do I have?"       |                    | Primary         |
| "Why did I create this task?" | Context            | Task details    |
| "Who mentioned X?"            | Entity search      |                 |
| "What's 50% complete?"        |                    | Stats           |
| "When did we decide Y?"       | Temporal search    |                 |

---

## Recommendation: Keep Both

### Use Memory (Graphiti) for:

- Conversational context across sessions
- Long-term memory ("remember that...")
- Semantic search ("what did we say about...")
- Temporal queries ("when did...")
- Relationship tracking (people, projects, concepts)

### Use SimpleCheckList for:

- Concrete task tracking
- Project organization
- Completion statistics
- Visual task management (web UI)
- Actionable work items with due dates

### Synergy Opportunities

You could build a **bridge** between them:

- When Memory identifies an actionable item, automatically create a SimpleCheckList task
- When completing a SimpleCheckList task, store the completion context in Memory
- Use Memory to answer "Why did we create this task?" by searching historical conversations

---

## Best Stack Recommendation

For comprehensive AI-assisted development workflows, combine:

| Component | Purpose |
|-----------|---------|
| **SimpleCheckList** | Visual task management + Web UI |
| **Workflows MCP** | Multi-step workflow orchestration |
| **Memory (Graphiti)** | Long-term context and knowledge |
| **Task Manager MCP** | AI-powered PRD to Task conversion |

This combination provides:
- **Structure** (SimpleCheckList) - Human interface for task tracking
- **Intelligence** (Task Manager) - Intelligent task breakdown from requirements
- **Automation** (Workflows) - Automate complex multi-step processes
- **Memory** (Graphiti) - Remember why tasks were created

### Complementarity Analysis

| MCP Server | Complementary to SimpleCheckList? | Notes |
|------------|-----------------------------------|-------|
| Workflows MCP Server | Highly complementary | Adds orchestration layer |
| Task Manager MCP | Highly complementary | Adds AI intelligence |
| Task Orchestrator MCP | Redundant | Too basic, overlaps with CRUD |
| Todoist/Jira MCP | Similar paradigm | Different storage, similar tracking |

---

> [!info] Metadata
> **Scope**: `= this.scope`
> **Type**: `= this.type`
> **Status**: `= this.status`
