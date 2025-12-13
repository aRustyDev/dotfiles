---
created: 2025-12-13T14:02
updated: 2025-12-13T14:25
---

| Aspect               | Agent-MCP                                     |
| -------------------- | --------------------------------------------- |
| Primary Mental Model | Admin Agent → Worker Agents → Knowledge Graph |
| Multi-Agent          | ✅ True multi-agent (ephemeral workers)        |
| Memory               | ✅ Persistent knowledge graph                  |
| MCP Integration      | ✅ Exposes MCP server + consumes MCP           |
| Docker/Sandboxing    | ⚠️ Not native (would need custom setup)       |
| Git Integration      | ❌ None built-in                               |
| Task Templates       | ⚠️ MCD templates                              |
| Skills Support       | ❌ No                                          |
| Cross-Client         | ✅ Good (any MCP client)                       |
| Maturity             | ⚠️ Early ("advanced tool notice")             |
| Setup Complexity     | High (admin + workers + dashboard)            |

PRD → Tasks → Subtasks → Implementation → Admin Agent → Worker Agents → Knowledge Graph
## Containerized Agents

- Container-Use
- Docker-Compose

## Git WorkTree Flows


## Task Templates

- PRD Parsing
- MCD templates
- Agent Templates (see claude-swarm / SwarmSDK)

## Anthropic Plugin Support


## OpenRouter Backend


## Complex Memory Configs

- Optionally Stateless
- Short-Term
- Medium-Term
	- Shared between Agents
	- Shared between "Sprints"
- Long-Term (Persistent, shared w/ user)

### ⚠️ "Namespaces" vs "channels"

| Channel            | Purpose                                    | Recommended Backend                              |
| ------------------ | ------------------------------------------ | ------------------------------------------------ |
| Long-term          | Project knowledge, architectural decisions | Graphiti (temporal graph)                        |
| Sprint/Medium-term | Current sprint context, active features    | AgentDB namespace or dedicated Graphiti subgraph |
| Team               | Shared between agent roles                 | AgentDB shared_state table                       |
| Short-term         | Current task context                       | In-context (no persistence)                      |
# Proposed memory architecture

```yaml
# Proposed memory architecture
memory_channels:
  long_term:
    backend: graphiti
    persistence: permanent
    scope: project

  sprint:
    backend: graphiti # Same DB, different subgraph
    persistence: sprint_duration
    scope: current_sprint
    ttl: "2 weeks"

  team:
    backend: agentdb
    table: shared_state
    persistence: session
    scope: all_agents

  short_term:
    backend: context_window
    persistence: none
    scope: current_agent
```
## Simplify Setup

## Make Agent Based "API"

> Enable a API for things like 'claude-workflow' to leverage
> > the Things leveraging this would be a Claude Code (or equivalent) tool 



Create a custom skill that routes memory operations:
   - Short-term → AgentDB (fast, ephemeral)
   - Long-term/Temporal → Graphiti (graph, persistent)