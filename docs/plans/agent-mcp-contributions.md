---
id: f6a7b8c9-d0e1-2345-f678-901234567890
title: "Plan: Agent-MCP Contributions"
created: 2025-12-13T00:00:00
updated: 2025-12-13T00:00:00
project: dotfiles
scope:
  - ai
  - agents
  - open-source
type: plan
status: 📝 draft
publish: false
tags:
  - plan
  - agent-mcp
  - contributions
  - open-source
  - multi-agent
aliases:
  - Agent-MCP Contribution Plan
related:
  - ref: "[[adr-agent-framework-strategy]]"
    description: Overall agent framework strategy
  - ref: "[[adr-memory-channel-architecture]]"
    description: Memory architecture design
plan:
  phase: discovery
  priority: medium
  effort: L
---

# Plan: Agent-MCP Contributions

Planned contributions to the [Agent-MCP](https://github.com/rinadelph/Agent-MCP) project to fill identified gaps and extend functionality for personal and community benefit.

---

## Motivation

Agent-MCP provides valuable multi-agent coordination patterns but lacks several features critical for production workflows:

1. **No git worktree support** - Parallel agents can't work on isolated branches
2. **Complex containerization** - Docker setup is manual and error-prone
3. **No Skills system** - Can't leverage Claude Code's native Skills
4. **Limited memory adapters** - No Graphiti integration

Contributing these features:
- Fills gaps for personal use
- Benefits the broader community
- Builds expertise in multi-agent systems
- Establishes reputation for Phase 3 framework

---

## Contribution 1: Git Worktree Support

### Problem

Agents working on the same codebase can conflict. There's no isolation between parallel workers.

### Solution

Add native git worktree support so each agent gets an isolated working directory.

### Design

```python
# agent_mcp/tools/git_worktree.py

class GitWorktreeTool:
    """MCP tool for managing git worktrees for agent isolation."""

    async def create_worktree(
        self,
        branch_name: str,
        base_branch: str = "main",
        agent_id: str = None
    ) -> WorktreeInfo:
        """
        Create isolated worktree for agent work.

        Args:
            branch_name: Name for the new branch
            base_branch: Branch to base work on
            agent_id: Optional agent identifier for tracking

        Returns:
            WorktreeInfo with path and branch details
        """
        worktree_path = f".agent-worktrees/{agent_id or branch_name}"

        # Create worktree
        await run_command(f"git worktree add -b {branch_name} {worktree_path} {base_branch}")

        return WorktreeInfo(
            path=worktree_path,
            branch=branch_name,
            base=base_branch,
            agent_id=agent_id
        )

    async def cleanup_worktree(self, worktree_path: str) -> None:
        """Remove worktree after agent completes."""
        await run_command(f"git worktree remove {worktree_path}")

    async def list_worktrees(self) -> List[WorktreeInfo]:
        """List all active agent worktrees."""
        result = await run_command("git worktree list --porcelain")
        return parse_worktree_list(result)
```

### Integration with Agent Lifecycle

```python
# In agent spawning logic
async def spawn_worker_agent(self, role: str, task: str):
    # Create isolated worktree for this agent
    worktree = await self.git_worktree.create_worktree(
        branch_name=f"agent/{role}/{task_id}",
        agent_id=f"{role}-{uuid4()}"
    )

    # Spawn agent with worktree as working directory
    agent = await self.create_agent(
        role=role,
        working_dir=worktree.path,
        environment={
            "AGENT_BRANCH": worktree.branch,
            "AGENT_WORKTREE": worktree.path
        }
    )

    return agent
```

### MCP Tool Definition

```json
{
  "name": "git_worktree_create",
  "description": "Create an isolated git worktree for agent work",
  "inputSchema": {
    "type": "object",
    "properties": {
      "branch_name": {
        "type": "string",
        "description": "Name for the new branch"
      },
      "base_branch": {
        "type": "string",
        "default": "main"
      },
      "agent_id": {
        "type": "string",
        "description": "Agent identifier for tracking"
      }
    },
    "required": ["branch_name"]
  }
}
```

### Files to Create/Modify

- [ ] `agent_mcp/tools/git_worktree.py` - New tool implementation
- [ ] `agent_mcp/tools/__init__.py` - Register new tool
- [ ] `agent_mcp/agents/base.py` - Add worktree lifecycle hooks
- [ ] `tests/test_git_worktree.py` - Test coverage
- [ ] `docs/tools/git-worktree.md` - Documentation

### Complexity: Medium | Impact: High

---

## Contribution 2: Simplified Containerization

### Problem

Current Docker setup requires manual configuration and doesn't integrate well with the agent lifecycle.

### Solution

Create a container management layer that handles:
- Auto-building agent containers
- Volume mounting for worktrees
- Network isolation
- Lifecycle management

### Design

```python
# agent_mcp/sandbox/container.py

class AgentContainer:
    """Managed container for isolated agent execution."""

    def __init__(
        self,
        agent_id: str,
        image: str = "agent-mcp-base:latest",
        worktree_path: str = None,
        network_mode: str = "bridge"
    ):
        self.agent_id = agent_id
        self.image = image
        self.worktree_path = worktree_path
        self.network_mode = network_mode
        self.container = None

    async def start(self) -> ContainerInfo:
        """Start container with appropriate mounts."""
        volumes = {}

        if self.worktree_path:
            volumes[self.worktree_path] = {
                "bind": "/workspace",
                "mode": "rw"
            }

        self.container = await docker_client.containers.run(
            self.image,
            detach=True,
            name=f"agent-{self.agent_id}",
            volumes=volumes,
            network_mode=self.network_mode,
            environment={
                "AGENT_ID": self.agent_id,
                "WORKSPACE": "/workspace"
            }
        )

        return ContainerInfo(
            container_id=self.container.id,
            agent_id=self.agent_id,
            status="running"
        )

    async def exec(self, command: str) -> ExecResult:
        """Execute command in container."""
        return await self.container.exec_run(command)

    async def stop(self) -> None:
        """Stop and cleanup container."""
        if self.container:
            await self.container.stop()
            await self.container.remove()
```

### Dockerfile Template

```dockerfile
# agent_mcp/sandbox/Dockerfile.agent-base
FROM python:3.11-slim

# Install common tools
RUN apt-get update && apt-get install -y \
    git \
    curl \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Install Claude Code CLI
RUN npm install -g @anthropic-ai/claude-code

# Install agent dependencies
COPY requirements.txt /tmp/
RUN pip install -r /tmp/requirements.txt

# Setup workspace
WORKDIR /workspace

# Default command
CMD ["bash"]
```

### Configuration

```yaml
# .agent-mcp/containers.yaml
containers:
  default:
    image: agent-mcp-base:latest
    network: bridge

  isolated:
    image: agent-mcp-base:latest
    network: none  # No network access

  with_mcp:
    image: agent-mcp-base:latest
    network: bridge
    mcp_servers:
      - graphiti
      - filesystem
```

### Files to Create/Modify

- [ ] `agent_mcp/sandbox/container.py` - Container management
- [ ] `agent_mcp/sandbox/Dockerfile.agent-base` - Base image
- [ ] `agent_mcp/sandbox/docker_client.py` - Docker API wrapper
- [ ] `agent_mcp/config/containers.py` - Configuration handling
- [ ] `tests/test_containers.py` - Test coverage
- [ ] `docs/sandbox/containers.md` - Documentation

### Complexity: Medium | Impact: High

---

## Contribution 3: Graphiti Memory Adapter

### Problem

Agent-MCP's memory system doesn't integrate with Graphiti for temporal knowledge graphs.

### Solution

Create a memory adapter that routes appropriate memory operations to Graphiti.

### Design

```python
# agent_mcp/memory/adapters/graphiti.py

from graphiti_core import Graphiti
from graphiti_core.nodes import EpisodeType

class GraphitiMemoryAdapter:
    """Memory adapter for Graphiti knowledge graph backend."""

    def __init__(
        self,
        falkordb_url: str,
        neo4j_url: str = None,
        embedding_model: str = "text-embedding-3-small"
    ):
        self.client = Graphiti(
            neo4j_url or falkordb_url,
            embedding_model=embedding_model
        )

    async def store_knowledge(
        self,
        content: str,
        source: str,
        episode_type: EpisodeType = EpisodeType.message,
        metadata: dict = None
    ) -> str:
        """Store knowledge in Graphiti."""
        episode = await self.client.add_episode(
            name=f"knowledge-{uuid4()}",
            episode_body=content,
            source=source,
            episode_type=episode_type,
            reference_time=datetime.now()
        )
        return episode.uuid

    async def search(
        self,
        query: str,
        num_results: int = 10,
        include_temporal: bool = True
    ) -> List[SearchResult]:
        """Search knowledge graph with optional temporal context."""
        results = await self.client.search(
            query=query,
            num_results=num_results
        )
        return [
            SearchResult(
                content=r.fact,
                relevance=r.score,
                valid_from=r.valid_at if include_temporal else None,
                valid_until=r.invalid_at if include_temporal else None
            )
            for r in results
        ]

    async def get_entity_history(
        self,
        entity_name: str
    ) -> List[EntityState]:
        """Get temporal history of an entity."""
        # Leverage Graphiti's temporal reasoning
        return await self.client.get_entity_timeline(entity_name)
```

### Memory Router Integration

```python
# agent_mcp/memory/router.py

class MemoryRouter:
    """Routes memory operations to appropriate backend."""

    def __init__(self):
        self.adapters = {
            "graphiti": GraphitiMemoryAdapter(...),
            "agentdb": AgentDBAdapter(...),
            "context": ContextWindowAdapter(...)
        }

        # Routing rules
        self.routes = {
            "long_term": "graphiti",
            "sprint": "graphiti",  # Different subgraph
            "team": "agentdb",
            "short_term": "context"
        }

    async def store(
        self,
        content: str,
        channel: str,
        **kwargs
    ) -> str:
        adapter = self.adapters[self.routes[channel]]
        return await adapter.store(content, **kwargs)

    async def search(
        self,
        query: str,
        channels: List[str] = None,
        **kwargs
    ) -> List[SearchResult]:
        channels = channels or list(self.routes.keys())
        results = []

        for channel in channels:
            adapter = self.adapters[self.routes[channel]]
            channel_results = await adapter.search(query, **kwargs)
            results.extend(channel_results)

        return sorted(results, key=lambda r: r.relevance, reverse=True)
```

### Files to Create/Modify

- [ ] `agent_mcp/memory/adapters/graphiti.py` - Graphiti adapter
- [ ] `agent_mcp/memory/adapters/__init__.py` - Adapter registry
- [ ] `agent_mcp/memory/router.py` - Memory routing logic
- [ ] `tests/test_graphiti_adapter.py` - Test coverage
- [ ] `docs/memory/graphiti.md` - Documentation

### Complexity: Low-Medium | Impact: Medium

---

## Contribution 4: Skills Bridge

### Problem

Claude Code Skills don't work in Agent-MCP agents. Skills are locked to Claude Code native context.

### Solution

Create a portable skill definition format and loader that works across systems.

### Design

```yaml
# Portable skill format
# skills/code-review.skill.yaml
name: code-review
version: "1.0"
description: |
  Automated code review skill that checks for security,
  performance, and maintainability issues.

triggers:
  - "review this code"
  - "check for bugs"
  - "security audit"
  - "code review"

instructions: |
  When reviewing code, follow this process:

  ## Security Review
  1. Check for injection vulnerabilities (SQL, command, XSS)
  2. Verify authentication and authorization
  3. Look for sensitive data exposure
  4. Check dependency vulnerabilities

  ## Performance Review
  1. Identify N+1 queries
  2. Check for unnecessary computations
  3. Verify caching strategies
  4. Look for memory leaks

  ## Maintainability Review
  1. Check code complexity
  2. Verify test coverage
  3. Review documentation
  4. Assess naming conventions

tools_required:
  - file_read
  - grep
  - ast_analyze

output_format:
  type: structured
  schema:
    security_issues: array
    performance_issues: array
    maintainability_issues: array
    summary: string
    risk_level: enum[low, medium, high, critical]
```

### Skill Loader

```python
# agent_mcp/skills/loader.py

class PortableSkillLoader:
    """Load portable skills into agent context."""

    def __init__(self, skills_dir: str = "skills/"):
        self.skills_dir = Path(skills_dir)
        self.skills = {}

    def load_all(self) -> Dict[str, Skill]:
        """Load all skills from directory."""
        for skill_file in self.skills_dir.glob("*.skill.yaml"):
            skill = self.load_skill(skill_file)
            self.skills[skill.name] = skill
        return self.skills

    def load_skill(self, path: Path) -> Skill:
        """Load single skill from file."""
        with open(path) as f:
            data = yaml.safe_load(f)

        return Skill(
            name=data["name"],
            triggers=data["triggers"],
            instructions=data["instructions"],
            tools_required=data.get("tools_required", []),
            output_format=data.get("output_format")
        )

    def match_skill(self, user_input: str) -> Optional[Skill]:
        """Find matching skill based on triggers."""
        user_lower = user_input.lower()

        for skill in self.skills.values():
            for trigger in skill.triggers:
                if trigger.lower() in user_lower:
                    return skill

        return None

    def inject_skill_context(
        self,
        skill: Skill,
        agent_context: dict
    ) -> dict:
        """Inject skill instructions into agent context."""
        agent_context["system_prompt"] += f"\n\n## Active Skill: {skill.name}\n{skill.instructions}"
        return agent_context
```

### Claude Code Skill Converter

```python
# agent_mcp/skills/converter.py

class ClaudeSkillConverter:
    """Convert between Claude Code SKILL.md and portable format."""

    @staticmethod
    def from_skill_md(skill_md_path: str) -> dict:
        """Convert SKILL.md to portable format."""
        with open(skill_md_path) as f:
            content = f.read()

        # Parse frontmatter
        frontmatter, body = parse_frontmatter(content)

        return {
            "name": frontmatter.get("name", Path(skill_md_path).parent.name),
            "description": frontmatter.get("description", ""),
            "triggers": extract_triggers(frontmatter.get("description", "")),
            "instructions": body,
            "tools_required": frontmatter.get("tools", [])
        }

    @staticmethod
    def to_skill_md(portable_skill: dict) -> str:
        """Convert portable format to SKILL.md."""
        return f"""---
name: {portable_skill['name']}
description: |
  {portable_skill['description']}
---

{portable_skill['instructions']}
"""
```

### Files to Create/Modify

- [ ] `agent_mcp/skills/loader.py` - Skill loading
- [ ] `agent_mcp/skills/converter.py` - Format conversion
- [ ] `agent_mcp/skills/matcher.py` - Trigger matching
- [ ] `skills/` - Portable skill definitions
- [ ] `tests/test_skills.py` - Test coverage
- [ ] `docs/skills/portable-skills.md` - Documentation

### Complexity: High | Impact: Very High

---

## Implementation Order

| Order | Contribution | Reason |
|-------|-------------|--------|
| 1 | Git Worktrees | Foundational for parallel work |
| 2 | Graphiti Adapter | Memory integration needed early |
| 3 | Containerization | Builds on worktrees |
| 4 | Skills Bridge | Most complex, benefits from learnings |

---

## Success Metrics

- [ ] All PRs merged to Agent-MCP main
- [ ] Documentation approved by maintainers
- [ ] Test coverage >80% for new code
- [ ] Features used in personal workflows for 2+ weeks
- [ ] At least one other user reports using the features

---

## References

- [Agent-MCP Repository](https://github.com/rinadelph/Agent-MCP)
- [Agent-MCP Discord](https://discord.gg/7Jm7nrhjGn)
- [Git Worktrees Documentation](https://git-scm.com/docs/git-worktree)
- [Graphiti Documentation](https://docs.falkordb.com/agentic-memory/graphiti.html)
- [Claude Code Skills](https://docs.claude.com/en/docs/claude-code/plugins)

---

> [!info] Metadata
> **Phase**: `= this.plan.phase`
> **Priority**: `= this.plan.priority`
> **Effort**: `= this.plan.effort`
