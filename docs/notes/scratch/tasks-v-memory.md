---
id: e6f7a8b9-c0d1-2345-ef01-678901234567
title: Tasks vs Memory MCP Comparison
created: 2025-12-13T00:00:00
updated: 2025-12-13T16:29
project: dotfiles
scope:
  - mcp
  - ai
type: analysis
status: 📝 draft
publish: false
tags:
  - mcp
  - graphiti
  - task-management
  - comparison
aliases:
  - Tasks vs Memory Analysis
related:
  - ref: "[[mcp-tasks-vs-memory]]"
    description: Formal MCP comparison document
  - ref: "[[mcp-memory-tools]]"
    description: Memory tools reference
---

## Assistant

Perfect! Now let me analyze the Graphiti documentation and create a comprehensive comparison:

**Tool Call: Thinking**
Status: Completed

Now I have a clear picture of both systems:

**Memory (Graphiti Knowledge Graph MCP)**:

- Purpose: Persistent memory/knowledge graph for AI assistants
- Backend: FalkorDB (Redis-based graph database)
- Tools: add_memory, search_facts, search_nodes, get_episodes, delete_episode, clear_graph
- Data model: Episodes, entities, relationships, facts in a temporal knowledge graph
- Use case: Long-term memory across conversations, context retention, semantic relationships
- AI-powered: Uses Ollama (LLM + embeddings) for entity extraction and semantic search
- Features: Temporally-aware, semantic search, entity/relationship extraction, multi-user via group_id

**SimpleCheckList MCP**:

- Purpose: Task/project management system
- Backend: SQLite database (relational)
- Tools: 20 tools for CRUD on projects, groups, task lists, tasks, subtasks
- Data model: Hierarchical structure (Project → Group → TaskList → Task → Subtask)
- Use case: Structured task tracking, TODO lists, project organization
- Not AI-powered: Traditional CRUD operations, no semantic understanding
- Features: Completion tracking, statistics, hierarchical organization, web UI for visualization

Key differences:

1. **Data structure**: Graph (semantic, temporal) vs Hierarchical (structured, relational)
2. **Purpose**: Memory/context vs Task management
3. **Intelligence**: AI-powered semantic search vs Traditional CRUD
4. **Temporal**: Timeline-aware episodes vs Static tasks
5. **Search**: Semantic similarity vs Exact match
6. **Use case**: "Remember this conversation" vs "Track this task"

Are they complementary or redundant?

- **COMPLEMENTARY** - They serve completely different purposes
- Memory is for storing unstructured knowledge and context
- SimpleCheckList is for structured task tracking

Example workflows:

- Memory: "Remember that John mentioned he prefers Python over JavaScript in our last conversation"
- SimpleCheckList: "Create a task to review John's Python code by Friday"

They could work together:

- AI assistant uses Memory to recall past conversations and preferences
- AI assistant uses SimpleCheckList to create and track actionable tasks based on those memories

## Assistant

## Comparison: Memory (Graphiti) vs SimpleCheckList

Based on my analysis of both systems, here's a comprehensive comparison:

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

### Memory (Graphiti) - **Unstructured Knowledge & Context**

- **What it does**: Maintains persistent memory across conversations
- **Data stored**:
  - Episodes (conversations, interactions)
  - Entities (people, places, concepts)
  - Facts (relationships, attributes)
  - Temporal context (when things happened)

Example uses:
- "Remember that Sarah prefers morning meetings"
- "John mentioned he's working on the API project"
- "Last week we discussed migrating to Kubernetes"
- Search: "What did we discuss about databases?"

### SimpleCheckList - **Structured Task Management**

- **What it does**: Organizes actionable work items
- **Data stored**:
  - Projects
  - Groups (within projects)
  - Task Lists (within groups)
  - Tasks (within task lists)
  - Subtasks (within tasks)

Example uses:
- "Create a project called 'Q1 Migration'"
- "Add task: Review API documentation by Friday"
- "Mark task as complete"
- "Show all tasks in 'Backend' project"
- Track completion statistics

---

## Tools Comparison

### Memory (Graphiti) - 6 Tools

```
add_memory         - Store episodes/interactions in knowledge graph
search_facts       - Find relevant facts and relationships (semantic)
search_nodes       - Search entity summaries (semantic)
get_episodes       - Retrieve recent episodes for context
delete_episode     - Remove episodes from graph
clear_graph        - Reset entire knowledge graph
```

### SimpleCheckList - 20 Tools

```
list_projects, create_project, get_project, update_project, delete_project
list_groups, create_group
list_task_lists, create_task_list
list_tasks, create_task, toggle_task_completion, update_task, delete_task
list_subtasks, create_subtask, toggle_subtask_completion, delete_subtask
get_project_stats
get_all_tasks
```

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

### **HIGHLY COMPLEMENTARY**

They serve fundamentally different purposes and work well together:

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
| "What did we discuss?"        | Primary            | -               |
| "What tasks do I have?"       | -                  | Primary         |
| "Why did I create this task?" | Context            | Task details    |
| "Who mentioned X?"            | Entity search      | -               |
| "What's 50% complete?"        | -                  | Stats           |
| "When did we decide Y?"       | Temporal search    | -               |

---

## Recommendation: **Keep Both**

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

You could even build a **bridge** between them:

- When Memory identifies an actionable item, automatically create a SimpleCheckList task
- When completing a SimpleCheckList task, store the completion context in Memory
- Use Memory to answer "Why did we create this task?" by searching historical conversations
