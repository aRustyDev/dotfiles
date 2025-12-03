---
id: 8F3A4B2C-9D1E-4F5A-B6C7-8D9E0F1A2B3C
title: "Using Claude Code with GitHub Copilot in Corporate Environments"
status: "✅ Completed"
date: 2025-12-03
author: AI Assistant
related: []
children: []
---

# Using Claude Code with GitHub Copilot in Corporate Environments

## Overview

This guide analyzes how to leverage Claude Code's ecosystem (plugins, SKILLS, conventions) while working under corporate restrictions that only allow GitHub Copilot for model access. It compares this approach to using Zed and explains the architectural differences.

## Background

Many corporate environments restrict direct API access to AI models like Claude, but allow GitHub Copilot. The blog post at [f12.no](https://blog.f12.no/wp/2025/09/22/using-claude-code-with-github-copilot-a-guide/) demonstrates how to configure Claude Code to use Copilot as its backend model provider.

## Architecture Comparison

### Blog Post Approach (✅ Recommended)

```
Terminal → Claude Code CLI → Copilot API → Claude models
```

**How it works:**
- Claude Code orchestrates the agent loop
- Claude Code provides plugins, SKILLS, and conventions
- Copilot API provides model inference (accessing Claude models)
- All Claude Code features remain available

**Benefits:**
- ✅ Full Claude Code ecosystem access
- ✅ Corporate-compliant (Copilot only)
- ✅ Native `.rules` file support
- ✅ Project-aware context
- ✅ Plugin system available

### Zed Approach (❌ Not Compatible)

```
Zed → Built-in Agent → Copilot API
```

**Why this doesn't work for the goal:**
- Zed controls the agent loop internally
- No "external agent" abstraction exists
- MCP servers in Zed provide TOOLS, not agent orchestration
- Cannot delegate to Claude Code as external agent

**Zed's Current Architecture:**
```
Zed Editor
├── Built-in Agent System
├── MCP Context Servers (tools/data providers)
│   ├── GitHub MCP
│   ├── GitLab MCP
│   ├── Docker MCP
│   └── Custom MCP servers
└── Model Providers
    ├── Copilot (with Claude models)
    ├── Anthropic Direct
    └── Others
```

**What you CAN'T do with Zed:**
```
Zed → External Claude Code Agent → Copilot API
```

This architecture is not supported because Zed manages its own agent loop.

## Context & Rules File Handling

### In Claude Code

Claude Code natively understands project structure:

```bash
# In terraform-provider-addy project
cd ~/code/oss/terraform-provider-addy
claude code

# Claude Code will:
# ✅ Read terraform-provider-addy/.rules
# ✅ Read terraform-provider-addy/.claude/*
# ✅ Apply those policies to this session
```

**Automatic Context Switching:**
```bash
# Switch to different project
cd ~/code/oss/domains
claude code

# Claude Code will:
# ✅ Read domains/.rules instead
# ✅ Load domains/.claude/* files
# ✅ Apply domain-specific policies
```

### In Zed (Multi-Repo Workspace)

When Zed has multiple project roots:
```
Workspace:
├── /Users/adamsm/.config
├── /Users/adamsm/.local
├── /Users/adamsm/code/oss/domains
├── /Users/adamsm/code/oss/templates
└── /Users/adamsm/code/oss/terraform-provider-addy
```

**Current Behavior:**
1. Sends UI-configured custom instructions (global across workspace)
2. Does NOT automatically merge multiple `.rules` files
3. Context is workspace-wide, not per-root
4. No automatic "rules switching" based on active file

**Workarounds for Zed:**

#### Option A: Manual Context Management
```
User: "Read the terraform-provider-addy/.rules file before we start"
```

#### Option B: Workspace-Level Rules
Create a unified rules file:
```markdown
# Workspace Rules

This workspace contains multiple projects:

1. `terraform-provider-addy/` - See terraform-provider-addy/.rules
2. `domains/` - See domains/.rules
3. `templates/` - See templates/.rules

Agent: Always check the .rules file in the directory tree 
of the file you're modifying.
```

#### Option C: Agent Profiles
Configure different agent profiles for different contexts:
```json
{
  "agent": {
    "profiles": {
      "terraform-provider": {
        "name": "Terraform Provider Work",
        "custom_instructions": "Read and follow terraform-provider-addy/.rules"
      },
      "domains": {
        "name": "Domains Work", 
        "custom_instructions": "Read and follow domains/.rules"
      }
    }
  }
}
```

## Recommended Workflow

### For Corporate Copilot-Only Environments

**Use Claude Code CLI with Copilot Backend:**

1. **Install Claude Code**
   ```bash
   # Follow installation instructions from Anthropic
   ```

2. **Configure Copilot Backend**
   ```json
   // Claude Code configuration
   {
     "modelProvider": "copilot",
     "copilot": {
       "model": "claude-opus-4.5"
     }
   }
   ```

3. **Use Per-Project Sessions**
   ```bash
   # Terminal 1: Terraform Provider work
   cd ~/code/oss/terraform-provider-addy
   claude code
   # Automatically reads .rules and .claude/

   # Terminal 2: Domains work
   cd ~/code/oss/domains
   claude code
   # Reads domains-specific rules
   ```

4. **Use Zed for Editing Only**
   - Use Zed as your text editor
   - Use Claude Code CLI for AI agent work
   - Best of both worlds

### Alternative: Cursor IDE

If you need tight IDE integration, consider **Cursor** instead of Zed:

**Why Cursor Might Be Better:**
- Built on VS Code
- More flexible agent configuration
- Supports agent mode + composer
- Potentially works with external agents
- Better corporate tooling support

**Zed Limitations:**
- Tightly integrated agent
- Less flexible for external agent use cases
- No "external agent" support

## Configuration Examples

### Zed with Copilot (Current Setup)

```json
// .config/zed/settings.json
{
  "agent": {
    "default_profile": "write",
    "default_model": {
      "provider": "copilot_chat",
      "model": "claude-opus-4.5"
    },
    "always_allow_tool_actions": true
  }
}
```

**This gives you:**
- ✅ Zed's built-in agent
- ✅ Copilot access to Claude models
- ❌ NOT Claude Code's ecosystem
- ❌ NOT Claude Code's plugins/SKILLS

### Claude Code with Copilot (Recommended)

```json
// Claude Code configuration
{
  "modelProvider": "copilot",
  "copilot": {
    "model": "claude-opus-4.5",
    "apiEndpoint": "https://api.githubcopilot.com"
  },
  "mcp": {
    "servers": {
      // Claude Code's MCP servers
      "filesystem": { /* ... */ },
      "git": { /* ... */ }
    }
  }
}
```

**This gives you:**
- ✅ Full Claude Code ecosystem
- ✅ Copilot access to Claude models
- ✅ Plugins and SKILLS
- ✅ Native `.rules` support
- ✅ Project-aware context

## Why Building a Bridge Doesn't Make Sense

You might consider building an MCP bridge:

```
Custom MCP Server (local)
  ↓ exposes tools from
Claude Code CLI (subprocess)
  ↓ uses models from
GitHub Copilot API

Then configure Zed to use this bridge
```

**Why this is a bad idea:**
- ⚠️ Extremely complex architecture
- ⚠️ Defeats the purpose of Claude Code
- ⚠️ You'd be reinventing Claude Code
- ⚠️ Maintenance nightmare
- ⚠️ No real benefit over using Claude Code directly

## Summary

| Approach | Claude Code Ecosystem | Copilot Compliant | .rules Support | Complexity |
|----------|----------------------|-------------------|----------------|------------|
| **Claude Code CLI + Copilot** | ✅ Full | ✅ Yes | ✅ Native | Low |
| **Zed + Copilot** | ❌ No | ✅ Yes | ⚠️ Manual | Low |
| **Custom Bridge** | ⚠️ Partial | ✅ Yes | ⚠️ Depends | Very High |
| **Cursor + Copilot** | ⚠️ Partial | ✅ Yes | ⚠️ Manual | Medium |

## Final Recommendations

1. **Use Claude Code CLI** with Copilot backend for AI agent work
2. **Use separate Claude Code sessions** for each project (automatic `.rules` handling)
3. **Use Zed** just for file editing, not for AI orchestration
4. **Don't build a bridge** - use the right tool for the job

This approach gives you:
- ✅ Claude Code ecosystem (plugins, SKILLS, conventions)
- ✅ Corporate-compliant Copilot access
- ✅ Automatic `.rules` file handling per project
- ✅ Project-aware context switching
- ✅ Best of both worlds (great editor + great AI agent)

## References

- [Blog post: Using Claude Code with GitHub Copilot](https://blog.f12.no/wp/2025/09/22/using-claude-code-with-github-copilot-a-guide/)
- [Model Context Protocol Servers Registry](https://github.com/modelcontextprotocol/servers)
- [Zed Documentation](https://zed.dev/docs)
- [Claude Code Documentation](https://docs.anthropic.com/claude-code)

## Questions Answered

### Q: Can I configure Zed to use an external Claude Code agent with Copilot?

**A:** No. Zed does not have an "external agent server" abstraction. Zed's agent loop is built into the editor itself. MCP servers in Zed provide *tools* and *context*, not agent orchestration.

### Q: How do .rules files work with multiple projects in Zed?

**A:** Zed currently:
- Sends global custom instructions across the entire workspace
- Does NOT automatically merge multiple `.rules` files
- Does NOT switch context based on the active file

You need to manually manage context or use agent profiles.

### Q: Which .rules file "wins" in a multi-repo Zed workspace?

**A:** None automatically. Zed doesn't have built-in `.rules` file handling. You must:
- Add global custom instructions to read the appropriate `.rules` file
- Create workspace-level rules that reference project-specific ones
- Use agent profiles for different projects
- Manually prompt the agent to read specific `.rules` files

### Q: Does the external agent get access to Zed's rules library?

**A:** This question assumes an architecture that doesn't exist. Zed doesn't support external agents. It has:
- Built-in agent system
- MCP context servers (for tools/data)
- Model providers (like Copilot)

But no way to delegate agent orchestration to external systems like Claude Code.

### Q: Should I use Zed or Claude Code for corporate Copilot environments?

**A:** Use **Claude Code CLI** for AI agent work and **Zed** for file editing. They serve different purposes:
- **Claude Code**: Agent orchestration, plugins, SKILLS, `.rules` support
- **Zed**: Fast, lightweight text editor with built-in AI features

Don't try to make Zed do what Claude Code does better.
