🏆 Top Tier - Production Ready

### 1. **Workflows MCP Server** ⭐ Most Mature

- **GitHub**: [cyanheads/workflows-mcp-server](https://github.com/cyanheads/workflows-mcp-server)
- **Stars**: 24 | **License**: Apache-2.0
- **Language**: TypeScript/Node.js
- **Status**: ✅ Active, production-ready

**What it does:**

- **YAML-based workflow orchestration** - Define multi-step workflows declaratively
- **Dynamic workflow creation** - Create temporary workflows on-the-fly for complex tasks
- **Global instructions** - Inject context into all workflows without modifying them
- **Dual transport**: stdio + HTTP/SSE

**Key Features:**

```yaml/dev/null/workflow-example.yaml#L1-15
# Example workflow definition
name: "Deploy Application"
category: "DevOps"
tags: ["deployment", "ci-cd"]
steps:
  - name: "Run tests"
    tool: "run_command"
    args: {command: "npm test"}
  - name: "Build application"
    tool: "run_command"
    args: {command: "npm build"}
  - name: "Deploy to production"
    tool: "deploy"
    args: {env: "production"}
```

**Strengths:**

- ✅ Declarative workflow definitions
- ✅ Template system for reusable workflows
- ✅ HTTP transport (can be exposed via Traefik)
- ✅ Active development
- ✅ JWT/OAuth authentication support

**Self-Hosting:**

```json/dev/null/workflows-config.json#L1-12
{
  "mcpServers": {
    "workflows": {
      "command": "docker",
      "args": ["run", "--rm", "-i",
               "--network", "mcp-global_default",
               "-v", "$HOME/.config/workflows:/workflows",
               "workflows-mcp-server"],
      "env": {
        "MCP_TRANSPORT_TYPE": "http"
      }
    }
  }
}
```

---

### 2. **Task Manager MCP** (tradesdontlie)

- **GitHub**: [tradesdontlie/task-manager-mcp](https://github.com/tradesdontlie/task-manager-mcp)
- **Stars**: 30 | **License**: MIT
- **Language**: Python
- **Status**: ✅ Active

**What it does:**

- **PRD parsing** - Automatically converts Product Requirements Documents into tasks
- **Task complexity estimation** - AI-powered task analysis
- **File template generation** - Generates code templates from task descriptions
- **Multi-LLM support** - OpenAI, OpenRouter, Ollama

**Key Features:**

```/dev/null/task-manager-features.txt#L1-12
Tools:
- create_task_file     - Create project task files
- add_task             - Add tasks with subtasks
- update_task_status   - Track progress
- get_next_task        - Get next uncompleted task
- parse_prd            - Convert PRD to structured tasks
- expand_task          - Break down into subtasks
- estimate_task_complexity
- get_task_dependencies
- generate_task_file   - Generate file templates
- suggest_next_actions - AI-powered suggestions
```

**Strengths:**

- ✅ AI-powered task intelligence
- ✅ PRD parsing (unique feature)
- ✅ SSE + stdio transport
- ✅ Docker support
- ✅ Works with local LLMs (Ollama)

**Comparison to SimpleCheckList:**
| Feature | Task Manager MCP | SimpleCheckList |
|---------|------------------|-----------------|
| AI-powered | ✅ Yes | ❌ No |
| PRD parsing | ✅ Yes | ❌ No |
| Complexity estimation | ✅ Yes | ❌ No |
| Web UI | ❌ No | ✅ Yes |
| Hierarchical structure | ✅ Yes | ✅ Yes

6. **Todoist MCP Server**

- **GitHub**: [koji0701/todoist-mcp-server](https://github.com/koji0701/todoist-mcp-server)
- **Stars**: 1 | **License**: MIT
- **Language**: Python
- **Status**: ✅ Active

**What it does:**

- Full Todoist API integration
- Creates, reads, updates, deletes tasks in Todoist
- Projects, sections, labels, comments support

**Self-Hostable**: ✅ Yes (but requires Todoist account)

**Use Cases:**

- Combine with Gmail MCP to auto-create tasks from emails
- Time-block tasks based on calendar availability
- Share structured project plans with team

7. **Jira MCP Server** (rixbeck)

- **GitHub**: [rixbeck/jira-mcp](https://github.com/rixbeck/jira-mcp)
- **License**: MIT (assumed)
- **Language**: Python (assumed)
- **Status**: ✅ Active

**What it does:**

- Integration with **self-hosted Jira**
- Issue and project management
- AI assistant interface to Jira
