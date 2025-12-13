---
id: d4e5f6a7-b8c9-0123-def4-567890123456
title: "Agentic Workflow Toolset Comparison"
created: 2025-12-13T00:00:00
updated: 2025-12-13T00:00:00
project: dotfiles
scope:
  - ai
  - mcp
  - agents
type: analysis
status: ✅ approved
publish: false
tags:
  - agentic
  - multi-agent
  - orchestration
  - claude-code
  - mcp
  - comparison
aliases:
  - Agent Orchestration Comparison
  - Multi-Agent Tools Analysis
related:
  - ref: "[[mcp-tasks-vs-memory]]"
    description: MCP memory tools comparison
  - ref: "[[adr-container-use-mcp-integration]]"
    description: Container MCP integration patterns
---

# Agentic Workflow Toolset Comparison

Research and comparison of multi-agent orchestration tools for AI-driven development workflows.

---

## Executive Summary

| Tool | Primary Focus | Cross-Client | Claude Code Native | Best For |
|------|--------------|--------------|-------------------|----------|
| **claude-flow** | Enterprise orchestration | ✅ MCP | ✅ Skills + MCP | Complex multi-agent swarms |
| **claude-swarm (SwarmSDK)** | Ruby agent teams | ✅ RubyLLM (any provider) | ❌ Decoupled | Ruby shops, provider flexibility |
| **claude-task-master** | Task management | ✅ MCP (Cursor, VS Code, etc.) | ✅ CLI integration | PRD→Tasks workflow |
| **tsk** | Sandboxed parallel agents | ⚠️ CLI only | ✅ Claude Code + Codex | Safe parallel experimentation |
| **Agent-MCP** | Multi-agent coordination | ✅ MCP | ⚠️ MCP only | Complex project coordination |
| **Kilo Code** | Model-agnostic agent | ✅ VS Code, JetBrains, CLI | ❌ Separate tool | Any-model workflows |

---

## Detailed Tool Analysis

### 1. claude-flow (v2.7.0)

**Repository:** https://github.com/ruvnet/claude-flow
**Language:** TypeScript/Node.js | **Stars:** ~2.5k | **Install:** `npx claude-flow@alpha`

#### What It Does

- Enterprise-grade AI orchestration with "hive-mind" swarm intelligence
- 25 Claude Skills that activate via natural language
- 100+ MCP tools for swarm orchestration
- Persistent memory with AgentDB (96x-164x faster vector search)
- Queen-led AI coordination with specialized worker agents

#### Architecture

```
┌─────────────────────────────────────────┐
│           HIVE-MIND QUEEN               │
│  (Coordinates all agent activity)       │
├─────────────────────────────────────────┤
│  Worker Agents (64 specialized types)   │
│  ├── researcher, coder, analyst...      │
│  └── Connected via MCP protocol         │
├─────────────────────────────────────────┤
│  Memory Layer                           │
│  ├── AgentDB (vector search)            │
│  └── ReasoningBank (SQLite)             │
└─────────────────────────────────────────┘
```

#### Claude Code Integration

- ✅ Native Skills system (25 skills)
- ✅ MCP server: `claude mcp add claude-flow npx claude-flow@alpha mcp start`
- ✅ Hooks system for automated workflows
- ✅ SPARC methodology support

#### Cross-Client Support

- ✅ Any MCP-compatible client
- ⚠️ Best experience with Claude Code

#### Pros

- Most feature-complete orchestration platform
- Built-in memory/RAG system
- Active development (v2.7 alpha)
- 84.8% SWE-Bench solve rate claimed

#### Cons

- Complex setup (many moving parts)
- Alpha quality (breaking changes possible)
- Heavy resource usage
- Steep learning curve

---

### 2. claude-swarm / SwarmSDK (v2)

**Repository:** https://github.com/parruda/claude-swarm
**Language:** Ruby | **Stars:** ~1.2k | **Install:** `gem install swarm_cli`

#### What It Does

- Ruby framework for multi-agent orchestration
- Single-process architecture (all agents in one Ruby process)
- Node workflows for multi-stage pipelines
- SwarmMemory with FAISS semantic search
- 12 hook events, 6 hook actions

#### Architecture

```yaml
version: 2
agents:
  lead:
    model: claude-3-5-sonnet-20241022
    role: "Lead developer"
    tools: [Read, Write, Edit, Bash]
    delegates_to: [frontend, backend]
    hooks:
      on_user_message:
        - run: "git diff"
          append_output_to_context: true
```

#### Claude Code Integration

- ❌ Decoupled from Claude Code (intentional design choice)
- Uses RubyLLM for direct API calls

#### Cross-Client Support

- ✅ **Best provider flexibility** - Works with Claude, OpenAI, Gemini via RubyLLM
- ✅ Rails integration
- ✅ Plugin system for extensions

#### Pros

- Clean Ruby DSL
- Single process (no MCP overhead)
- Provider-agnostic (any LLM)
- Node workflows for pipelines
- Cost tracking built-in

#### Cons

- Ruby-only (not ideal for non-Ruby shops)
- No Claude Code native features
- Smaller ecosystem than Node.js tools

---

### 3. claude-task-master (Taskmaster)

**Repository:** https://github.com/eyaltoledano/claude-task-master
**Language:** TypeScript/Node.js | **Stars:** ~15k | **Install:** `npx task-master-ai`

#### What It Does

- PRD → Task breakdown → Implementation workflow
- AI-powered task management with dependencies
- Research mode with Perplexity integration
- Works with multiple AI providers

#### Architecture

```
PRD Document
    ↓ parse-prd
Task Tree (tasks.json)
    ↓ expand/breakdown
Subtasks with Dependencies
    ↓ implement
Code Changes
```

#### Claude Code Integration

- ✅ `claude mcp add taskmaster-ai -- npx -y task-master-ai`
- ✅ Works as MCP server
- ✅ Supports `claude-code/sonnet` model (no API key)

#### Cross-Client Support

- ✅ **Best cross-client support:**
  - Cursor (one-click install)
  - VS Code
  - Windsurf
  - Zed (via MCP)
  - Claude Code
  - Q Developer CLI

#### Tool Loading Modes

| Mode | Tools | Tokens |
|------|-------|--------|
| `all` | 36 | ~21,000 |
| `standard` | 15 | ~10,000 |
| `core` | 7 | ~5,000 |

#### Pros

- **Most widely compatible** (works everywhere)
- Simple mental model (PRD → Tasks)
- Research integration (Perplexity)
- Active community (15k stars)
- One-click Cursor install

#### Cons

- Not true multi-agent (single orchestrator)
- No persistent memory system
- Task-focused (not general orchestration)

---

### 4. tsk

**Repository:** https://github.com/dtormoen/tsk
**Language:** Rust | **Stars:** ~500 | **Install:** `cargo install tsk-ai`

#### What It Does

- Sandboxed Docker environments for AI agents
- Parallel agent execution with git worktrees
- Task templates for common operations
- Returns git branches for human review

#### Architecture

```
┌─────────────────────────────────────────┐
│              TSK SERVER                  │
│         (manages parallel tasks)         │
├─────────────────────────────────────────┤
│  Task 1 (Docker)  │  Task 2 (Docker)    │
│  ├── /repo copy   │  ├── /repo copy     │
│  ├── claude agent │  ├── codex agent    │
│  └── git branch   │  └── git branch     │
├─────────────────────────────────────────┤
│        Squid Proxy (network control)     │
└─────────────────────────────────────────┘
```

#### Key Commands

```bash
tsk shell                    # Interactive sandbox
tsk run --type feat -n greeting -d "Add greeting"
tsk server start --workers 4 # Parallel execution
tsk add --agent claude,codex # Compare agents
```

#### Claude Code Integration

- ✅ Supports Claude Code as agent
- ✅ Supports Codex CLI
- ✅ Can run both in parallel for comparison

#### Cross-Client Support

- ⚠️ CLI-only (no IDE integration)
- ✅ Agent-agnostic (claude, codex, extensible)

#### Pros

- **Safest parallel execution** (Docker isolation)
- Git-native workflow (branches for review)
- Fast (Rust implementation)
- Agent comparison mode
- Network-controlled sandboxes

#### Cons

- CLI-only (no IDE integration)
- Requires Docker
- No persistent memory
- No MCP integration

---

### 5. Agent-MCP

**Repository:** https://github.com/rinadelph/Agent-MCP
**Language:** Python + Node.js | **Stars:** ~800 | **Install:** `uv run -m agent_mcp.cli`

#### What It Does

- Multi-agent coordination via MCP protocol
- Persistent knowledge graph (like "Obsidian for agents")
- Real-time dashboard visualization
- Short-lived ephemeral agents (vs long-lived)

#### Architecture

```
┌─────────────────────────────────────────┐
│            ADMIN AGENT                   │
│     (coordinates all workers)            │
├─────────────────────────────────────────┤
│  backend-worker  │  frontend-worker     │
│  integration     │  test-worker         │
│  devops-worker   │  security-worker     │
├─────────────────────────────────────────┤
│         SHARED KNOWLEDGE GRAPH           │
│    (MCD - Main Context Document)         │
└─────────────────────────────────────────┘
```

#### Agent Modes

- `AUTO --worker --memory` - Implementation mode
- `AUTO --worker --playwright` - Frontend with visual testing
- `AUTO --memory` - Research/read-only
- `AUTO --memory --manager` - Context curation

#### Claude Code Integration

- ✅ MCP server for Claude Desktop
- ⚠️ Requires manual agent mode setup

#### Cross-Client Support

- ✅ Any MCP client (Claude Desktop, VS Code, etc.)
- ✅ Python and Node.js implementations

#### Pros

- Strong knowledge graph / memory
- Dashboard visualization
- Ephemeral agents (clean context)
- MCD (Main Context Document) pattern

#### Cons

- "Advanced tool" - steep learning curve
- Complex setup (admin + workers)
- No native Claude Code skills
- Early stage development

---

### 6. Kilo Code (Bonus Alternative)

**Repository:** https://github.com/Kilo-Org/kilocode/
**Language:** TypeScript | **Stars:** ~5k | **Install:** VS Code/JetBrains extension

#### What It Does

- Model-agnostic agentic coding
- Orchestration mode for multi-step workflows
- Parallel agents via git worktrees
- Works with ANY LLM provider

#### Cross-Client Support

- ✅ VS Code, JetBrains, Cursor, Windsurf, CLI
- ✅ Any model (OpenRouter, local, etc.)

#### Pros

- **Best model flexibility** (no vendor lock-in)
- Native IDE integration
- Growing fast (#1 on OpenRouter)

#### Cons

- Not Claude-specific
- No MCP server mode
- Different paradigm than Claude Code

---

## Cross-Client Compatibility Matrix

| Tool | Claude Code | Cursor | VS Code | Zed | Windsurf | OpenCode/Crush | CLI |
|------|:-----------:|:------:|:-------:|:---:|:--------:|:--------------:|:---:|
| claude-flow | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠️ | ✅ |
| claude-swarm | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| task-master | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠️ | ✅ |
| tsk | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ |
| Agent-MCP | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠️ | ✅ |
| Kilo Code | ❌ | ✅ | ✅ | ❌ | ✅ | ❌ | ✅ |

**Legend:** ✅ Full support | ⚠️ Partial/untested | ❌ Not supported

**Note on OpenCode/Crush:** OpenCode has been archived and renamed to Crush. It uses its own TUI and doesn't support the Claude Code plugin system. MCP tools may work via its built-in MCP support.

---

## Claude Code Native Features Support

| Tool | Skills | Hooks | Plugins | Subagents | MCP Tools |
|------|:------:|:-----:|:-------:|:---------:|:---------:|
| claude-flow | ✅ 25 | ✅ | ✅ | ✅ | ✅ 100+ |
| claude-swarm | ❌ | ❌ | ❌ | ❌ | ❌ |
| task-master | ❌ | ❌ | ❌ | ❌ | ✅ 36 |
| tsk | ❌ | ❌ | ❌ | ❌ | ❌ |
| Agent-MCP | ❌ | ❌ | ❌ | ❌ | ✅ |

### Claude Code Plugin System Overview

- **Skills**: SKILL.md files that auto-activate based on triggers
- **Hooks**: Pre/post operation automation
- **Plugins**: Packaged collections (commands, agents, MCP, hooks)
- **Subagents**: Parallel isolated workers via Claude Agent SDK

See [Claude Code Plugins](https://www.anthropic.com/news/claude-code-plugins) and [claude-code-plugins-plus](https://github.com/jeremylongshore/claude-code-plugins-plus) (257 plugins, 240 skills).

---

## Recommendations

### Two-Toolset Approach

#### Toolset 1: Cross-Client (MCP-Based)

**Recommendation: claude-task-master (Taskmaster)**

**Why:**
- ✅ Widest client support (Cursor, VS Code, Windsurf, Zed, Claude Code)
- ✅ Simple mental model (PRD → Tasks → Implementation)
- ✅ Tool loading modes to manage context
- ✅ Research integration
- ✅ 15k stars, active community
- ✅ One-click installs for most IDEs

**Use For:**
- Project planning and task breakdown
- Cross-IDE workflows
- Teams with mixed tooling

```bash
# Install everywhere
claude mcp add taskmaster-ai -- npx -y task-master-ai
```

#### Toolset 2: Claude Code Native

**Recommendation: claude-flow**

**Why:**
- ✅ **Deepest Claude Code integration** (25 native Skills)
- ✅ Full plugin system support
- ✅ Hooks for automation
- ✅ Hive-mind multi-agent orchestration
- ✅ Persistent memory (AgentDB + ReasoningBank)
- ✅ MCP tools (100+)

**Use For:**
- Complex multi-agent workflows
- Long-running projects needing memory
- Maximum Claude Code feature usage

```bash
# Full Claude Code setup
npx claude-flow@alpha init --force
claude mcp add claude-flow npx claude-flow@alpha mcp start
```

### Alternative Combinations

| If You Need... | Use Instead |
|----------------|-------------|
| **Ruby ecosystem** | SwarmSDK (cross-client via RubyLLM) |
| **Safe parallel experiments** | tsk (Docker sandboxes) |
| **Model flexibility** | Kilo Code (any provider) |
| **Knowledge graph focus** | Agent-MCP (MCD pattern) |

---

## Quick Decision Tree

```
What's your priority?
│
├─► Cross-client compatibility
│   └─► claude-task-master ✅
│
├─► Maximum Claude Code features
│   └─► claude-flow ✅
│
├─► Safe parallel agent execution
│   └─► tsk ✅
│
├─► Provider flexibility (not just Claude)
│   ├─► Ruby shop → SwarmSDK ✅
│   └─► IDE-native → Kilo Code ✅
│
└─► Knowledge graph / memory focus
    └─► Agent-MCP ✅
```

---

## References

- [claude-flow](https://github.com/ruvnet/claude-flow)
- [claude-swarm / SwarmSDK](https://github.com/parruda/claude-swarm)
- [claude-task-master](https://github.com/eyaltoledano/claude-task-master)
- [tsk](https://github.com/dtormoen/tsk)
- [Agent-MCP](https://github.com/rinadelph/Agent-MCP)
- [Kilo Code](https://github.com/Kilo-Org/kilocode/)
- [Claude Code Plugins](https://www.anthropic.com/news/claude-code-plugins)
- [Claude Agent SDK](https://www.anthropic.com/engineering/building-agents-with-the-claude-agent-sdk)
- [claude-code-plugins-plus](https://github.com/jeremylongshore/claude-code-plugins-plus)
- [Zed MCP Documentation](https://zed.dev/docs/ai/mcp)
- [Agent Client Protocol (ACP)](https://blog.jetbrains.com/ai/2025/10/jetbrains-zed-open-interoperability-for-ai-coding-agents-in-your-ide/)
- [OpenCode (archived)](https://github.com/opencode-ai/opencode)

---

> [!info] Metadata
> **Scope**: `= this.scope`
> **Type**: `= this.type`
> **Status**: `= this.status`
