---
id: e5f6a7b8-c9d0-1234-ef56-789012345678
title: "ADR: Agent Framework Strategy"
created: 2025-12-13T00:00:00
updated: 2025-12-13T00:00:00
project: dotfiles
scope:
  - ai
  - agents
  - mcp
type: adr
status: ✅ approved
publish: false
tags:
  - adr
  - architecture
  - agents
  - orchestration
  - claude-code
  - multi-agent
aliases:
  - Agent Framework ADR
  - Multi-Agent Strategy
related:
  - ref: "[[adr-memory-channel-architecture]]"
    description: Memory channel design for agents
  - ref: "[[agentic-workflow-toolset-comparison]]"
    description: Tool comparison analysis
  - ref: "[[agent-mcp-contributions]]"
    description: Planned Agent-MCP contributions
adr:
  number: "004"
  supersedes: null
  superseded_by: null
  deciders:
    - arustydev
---

# ADR: Agent Framework Strategy

## Status

Approved

## Context

Building AI-powered development workflows requires a multi-agent orchestration strategy that balances:

1. **Immediate productivity** - Start building now, not after months of framework development
2. **Memory integration** - Agents need persistent, multi-channel memory (Graphiti+FalkorDB)
3. **Cross-client compatibility** - Must work across Claude Code, Zed, VS Code, OpenCode/Crush
4. **Native Claude Code features** - Skills, Hooks, Plugins, Subagents
5. **Git-centric workflows** - Worktrees, branches, PR-based reviews
6. **Sandboxed execution** - Safe parallel agent execution
7. **Long-term ownership** - Custom framework for specialized agents

After evaluating claude-flow, Agent-MCP, claude-task-master, tsk, and Kilo Code, a phased approach emerged as optimal.

---

## Decision

Adopt a **three-phase incremental strategy**:

### Phase 1: claude-flow Foundation

**Duration:** Weeks 1-4

**Rationale:** Provides immediate access to:
- 25 native Skills (auto-activate via natural language)
- Advanced Hooks system for workflow automation
- 100+ MCP tools for orchestration
- AgentDB for coordination memory
- Active development with responsive maintainers

**Setup:**
```bash
# Initialize claude-flow
npx claude-flow@alpha init --force
claude mcp add claude-flow npx claude-flow@alpha mcp start

# Add Graphiti for long-term memory
claude mcp add graphiti graphiti-mcp-server
```

**Memory Strategy:**
- AgentDB: Agent coordination, shared state, short-term
- Graphiti: Project knowledge, temporal reasoning, long-term

**Deliverables:**
- [ ] claude-flow operational
- [ ] Basic multi-agent workflows functional
- [ ] Graphiti MCP integrated
- [ ] Hybrid memory skill created (routes to appropriate backend)

### Phase 2: Agent-MCP Integration

**Duration:** Months 2-3

**Rationale:** Provides:
- Alternative multi-agent coordination patterns
- Knowledge graph visualization (dashboard)
- Ephemeral agent architecture (clean context)
- Contribution opportunities to fill gaps

**Integration Pattern:**
```
claude-flow (primary orchestrator)
    │
    ├── Direct Skills-enabled agents
    │
    └── Agent-MCP (specialized workflows)
        ├── Knowledge-heavy research
        ├── Dashboard visualization
        └── Ephemeral multi-worker tasks
```

**Planned Contributions:**
- Git worktree support for parallel agent work
- Simplified Docker/containerization setup
- Graphiti memory adapter
- Skills bridge (portable skill definitions)

**Deliverables:**
- [ ] Agent-MCP evaluated and operational
- [ ] container-use MCP tested as sandbox option
- [ ] First upstream contribution (git worktrees)
- [ ] Integration pattern documented

### Phase 3: Custom Agent SDK Framework

**Duration:** Month 4+

**Rationale:** Long-term ownership of agent architecture:
- Claude Agent SDK as canonical foundation
- Skills are first-class citizens
- Incorporate learnings from Phase 1-2
- Specialized agents for specific workflows

**Framework Structure:**
```
agent-framework/
├── agents/
│   ├── base/                 # SDK-based templates
│   │   ├── researcher.py
│   │   ├── developer.py
│   │   ├── reviewer.py
│   │   └── debugger.py
│   └── specialized/          # Custom agents
│       ├── security-auditor/
│       ├── perf-analyzer/
│       └── api-reviewer/
├── skills/
│   ├── portable/             # Work in any context
│   │   ├── code-review.yaml
│   │   └── security-audit.yaml
│   └── sdk-native/           # SDK-specific skills
├── memory/
│   ├── channels/
│   │   ├── long-term.py      # Graphiti
│   │   ├── sprint.py         # Graphiti subgraph
│   │   ├── team.py           # AgentDB shared_state
│   │   └── short-term.py     # Context window
│   └── router.py             # Channel routing logic
├── orchestration/
│   ├── hooks/
│   │   ├── post-feature.py
│   │   └── pre-commit.py
│   └── workflows/
│       ├── feature-development.yaml
│       └── code-review.yaml
└── sandboxes/
    ├── docker/
    ├── worktree/
    └── claude-native/
```

**Deliverables:**
- [ ] SDK agent prototypes working
- [ ] Skills ported to portable format
- [ ] Memory channel router implemented
- [ ] At least 3 specialized agents operational

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          CLAUDE CODE                                     │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                    SKILLS LAYER                                  │    │
│  │  ├── code-review    ├── security-audit   ├── performance-check  │    │
│  │  ├── feature-impl   ├── debug-assist     ├── memory-router      │    │
│  │  └── custom-skills/ (extensions)                                │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                │                                         │
│  ┌─────────────────────────────┴─────────────────────────────────┐      │
│  │                    HOOKS LAYER                                 │      │
│  │  ├── post-task → spawn review agents                          │      │
│  │  ├── pre-commit → run tests                                   │      │
│  │  └── on-feature-complete → trigger sandbox execution          │      │
│  └───────────────────────────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────────────────────────┘
          │                              │                      │
          ▼                              ▼                      ▼
┌──────────────────┐          ┌──────────────────┐    ┌──────────────────┐
│   claude-flow    │          │     Graphiti     │    │   tsk / Docker   │
│   (Orchestration)│          │  (Long-term Mem) │    │   (Sandboxed)    │
├──────────────────┤          ├──────────────────┤    ├──────────────────┤
│ • Hive-mind coord│          │ • Project knowl. │    │ • Git worktrees  │
│ • Agent spawning │          │ • Temporal graph │    │ • Docker isolate │
│ • AgentDB (coord)│          │ • Entity relns   │    │ • Parallel exec  │
│ • MCP tools      │          │ • Sprint memory  │    │ • Branch output  │
└──────────────────┘          └──────────────────┘    └──────────────────┘
          │                              │                      │
          └──────────────────────────────┴──────────────────────┘
                                    │
                    ┌───────────────┴───────────────┐
                    │       MEMORY CHANNELS          │
                    ├────────────────────────────────┤
                    │ Long-term   → Graphiti         │
                    │ Sprint      → Graphiti subgraph│
                    │ Team        → AgentDB shared   │
                    │ Short-term  → Context window   │
                    └────────────────────────────────┘
```

---

## Consequences

### Positive

- Immediate productivity (Phase 1 operational in days)
- Learn multi-agent patterns before building custom framework
- Memory architecture designed upfront (Graphiti + AgentDB)
- Contributions to Agent-MCP benefit broader community
- Final framework incorporates real-world learnings

### Negative

- Multiple tools to maintain initially
- Potential for approach divergence between tools
- Learning curve across multiple systems
- Integration complexity between claude-flow and Agent-MCP

### Mitigations

| Risk | Mitigation |
|------|------------|
| claude-flow breaking changes | Pin to specific alpha version |
| Graphiti ↔ AgentDB complexity | Clear boundaries per memory channel |
| Agent-MCP learning curve | Discord community, start simple |
| Scope creep in Phase 3 | Define MVP agent framework early |

---

## Timeline

| Phase | Duration | Milestone |
|-------|----------|-----------|
| **1a** | Week 1-2 | claude-flow running, basic agents working |
| **1b** | Week 3-4 | Graphiti integrated, memory routing working |
| **2a** | Month 2 | Agent-MCP evaluated, container-use tested |
| **2b** | Month 2-3 | First contributions to Agent-MCP |
| **3a** | Month 3-4 | SDK agent prototypes, Skills ported |
| **3b** | Month 4+ | Custom framework operational |

---

## References

- [claude-flow](https://github.com/ruvnet/claude-flow)
- [Agent-MCP](https://github.com/rinadelph/Agent-MCP)
- [Claude Agent SDK](https://www.anthropic.com/engineering/building-agents-with-the-claude-agent-sdk)
- [Graphiti MCP Server](https://docs.falkordb.com/agentic-memory/graphiti-mcp-server.html)
- [tsk](https://github.com/dtormoen/tsk)

---

> [!info] Metadata
> **ADR**: `= this.adr.number`
> **Status**: `= this.status`
> **Deciders**: `= this.adr.deciders`
