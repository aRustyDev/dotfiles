---
created: 2025-12-13T12:42
updated: 2025-12-13T14:25
---
****
Deep Dive: claude-task-master vs Agent-MCP

Head-to-Head Comparison

| Aspect               | claude-task-master                      | Agent-MCP                                     |
| -------------------- | --------------------------------------- | --------------------------------------------- |
| Primary Mental Model | PRD → Tasks → Subtasks → Implementation | Admin Agent → Worker Agents → Knowledge Graph |
| Multi-Agent          | ❌ Single orchestrator                  | ✅ True multi-agent (ephemeral workers)       |
| Memory               | ❌ Stateless (task JSON only)           | ✅ Persistent knowledge graph                 |
| MCP Integration      | ✅ 36 MCP tools (is an MCP server)      | ✅ Exposes MCP server + consumes MCP          |
| Docker/Sandboxing    | ❌ None                                 | ⚠️ Not native (would need custom setup)       |
| Git Integration      | ❌ None built-in                        | ❌ None built-in                              |
| Task Templates       | ❌ No (but PRD parsing)                 | ⚠️ MCD templates                              |
| Skills Support       | ❌ No                                   | ❌ No                                         |
| Cross-Client         | ✅ Excellent (all major IDEs)           | ✅ Good (any MCP client)                      |
| Maturity             | ✅ Mature (15k stars, active)           | ⚠️ Early ("advanced tool notice")             |
| Setup Complexity     | Low (one command)                       | High (admin + workers + dashboard)            |

Why I Initially Recommended task-master for Cross-Client

1. Simplicity: Single command install, works immediately
2. Universality: One-click Cursor, native VS Code, Windsurf, Zed
3. Focused Scope: Does one thing well (task management)
4. Tool Loading Modes: Can reduce context from 21k to 5k tokens

Why Agent-MCP Might Be Better For Your Requirements

Given your clarified requirements, Agent-MCP actually aligns better:

| Your Requirement         | task-master      | Agent-MCP                    |
| ------------------------ | ---------------- | ---------------------------- |
| Memory integration       | ❌ None           | ✅ Knowledge graph            |
| Multiple memory channels | ❌                | ⚠️ Namespaces (not channels) |
| MCP access for agents    | ✅ Is MCP         | ✅ Consumes + exposes MCP     |
| Short-lived agents       | ❌ Single         | ✅ Ephemeral by design        |
| Research/debug agents    | ⚠️ Research mode | ✅ Specialized worker roles   |

---

Addressing Your Specific Requirements

1. Sandboxed Docker Environments

Options:

| Approach                  | Pros                                                                                    | Cons                              |
| ------------------------- | --------------------------------------------------------------------------------------- | --------------------------------- |
| tsk (Rust CLI)            | Purpose-built, git worktrees, network isolation                                         | CLI-only, no IDE integration      |
| container-use             | Anthropic-supported, MCP-native                                                         | Still experimental                |
| Custom Docker + Agent-MCP | Flexible, you control everything                                                        | Manual setup                      |
| Claude Code Sandbox       | Native (no Docker needed), https://www.anthropic.com/engineering/claude-code-sandboxing | Not Docker, limited customization |

Recommendation:

For your use case, consider a hybrid approach:

- Use Claude Code's native sandbox for filesystem/network isolation (no Docker overhead)
- Use tsk for parallel experimental branches that need complete isolation
- Reserve Docker for specific agents that need custom environments

Note: https://code.claude.com/docs/en/sandboxing - you'd need to exclude Docker commands from the sandbox.

2. Git Worktrees (Git-Centric Approach)

| Tool        | Git Worktree Support                                 |
| ----------- | ---------------------------------------------------- |
| tsk         | ✅ Native - each task gets its own worktree + branch |
| Kilo Code   | ✅ Parallel agents via worktrees                     |
| claude-flow | ❌ No worktree support                               |
| Agent-MCP   | ❌ No worktree support                               |
| task-master | ❌ No git integration                                |

Gap Analysis: None of the "orchestration" tools have native worktree support. Only the "sandboxed execution" tools (tsk, Kilo) do.

Recommendation: Use tsk as your git-centric sandbox executor, integrated with your orchestration layer via hooks.

3. Task Templates

| Tool        | Template Support                                                              |
| ----------- | ----------------------------------------------------------------------------- |
| tsk         | ✅ Excellent - .tsk/templates/\*.md with {{description}} placeholders         |
| claude-flow | ✅ Skills (25 built-in) + SPARC methodology                                   |
| Agent-MCP   | ⚠️ MCD (Main Context Document) - more like a project spec than task templates |
| task-master | ⚠️ PRD parsing (not templates)                                                |

tsk Template Example:

```mustache
# .tsk/templates/feat.md Implement the feature below. Make sure unit tests pass.
Write a descriptive commit message.
{{DESCRIPTION}}

tsk run --type feat --name auth -d "Add JWT authentication"
```

4. Memory Integration (Critical Requirement)

Graphiti+FalkorDB vs AgentDB

| Feature              | Graphiti+FalkorDB                                                   | AgentDB (claude-flow)           |
| -------------------- | ------------------------------------------------------------------- | ------------------------------- |
| Architecture         | Knowledge Graph (temporal)                                          | Vector DB + SQLite              |
| Query Latency        | Sub-10ms (P95: 300ms for semantic)                                  | <0.1ms (96x faster than before) |
| Temporal Reasoning   | ✅ Native (when facts valid/invalid)                                 | ❌ No temporal awareness         |
| Entity Relationships | ✅ Graph traversal                                                   | ⚠️ Vector similarity only       |
| Multi-tenancy        | ✅ Built-in                                                          | ⚠️ Namespace-based              |
| MCP Server           | ✅ https://docs.falkordb.com/agentic-memory/graphiti-mcp-server.html | ✅ Built into claude-flow        |
| Conflict Handling    | ✅ Invalidates old facts (preserves history)                         | ⚠️ Overwrites                   |

Verdict: Graphiti+FalkorDB is superior for your use case because:

1. Temporal reasoning (your agents can understand when things changed)
2. Graph relationships (better for understanding code relationships)
3. You're already setting it up

Can You Use Graphiti with claude-flow?

Yes, but with effort:

# claude-flow memory backend options

claude-flow memory backend set agentdb # Default
claude-flow memory backend set legacy # SQLite only
claude-flow memory backend set hybrid # Both

Custom Integration Path:

1. Keep AgentDB for claude-flow's internal coordination
2. Add Graphiti MCP server as an additional MCP tool
3. Create a custom skill that routes memory operations:
   - Short-term → AgentDB (fast, ephemeral)
   - Long-term/Temporal → Graphiti (graph, persistent)

```json
// Claude Code MCP config
{
  "mcpServers": {
    "claude-flow": { "command": "npx claude-flow@alpha mcp start" },
    "graphiti": {
      "command": "graphiti-mcp-server",
      "env": { "FALKORDB_URL": "..." }
    }
  }
}
```

Multiple Memory Channels (Your Requirement)

| Channel            | Purpose                                    | Recommended Backend                              |
| ------------------ | ------------------------------------------ | ------------------------------------------------ |
| Long-term          | Project knowledge, architectural decisions | Graphiti (temporal graph)                        |
| Sprint/Medium-term | Current sprint context, active features    | AgentDB namespace or dedicated Graphiti subgraph |
| Team               | Shared between agent roles                 | AgentDB shared_state table                       |
| Short-term         | Current task context                       | In-context (no persistence)                      |
|                    |                                            |                                                  |

Implementation Strategy:

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

5. Skills Support (Native in All Agents)

Current State:

| Tool        | Skills Support                 |
| ----------- | ------------------------------ |
| Claude Code | ✅ Native (skills/\*/SKILL.md) |
| claude-flow | ✅ 25 built-in + extensible    |
| Agent-MCP   | ❌ No skills system            |
| task-master | ❌ No skills system            |
| tsk         | ❌ Templates only (not skills) |

Making Skills Native Everywhere:

The challenge is that Skills are a Claude Code native feature. To use them in other contexts:

Option A: Route Everything Through Claude Code

```asciidoc
User Request
    ↓
Claude Code (with Skills)
    ↓ spawns
Subagents (inherit skill context)
```

Option B: Create Portable Skill Definitions

# portable-skills/code-review.yaml

```yaml
# portable-skills/code-review.yaml
name: code-review
triggers:
  - "review this code"
  - "check for bugs"
  - "security audit"
instructions: |
  When reviewing code:
  1. Check for security vulnerabilities
  2. Verify error handling
  3. Assess performance implications
  ...
```

Then load these into any agent system's prompt.

Option C: Use Claude Agent SDK

The https://www.anthropic.com/engineering/building-agents-with-the-claude-agent-sdk supports Skills natively. Any agent built with the SDK gets Skills.

6. Hooks for Agent Workflows

Your Example: "New feature is ready → trigger review agents for different roles"

| Tool         | Hook Support                                    |
| ------------ | ----------------------------------------------- |
| Claude Code  | ✅ Native hooks (pre/post tool, session events) |
| claude-flow  | ✅ Advanced hooks + MCP triggers                |
| claude-swarm | ✅ 12 events, 6 actions                         |
| Agent-MCP    | ⚠️ Manual agent spawning                        |
| task-master  | ❌ No hooks                                     |
| tsk          | ❌ No hooks (but can chain via shell)           |

Hook-Triggered Review Workflow:

# claude-flow hook example

```yaml
# claude-flow hook example
hooks:
  post-task:
    - condition: "task.type == 'feature' && task.status == 'complete'"
      actions:
        - spawn_agent:
            type: security-reviewer
            prompt: "Review {{task.branch}} for security issues"
        - spawn_agent:
            type: performance-reviewer
            prompt: "Review {{task.branch}} for performance"
        - spawn_agent:
            type: api-reviewer
            prompt: "Review {{task.branch}} for API consistency"
```

---

Revised Recommendation

Given your clarified requirements, here's my updated two-toolset recommendation:

Toolset 1: Orchestration + Memory + Skills

claude-flow (not task-master)

Why Changed:

- ✅ Native Skills (25 built-in)
- ✅ Hooks for agent workflows
- ✅ Memory system (AgentDB) + can integrate Graphiti
- ✅ Multi-agent swarm orchestration
- ✅ MCP native

Memory Strategy:

# Use hybrid: AgentDB for coordination, Graphiti for knowledge

claude mcp add graphiti graphiti-mcp-server

# Configure claude-flow to use Graphiti for long-term memory via custom skill

Toolset 2: Git-Centric Sandboxed Execution

tsk

Why:

- ✅ Git worktrees (your requirement)
- ✅ Docker sandboxing
- ✅ Task templates
- ✅ Parallel agent execution
- ✅ Agent comparison mode (claude vs codex)

Integration with claude-flow:

# claude-flow hook to trigger tsk

hooks:
on-feature-ready: - run: "tsk add --type review -n {{feature}} -d 'Review feature: {{description}}'"

Alternative: All-in-One Approach

If you want to reduce toolset complexity:

claude-flow + Custom Extensions

Build/extend claude-flow with:

1. Git worktree skill (new skill to create worktrees)
2. Graphiti integration skill (route long-term memory to Graphiti)
3. Docker sandbox skill (spawn isolated agent containers)
4. Multi-channel memory skill (manage your 4 memory channels)

This keeps everything in one system but requires development work.

---

Architecture Diagram (Proposed)

```asciidoc
┌─────────────────────────────────────────────────────────────────────────┐
│                          CLAUDE CODE                                     │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                    SKILLS LAYER                                  │    │
│  │  ├── code-review    ├── security-audit   ├── performance-check  │    │
│  │  ├── feature-impl   ├── debug-assist     ├── research           │    │
│  │  └── custom-skills/ (your extensions)                           │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                │                                         │
│  ┌─────────────────────────────┴─────────────────────────────────┐      │
│  │                    HOOKS LAYER                                 │      │
│  │  ├── post-task → spawn review agents                          │      │
│  │  ├── pre-commit → run tests                                   │      │
│  │  └── on-feature-complete → trigger tsk sandbox                │      │
│  └───────────────────────────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────────────────────────┘
          │                              │                      │
          ▼                              ▼                      ▼
┌──────────────────┐          ┌──────────────────┐    ┌──────────────────┐
│   claude-flow    │          │     Graphiti     │    │       tsk        │
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

Sources

- https://www.falkordb.com/blog/graphiti-falkordb-multi-agent-performance/
- https://docs.falkordb.com/agentic-memory/graphiti-mcp-server.html
- https://github.com/ruvnet/claude-flow/issues/829
- https://github.com/ruvnet/claude-flow/wiki/Memory-System
- https://www.anthropic.com/engineering/claude-code-sandboxing
- https://www.docker.com/blog/the-model-context-protocol-simplifying-building-ai-apps-with-anthropic-claude-desktop-and-docker/
- https://www.claude.com/blog/context-management
- https://github.com/jpicklyk/task-orchestrator
