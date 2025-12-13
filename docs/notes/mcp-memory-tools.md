---
id: 9b8c7d6e-5f4a-3b2c-1d0e-f9a8b7c6d5e4
title: MCP Memory Tools Reference
created: 2025-12-13T00:00:00
updated: 2025-12-13T00:00:00
project: dotfiles
scope:
  - mcp
  - ai
type: reference
status: 📝 draft
publish: false
tags:
  - mcp
  - memory
  - knowledge-graph
  - ai-tools
aliases:
  - Memory MCP Tools
  - AI Memory Reference
related:
  - ref: "[[mcp-tasks-vs-memory]]"
    description: Memory vs Task comparison
  - ref: "[[graphiti-strategy]]"
    description: Graphiti custom entity types
---

# MCP Memory Tools Reference

Comprehensive reference for memory-related MCP tools and platforms.

---

## Use Case Scenarios

### Cross-Tool Project Flow

Define technical requirements of a project in Claude Desktop. Build in Cursor. Debug issues in Windsurf - all with shared context passed through OpenMemory.

### Preferences That Persist

Set your preferred code style or tone in one tool. When you switch to another MCP client, it can access those same preferences without redefining them.

### Project Knowledge

Save important project details once, then access them from any compatible AI tool - no more repetitive explanations.

### Multi-Session Research Agent

Run multi-session investigations that remember past findings and preferences. See [Mem0 Deep Research](https://docs.mem0.ai/cookbooks/operations/deep-research).

### Collaborative Task Assistant

Coordinate multi-user projects with shared memories and roles. See [Mem0 Team Task Agent](https://docs.mem0.ai/cookbooks/operations/team-task-agent).

### Content Creation Workflow

Store voice guidelines once and apply them across every draft. See [Mem0 Content Writing](https://docs.mem0.ai/cookbooks/operations/content-writing).

### Personalized AI Tutor

Keep student progress and preferences persistent across tutoring sessions. See [Mem0 AI Tutor](https://docs.mem0.ai/cookbooks/companions/ai-tutor).

### Search with Personal Context

Blend Tavily's realtime results with personal context stored in Mem0.

---

## Essential Memory Operations

| Category | Operations |
|----------|------------|
| **Recall** | Reading, querying, semantic search & retrieval |
| **Organization** | Tagging, categorization, contextual linking |
| **Lifecycle** | Summarization, expiration, archiving, versioning |
| **Data** | Export/import, storage (vectors, graphs, RDBMS) |
| **Discovery** | Listing, exploration, browsing |
| **Ranking** | Salience boosting, sectorization, reinforcement |
| **Scoring** | Relevance, freshness, importance |

---

## Memory Platforms Comparison

### mcp/memory

Basic graph memory operations:

| Tool | Description |
|------|-------------|
| `search_nodes` | Search for nodes in the graph |
| `read_graph` | Read the entire graph |
| `open_nodes` | Open specific nodes |
| `delete_relations` | Delete relationships |
| `delete_observations` | Delete observations |
| `delete_entities` | Delete entities |
| `create_relations` | Create relationships |
| `create_entities` | Create entities |
| `add_observations` | Add observations |

### Graphiti

Temporal knowledge graph with AI extraction:

| Tool | Description |
|------|-------------|
| `add_memory` | Store episodes and interactions in the knowledge graph |
| `search_facts` | Find relevant facts and relationships |
| `search_nodes` | Search for entity summaries and information |
| `get_episodes` | Retrieve recent episodes for context |
| `delete_episode` | Remove episodes from the graph |
| `clear_graph` | Reset the knowledge graph entirely |

### MCP Memory Service

Full-featured memory service with chunking support:

| Tool | Description |
|------|-------------|
| `store_memory` | Store new memory with metadata |
| `retrieve_memory` | Retrieve by semantic similarity |
| `search_by_tag` | Search by specific tags (AND/OR logic) |
| `delete_memory` | Delete by content hash |
| `list_memories` | List with pagination and filtering |
| `check_database_health` | Check database status |
| `get_cache_stats` | Performance monitoring |

**Content Length Limits:**
- Cloudflare backend: 800 characters max
- SQLite-vec backend: No limit
- Hybrid backend: 800 characters max
- Auto-splitting preserves context (50-char overlap)

### BasicMemory

Note-centric knowledge management:

**Knowledge Management:**
- `write_note`, `read_note`, `edit_note`, `view_note`, `delete_note`, `move_note`

**Search and Discovery:**
- `search_notes`, `recent_activity`, `build_context`, `list_directory`

**Project Management:**
- `list_memory_projects`, `create_memory_project`, `delete_project`, `sync_status`
- Multi-project mode, default project mode, single project mode

### OpenMemory

Simple cross-tool memory:

| Tool | Description |
|------|-------------|
| `add_memories` | Store new memory objects |
| `search_memory` | Retrieve relevant memories |
| `list_memories` | View all stored memory |
| `delete_all_memories` | Clear memory entirely |
| `openmemory_query` | Query memories |
| `openmemory_store` | Store memory |
| `openmemory_reinforce` | Reinforce existing memory |

### Mem0

See [Mem0 Documentation](https://docs.mem0.ai/open-source/overview) for full reference.

---

## Open Questions

### Memory Architecture
- Should zettelkasten notes be a separate memory type or integrated into general notes?
- How do notes relate to memories?

### Memory Lifecycle
- How to handle memory archiving?
- Memory versioning & updates strategy?
- How to handle "Lessons Learned" or evolving knowledge?

### Context & Relevance
- How to make memories more context-aware?
- Memory reranking strategies?

### Privacy & Collaboration
- Privacy & security considerations?
- Personal vs shared memories - agents that need to collaborate but stay fresh/unbiased?

---

## Resources

- [Mem0 Documentation](https://docs.mem0.ai/open-source/overview)
- [BasicMemory Docs](https://docs.basicmemory.com/guides/mcp-tools-reference/)
- [OpenMemory GitHub](https://github.com/CaviraOSS/OpenMemory)
- [Graphiti Repository](https://github.com/zep-ai/graphiti)

---

> [!info] Metadata
> **Scope**: `= this.scope`
> **Type**: `= this.type`
> **Status**: `= this.status`
