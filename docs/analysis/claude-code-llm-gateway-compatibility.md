---
id: a1b2c3d4-e5f6-7890-abcd-ef1234567890
title: Claude Code LLM Gateway Compatibility
created: 2025-12-13T00:00:00
updated: 2025-12-13T16:17
project: dotfiles
scope:
  - ai
  - claude-code
  - mcp
type: analysis
status: ✅ approved
publish: false
tags:
  - claude-code
  - litellm
  - llm-gateway
  - bedrock
  - vertex
  - compatibility
aliases:
  - LiteLLM Compatibility
  - Claude Code Gateway Analysis
related:
  - ref: "[[adr-agent-framework-strategy]]"
    description: Agent framework strategy
  - ref: "[[agentic-workflow-toolset-comparison]]"
    description: Agentic workflow tools comparison
---

# Claude Code LLM Gateway Compatibility

Analysis of Claude Code feature compatibility when using LLM gateways like LiteLLM, OpenRouter, or cloud provider backends (Bedrock, Vertex).

---

## Executive Summary

**Key Finding**: Most Claude Code features work through LLM gateways because they're **client-side** features. The CLI loads Skills, Plugins, Hooks, and Memory locally, then assembles them into standard Messages API requests.

| Category | Compatibility |
|----------|---------------|
| Client-side features (Skills, Plugins, Hooks, MCP) | ✅ Full |
| Server-side optimizations (caching, extended thinking) | ⚠️ Partial |
| Beta features (1M context, interleaved thinking) | ❌ Broken |

---

## How Claude Code Features Are Processed

```
┌─────────────────────────────────────────────────────────────────┐
│                      CLAUDE CODE CLI                             │
├─────────────────────────────────────────────────────────────────┤
│  1. Load Skills from ~/.claude/skills/ and .claude/skills/      │
│  2. Load Plugins from marketplaces                               │
│  3. Load Memory from CLAUDE.md files                             │
│  4. Execute Hooks locally (bash or prompt-based)                 │
│  5. Run MCP tool calls locally                                   │
│  6. Manage Sub-agent contexts separately                         │
│                                                                  │
│  ALL OF THIS ──► Assembled into Messages API request             │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    STANDARD MESSAGES API                         │
│                                                                  │
│  { "model": "claude-sonnet-4", "messages": [...] }              │
│                                                                  │
│  Skills/Plugins/Memory = injected into system prompt            │
│  MCP tools = tool definitions + tool results in messages        │
│  Sub-agents = separate API calls with own contexts              │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    LiteLLM / OpenRouter (proxy)
                              │
                              ▼
                    Anthropic / Bedrock / Vertex
```

---

## Feature-by-Feature Compatibility

### Client-Side Features (✅ Full Compatibility)

These features work entirely through prompt engineering and local execution. They don't require special API capabilities beyond standard Messages API.

#### Skills

| Aspect | Details |
|--------|---------|
| **Loading** | Local filesystem (`~/.claude/skills/`, `.claude/skills/`) |
| **Processing** | `SKILL.md` content injected into system prompt |
| **API Dependency** | None - standard Messages API |
| **Gateway Compatible** | ✅ Yes |

#### Plugins

| Aspect | Details |
|--------|---------|
| **Loading** | Local marketplace discovery and loading |
| **Components** | Commands, agents, hooks, skills, MCP servers |
| **API Dependency** | None - components processed locally |
| **Gateway Compatible** | ✅ Yes |

#### Hooks

| Aspect | Details |
|--------|---------|
| **Loading** | `settings.json` configuration |
| **Types** | Bash scripts (local) or prompts (uses Haiku) |
| **API Dependency** | Prompt hooks use standard fast model calls |
| **Gateway Compatible** | ✅ Yes |

#### Sub-agents

| Aspect | Details |
|--------|---------|
| **Loading** | `.claude/agents/` or `~/.claude/agents/` |
| **Processing** | Separate context windows, independent API calls |
| **API Dependency** | Standard Messages API per agent |
| **Gateway Compatible** | ✅ Yes |

#### Memory (CLAUDE.md)

| Aspect | Details |
|--------|---------|
| **Loading** | Hierarchical file loading with imports |
| **Processing** | Content injected into system prompt |
| **API Dependency** | None - pure prompt engineering |
| **Gateway Compatible** | ✅ Yes |

#### MCP Tools

| Aspect | Details |
|--------|---------|
| **Loading** | MCP servers run locally or remotely |
| **Processing** | Tool definitions sent, execution local |
| **API Dependency** | Standard tool use (Messages API) |
| **Gateway Compatible** | ✅ Yes |

#### Model Aliases

| Aspect | Details |
|--------|---------|
| **Processing** | CLI resolves `sonnet`, `opus`, `haiku` to model names |
| **Configuration** | Environment variables for custom names |
| **Gateway Compatible** | ✅ Yes |

**Custom Model Names**:
```bash
export ANTHROPIC_DEFAULT_SONNET_MODEL=your-gateway-sonnet-name
export ANTHROPIC_DEFAULT_OPUS_MODEL=your-gateway-opus-name
export ANTHROPIC_DEFAULT_HAIKU_MODEL=your-gateway-haiku-name
```

---

### Server-Side Features (⚠️ Partial Compatibility)

These features depend on server-side API capabilities and may require special headers.

#### Prompt Caching

| Aspect | Details |
|--------|---------|
| **Processing** | Server-side (Anthropic/Bedrock/Vertex) |
| **Basic Caching** | Now GA, works without special headers |
| **Extended TTL** | Requires `anthropic-beta: extended-cache-ttl-2025-04-11` |
| **Gateway Compatible** | ⚠️ Basic works, extended TTL may fail |

#### Extended Thinking

| Aspect | Details |
|--------|---------|
| **Processing** | Server-side |
| **Basic Thinking** | Uses `thinking` parameter in request body |
| **Interleaved Mode** | Requires `anthropic-beta: interleaved-thinking-2025-05-14` |
| **Gateway Compatible** | ⚠️ Basic works, interleaved may fail |

---

### Beta Features (❌ Broken)

These features require `anthropic-beta` headers that LiteLLM doesn't properly forward.

#### Extended 1M Context

| Aspect | Details |
|--------|---------|
| **Requirement** | `anthropic-beta: context-1m-2025-08-07` header |
| **LiteLLM Issue** | [#15622](https://github.com/BerriAI/litellm/issues/15622) - headers not forwarded to Bedrock |
| **Impact** | Requests may silently fall back to standard context |
| **Gateway Compatible** | ❌ No |

#### Interleaved Thinking (Claude 4)

| Aspect | Details |
|--------|---------|
| **Requirement** | `anthropic-beta: interleaved-thinking-2025-05-14` header |
| **LiteLLM Issue** | [#15299](https://github.com/BerriAI/litellm/issues/15299) - headers not forwarded to Vertex |
| **Gateway Compatible** | ❌ No |

---

## Summary Matrix

| Feature | Client/Server | Special Headers | LiteLLM | Bedrock Native | Vertex Native |
|---------|---------------|-----------------|---------|----------------|---------------|
| Skills | Client | None | ✅ | ✅ | ✅ |
| Plugins | Client | None | ✅ | ✅ | ✅ |
| Hooks | Client | None | ✅ | ✅ | ✅ |
| Sub-agents | Client | None | ✅ | ✅ | ✅ |
| Memory | Client | None | ✅ | ✅ | ✅ |
| MCP Tools | Client | None | ✅ | ✅ | ✅ |
| Model Aliases | Client | None | ✅ | ✅ | ✅ |
| Prompt Caching (basic) | Server | None (GA) | ✅ | ✅ | ✅ |
| Prompt Caching (extended TTL) | Server | `anthropic-beta` | ⚠️ | ✅ | ✅ |
| Extended Thinking (basic) | Server | None | ✅ | ✅ | ✅ |
| Extended Thinking (interleaved) | Server | `anthropic-beta` | ❌ | ✅ | ✅ |
| Extended 1M Context | Server | `anthropic-beta` | ❌ | ✅ | ✅ |

---

## Known LiteLLM Issues

### Header Forwarding Bugs

| Issue | Description | Status |
|-------|-------------|--------|
| [#15622](https://github.com/BerriAI/litellm/issues/15622) | `anthropic-beta` not forwarded to Bedrock | Open |
| [#15299](https://github.com/BerriAI/litellm/issues/15299) | `anthropic-beta` not forwarded to Vertex AI | Open |
| [#9016](https://github.com/BerriAI/litellm/issues/9016) | `anthropic-beta` not forwarded on proxy | Open |
| [#9020](https://github.com/BerriAI/litellm/issues/9020) | Extended thinking + output-128k beta conflict | Open |

### Claude Code Documentation Warning

> "Failure to forward headers or preserve body fields may result in reduced functionality or inability to use Claude Code features."

**Required forwards**:
- `anthropic-beta` header (Anthropic Messages, Vertex)
- `anthropic-version` header
- `anthropic_beta` body field (Bedrock)
- `anthropic_version` body field (Bedrock)

---

## Configuration Options

### Native Backends (Full Feature Support)

#### Direct Anthropic API
```bash
export ANTHROPIC_API_KEY=sk-ant-...
# No additional configuration needed
```

#### AWS Bedrock Native
```bash
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_REGION=us-east-1
# Uses AWS credentials from environment/profile
```

#### Google Vertex Native
```bash
export CLAUDE_CODE_USE_VERTEX=1
export CLOUD_ML_REGION=us-east5
export ANTHROPIC_VERTEX_PROJECT_ID=your-project
# Uses Google credentials from environment
```

### LiteLLM Gateway

#### Unified Endpoint (Recommended)
```bash
export ANTHROPIC_BASE_URL=https://litellm-server:4000
export ANTHROPIC_AUTH_TOKEN=sk-litellm-key
```

#### Pass-through Anthropic
```bash
export ANTHROPIC_BASE_URL=https://litellm-server:4000/anthropic
export ANTHROPIC_AUTH_TOKEN=sk-litellm-key
```

#### Pass-through Bedrock
```bash
export ANTHROPIC_BEDROCK_BASE_URL=https://litellm-server:4000/bedrock
export CLAUDE_CODE_SKIP_BEDROCK_AUTH=1
export CLAUDE_CODE_USE_BEDROCK=1
```

#### Pass-through Vertex
```bash
export ANTHROPIC_VERTEX_BASE_URL=https://litellm-server:4000/vertex_ai/v1
export ANTHROPIC_VERTEX_PROJECT_ID=your-project
export CLAUDE_CODE_SKIP_VERTEX_AUTH=1
export CLAUDE_CODE_USE_VERTEX=1
export CLOUD_ML_REGION=us-east5
```

### Disable Problematic Features

```bash
# Disable prompt caching if causing issues
export DISABLE_PROMPT_CACHING=1

# Disable experimental betas when using gateway with Bedrock/Vertex format
export CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1
```

---

## Recommendations

### When to Use LLM Gateway

✅ **Good fit**:
- Centralized usage tracking and cost controls
- Team-wide authentication management
- Audit logging requirements
- Load balancing and fallback handling
- Standard coding workflows (Skills, Plugins, MCP work fine)

❌ **Poor fit**:
- Heavy reliance on prompt caching cost optimization
- Need for extended 1M context windows
- Using interleaved thinking (Claude 4)
- Cutting-edge beta features

### Decision Matrix

| Scenario | Recommendation |
|----------|----------------|
| Full feature access needed | Direct Anthropic API or native Bedrock/Vertex |
| Enterprise cost tracking | LiteLLM (accept beta feature limitations) |
| Mixed requirements | Route feature-rich traffic direct, cost-sensitive through gateway |
| Bedrock compliance required | Native Bedrock (`CLAUDE_CODE_USE_BEDROCK=1`) |

### Hybrid Approach

For maximum flexibility, consider:

1. **Interactive development**: Direct Anthropic API (full features)
2. **Batch/background work**: LiteLLM → Bedrock (cost tracking)
3. **Production agents**: Native Bedrock (compliance + full features)

---

## Cross-Model Compatibility (Non-Claude Models)

### The Question

Can you use Claude Code with a non-Claude model (e.g., GPT-5) through an LLM gateway?

```
Claude Code CLI
      │
      │  ← Skills, Plugins, Hooks loaded HERE (client-side)
      │  ← Assembled into Anthropic Messages API format
      │
      ▼
   LiteLLM (translates API format)
      │
      ▼
GitHub Enterprise Copilot / OpenRouter / etc.
      │
      ▼
   Model (GPT-5, Gemini, Llama, etc.)
```

### Short Answer

**Technically functional, but degraded experience.**

### What Works (Syntactically)

| Feature | Status | Notes |
|---------|--------|-------|
| Skills | ⚠️ Loads | Prompt injection works, but model interprets differently |
| Plugins | ⚠️ Loads | Components load, behavior varies |
| Hooks | ✅ Works | Client-side execution, model-agnostic |
| Memory | ⚠️ Loads | Prompt injection works, interpretation varies |
| MCP Tools | ⚠️ Partial | Requires LiteLLM to translate tool schemas |

### What Breaks (Semantically)

| Issue | Impact |
|-------|--------|
| **Prompt interpretation** | Skills designed for Claude may not trigger correctly on GPT/Gemini |
| **Tool calling schema** | Anthropic vs OpenAI format differences (LiteLLM translates, but imperfectly) |
| **System prompt handling** | Models interpret system prompts differently |
| **Thinking/reasoning** | Claude-specific features (extended thinking) don't exist |
| **Response format** | Different models structure responses differently |

### LiteLLM Translation

LiteLLM can translate between Anthropic and OpenAI API formats:

```python
# LiteLLM handles format translation internally:
# - Anthropic Messages → OpenAI Chat Completions
# - Anthropic tool_use → OpenAI function_calling
# - But behavioral differences remain
```

**The translation is syntactic, not semantic.** The API request gets reformatted correctly, but the model's interpretation of that prompt differs.

### Scenario Comparison

#### Claude Code → LiteLLM → **Claude Model**

```
✅ Skills work as designed (same model family)
✅ Tool schemas native (no translation needed)
✅ Prompt format native
✅ Response patterns expected
⚠️ Beta features may break (header forwarding)
```

#### Claude Code → LiteLLM → **Non-Claude Model (GPT-5, Gemini)**

```
⚠️ Skills load but may behave unexpectedly
⚠️ Tool calls translated (potential edge cases)
⚠️ System prompt interpreted differently
⚠️ Response format variations
❌ Claude-specific features unavailable
❌ Skills tuned for Claude's behavior won't transfer perfectly
```

### Recommendation

| Goal | Best Approach |
|------|---------------|
| Use Claude through enterprise gateway | Claude Code → LiteLLM → Claude (Bedrock/Vertex/GitHub) |
| Use GPT-5 | Native OpenAI client (Cursor, Continue, Copilot Chat) |
| Use Gemini | Native Google client or Gemini-optimized tooling |
| Multi-model flexibility | Separate clients per model family |

### Why Not Force Cross-Model?

1. **Skills are prompt engineering** - Prompt patterns that work well for Claude may not work for GPT
2. **Tool schemas differ** - Even with translation, edge cases exist
3. **No ecosystem benefit** - GPT has its own plugin/skill ecosystems (GPTs, Copilot extensions)
4. **Debugging complexity** - Hard to tell if issues are gateway, translation, or model behavior

### If You Must Use Non-Claude Models

1. **Test Skills individually** - Verify each Skill works with target model
2. **Simplify prompts** - Remove Claude-specific language from Skills
3. **Monitor tool calls** - Watch for translation failures
4. **Accept degradation** - Some features simply won't work the same

---

## Testing Gateway Compatibility

### Verify Header Forwarding

```bash
# Test if extended thinking headers forward
curl -X POST https://your-litellm/v1/messages \
  -H "Content-Type: application/json" \
  -H "anthropic-beta: interleaved-thinking-2025-05-14" \
  -H "anthropic-version: 2023-06-01" \
  -H "x-api-key: your-key" \
  -d '{
    "model": "claude-sonnet-4-20250514",
    "max_tokens": 1024,
    "thinking": {"type": "enabled", "budget_tokens": 500},
    "messages": [{"role": "user", "content": "test"}]
  }'
```

### Check Claude Code Status

```bash
# Verify configuration
claude /status

# Enable debug logging
export ANTHROPIC_LOG=debug
claude "test message"
```

---

## References

- [Claude Code LLM Gateway Documentation](https://code.claude.com/docs/en/llm-gateway)
- [Claude Code Skills Documentation](https://code.claude.com/docs/en/skills)
- [Claude Code Plugins Documentation](https://code.claude.com/docs/en/plugins)
- [Claude Code Sub-agents Documentation](https://code.claude.com/docs/en/sub-agents)
- [Claude Code Hooks Documentation](https://code.claude.com/docs/en/hooks)
- [Claude Code Amazon Bedrock](https://code.claude.com/docs/en/amazon-bedrock)
- [Claude Code Model Configuration](https://code.claude.com/docs/en/model-config)
- [LiteLLM Anthropic Provider](https://docs.litellm.ai/docs/providers/anthropic)
- [LiteLLM Prompt Caching](https://docs.litellm.ai/docs/completion/prompt_caching)

---

> [!info] Metadata
> **Scope**: `= this.scope`
> **Type**: `= this.type`
> **Status**: `= this.status`
