---
id: f7a8b9c0-d1e2-3456-f789-012345678901
title: "ADR: Memory Channel Architecture"
created: 2025-12-13T00:00:00
updated: 2025-12-13T00:00:00
project: dotfiles
scope:
  - ai
  - agents
  - memory
type: adr
status: ✅ approved
publish: false
tags:
  - adr
  - architecture
  - memory
  - graphiti
  - agentdb
  - multi-agent
aliases:
  - Memory Channel ADR
  - Agent Memory Architecture
related:
  - ref: "[[adr-agent-framework-strategy]]"
    description: Overall agent framework strategy
  - ref: "[[agent-mcp-contributions]]"
    description: Planned Agent-MCP contributions
adr:
  number: "005"
  supersedes: null
  superseded_by: null
  deciders:
    - arustydev
---

# ADR: Memory Channel Architecture

## Status

Approved

## Context

Multi-agent systems require sophisticated memory management to:

1. **Persist knowledge** across sessions and agent lifetimes
2. **Share context** between coordinating agents
3. **Maintain temporal awareness** (what was true when?)
4. **Scope information** appropriately (project vs sprint vs task)
5. **Query efficiently** with semantic search and graph traversal

Two complementary memory systems are available:

- **Graphiti + FalkorDB**: Temporal knowledge graphs with entity relationships
- **AgentDB** (claude-flow): Fast vector search with SQLite coordination

Rather than choosing one, a **channel-based routing architecture** leverages both systems' strengths.

---

## Decision

Adopt a **four-channel memory architecture** with routing based on information type and lifecycle:

### Channel Definitions

| Channel | Backend | Scope | Lifecycle | Use Cases |
|---------|---------|-------|-----------|-----------|
| **Long-term** | Graphiti | Project/Global | Persistent | Architecture decisions, patterns, domain knowledge |
| **Sprint** | Graphiti (subgraph) | Sprint/Epic | Weeks | Current feature context, WIP decisions, research |
| **Team** | AgentDB shared_state | Agent session | Hours | Inter-agent coordination, task handoffs, status |
| **Short-term** | Context window | Single agent | Minutes | Immediate task context, scratchpad |

### Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         MEMORY ROUTER                                    │
│                   (Channel-based routing logic)                          │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  store(content, channel, metadata) ──► route to appropriate backend     │
│  search(query, channels[]) ──► federated search across backends         │
│  recall(entity, temporal_context) ──► timeline-aware retrieval          │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
          │                    │                    │                │
          ▼                    ▼                    ▼                ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  ┌──────────┐
│   LONG-TERM     │  │     SPRINT      │  │      TEAM       │  │  SHORT   │
│    CHANNEL      │  │    CHANNEL      │  │    CHANNEL      │  │  TERM    │
├─────────────────┤  ├─────────────────┤  ├─────────────────┤  ├──────────┤
│ Graphiti        │  │ Graphiti        │  │ AgentDB         │  │ Context  │
│ + FalkorDB      │  │ (subgraph)      │  │ shared_state    │  │ Window   │
├─────────────────┤  ├─────────────────┤  ├─────────────────┤  ├──────────┤
│ • Entities      │  │ • Sprint scope  │  │ • Agent states  │  │ • Prompt │
│ • Relations     │  │ • Temporal      │  │ • Task queue    │  │ • Recent │
│ • Episodes      │  │ • Invalidation  │  │ • Handoffs      │  │   output │
│ • Facts         │  │                 │  │ • Shared vars   │  │          │
└─────────────────┘  └─────────────────┘  └─────────────────┘  └──────────┘
```

### Channel Characteristics

#### Long-term Channel (Graphiti)

**Purpose**: Permanent project knowledge that persists across all work.

**Stored Content**:
- Architecture decisions (ADRs, patterns)
- Domain entity definitions
- API contracts and schemas
- Team conventions and standards
- Historical decisions and their rationale

**Query Patterns**:
```python
# Semantic search
await memory.search("authentication patterns", channels=["long_term"])

# Entity lookup with relationships
await memory.get_entity("UserService", include_relations=True)

# Temporal query
await memory.recall("database schema", as_of="2025-01-01")
```

**Lifecycle**: Permanent until explicitly deprecated/superseded.

#### Sprint Channel (Graphiti Subgraph)

**Purpose**: Current work context that's relevant for weeks, not forever.

**Stored Content**:
- Feature specifications and decisions
- Research findings for current work
- WIP design choices
- Sprint-specific patterns
- Temporary workarounds

**Query Patterns**:
```python
# Current sprint context
await memory.search("error handling", channels=["sprint"])

# Promote to long-term when stabilized
await memory.promote("sprint", "long_term", entity_id="...")
```

**Lifecycle**: Sprint duration (1-4 weeks), then archived or promoted.

#### Team Channel (AgentDB)

**Purpose**: Real-time coordination between active agents.

**Stored Content**:
- Agent status and capabilities
- Task assignments and progress
- Shared variables and flags
- Handoff context
- Lock/semaphore states

**Query Patterns**:
```python
# Check agent status
await memory.get_team_state("backend-worker")

# Coordinate handoff
await memory.handoff(
    from_agent="researcher",
    to_agent="developer",
    context={"findings": [...], "recommendations": [...]}
)
```

**Lifecycle**: Session duration, cleared on workflow completion.

#### Short-term Channel (Context Window)

**Purpose**: Immediate working memory for single agent tasks.

**Stored Content**:
- Current task context
- Recent tool outputs
- Scratchpad calculations
- Intermediate results

**Query Patterns**:
```python
# Managed automatically by context window
# No explicit API - part of prompt management
```

**Lifecycle**: Single task, automatically garbage collected.

---

### Routing Logic

```python
class MemoryRouter:
    """Routes memory operations to appropriate backend."""

    CHANNEL_BACKENDS = {
        "long_term": "graphiti",
        "sprint": "graphiti",  # Different subgraph
        "team": "agentdb",
        "short_term": "context"
    }

    CONTENT_TYPE_CHANNELS = {
        # Architectural knowledge → long-term
        "adr": "long_term",
        "pattern": "long_term",
        "convention": "long_term",
        "schema": "long_term",

        # Current work → sprint
        "research": "sprint",
        "wip_decision": "sprint",
        "feature_spec": "sprint",
        "investigation": "sprint",

        # Coordination → team
        "agent_status": "team",
        "task_assignment": "team",
        "handoff": "team",
        "shared_state": "team",

        # Ephemeral → short-term
        "scratchpad": "short_term",
        "intermediate": "short_term"
    }

    async def store(
        self,
        content: str,
        channel: str = None,
        content_type: str = None,
        metadata: dict = None
    ) -> str:
        """Store content in appropriate channel."""
        # Auto-detect channel from content type if not specified
        if channel is None:
            channel = self.CONTENT_TYPE_CHANNELS.get(content_type, "sprint")

        backend = self.CHANNEL_BACKENDS[channel]

        if backend == "graphiti":
            return await self._store_graphiti(content, channel, metadata)
        elif backend == "agentdb":
            return await self._store_agentdb(content, metadata)
        else:
            return await self._store_context(content)

    async def search(
        self,
        query: str,
        channels: list[str] = None,
        limit: int = 10
    ) -> list[SearchResult]:
        """Federated search across channels."""
        channels = channels or ["long_term", "sprint"]
        results = []

        for channel in channels:
            backend = self.CHANNEL_BACKENDS[channel]
            channel_results = await self._search_backend(
                backend, query, channel, limit
            )
            results.extend(channel_results)

        # Sort by relevance, deduplicate
        return self._merge_results(results, limit)
```

---

### Graphiti Configuration

```yaml
# graphiti-config.yaml
graphiti:
  connection:
    falkordb_url: "redis://localhost:6379"
    # OR neo4j_url: "bolt://localhost:7687"

  embedding:
    model: "text-embedding-3-small"
    dimensions: 1536

  subgraphs:
    long_term:
      name: "project_knowledge"
      description: "Permanent project knowledge"
      entity_types:
        - Service
        - Pattern
        - Convention
        - Decision
        - Schema

    sprint:
      name: "sprint_${SPRINT_ID}"
      description: "Current sprint context"
      entity_types:
        - Feature
        - Investigation
        - WIPDecision
        - Research
      ttl: "4w"  # Auto-archive after 4 weeks
```

### AgentDB Configuration

```yaml
# agentdb-config.yaml
agentdb:
  storage:
    path: ".claude-flow/agentdb.sqlite"

  collections:
    team_state:
      description: "Agent coordination state"
      vector_dimensions: 1536
      hnsw_ef_construction: 200

    task_queue:
      description: "Pending task assignments"
      vector_dimensions: 1536

  cleanup:
    on_workflow_complete: true
    retain_logs: true
```

---

### Cross-Channel Operations

#### Promotion (Sprint → Long-term)

When sprint knowledge becomes permanent:

```python
async def promote_to_long_term(
    self,
    sprint_entity_id: str,
    reason: str
) -> str:
    """Promote sprint knowledge to long-term storage."""
    # Fetch from sprint subgraph
    entity = await self.graphiti.get_entity(
        sprint_entity_id,
        subgraph="sprint"
    )

    # Store in long-term with provenance
    return await self.graphiti.add_episode(
        name=entity.name,
        episode_body=entity.content,
        source=f"promoted_from_sprint:{sprint_entity_id}",
        episode_type=EpisodeType.reflection,
        metadata={
            "promotion_reason": reason,
            "original_sprint": os.environ.get("SPRINT_ID"),
            "promoted_at": datetime.now().isoformat()
        },
        subgraph="long_term"
    )
```

#### Team → Sprint Escalation

When coordination discoveries become sprint knowledge:

```python
async def escalate_to_sprint(
    self,
    team_context: dict,
    summary: str
) -> str:
    """Escalate team coordination insights to sprint memory."""
    return await self.store(
        content=summary,
        channel="sprint",
        content_type="investigation",
        metadata={
            "source": "team_escalation",
            "original_context": team_context
        }
    )
```

---

## Consequences

### Positive

- **Right tool for right job**: Graphiti for knowledge graphs, AgentDB for coordination
- **Clear boundaries**: Each channel has defined scope and lifecycle
- **Temporal awareness**: Graphiti's bi-temporal model supports "what was true when"
- **Fast coordination**: AgentDB's HNSW indexing for real-time agent sync
- **Graceful degradation**: Channels can operate independently
- **Future-proof**: Can swap backends per channel without changing interface

### Negative

- **Complexity**: Two systems to configure and maintain
- **Learning curve**: Developers must understand channel semantics
- **Potential inconsistency**: Cross-channel operations need careful handling
- **Storage overhead**: Duplication possible between channels

### Mitigations

| Risk | Mitigation |
|------|------------|
| Configuration complexity | Unified YAML config with sensible defaults |
| Wrong channel selection | Content-type-based auto-routing |
| Cross-channel inconsistency | Explicit promotion/escalation operations |
| Storage duplication | Deduplication on promotion |

---

## Implementation Phases

### Phase 1: Foundation
- [ ] Graphiti MCP server operational
- [ ] AgentDB via claude-flow operational
- [ ] Basic MemoryRouter class
- [ ] Manual channel specification

### Phase 2: Smart Routing
- [ ] Content-type auto-detection
- [ ] Federated search across channels
- [ ] Promotion/escalation operations
- [ ] Memory Skill for Claude Code

### Phase 3: Advanced Features
- [ ] Temporal queries ("as of" support)
- [ ] Sprint lifecycle automation
- [ ] Cross-channel deduplication
- [ ] Analytics and insights

---

## References

- [Graphiti Documentation](https://docs.falkordb.com/agentic-memory/graphiti.html)
- [Graphiti MCP Server](https://docs.falkordb.com/agentic-memory/graphiti-mcp-server.html)
- [claude-flow AgentDB](https://github.com/ruvnet/claude-flow)
- [Bi-temporal Data Modeling](https://en.wikipedia.org/wiki/Bitemporal_Modeling)

---

> [!info] Metadata
> **ADR**: `= this.adr.number`
> **Status**: `= this.status`
> **Deciders**: `= this.adr.deciders`
