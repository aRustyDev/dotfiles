Chain-of-Thought MCP Servers

1. Sequential Thinking (Official Anthropic)

Already deployed in your infrastructure (mcp/sequentialthinking)

- Docker image: mcp/sequentialthinking
- Single tool: sequentialthinking
- Flexible thought chains with revision/branching support
- General-purpose reasoning

2. Code Reasoning

Repository: https://github.com/mettamatt/code-reasoning (244★)

- Fork of official sequential-thinking optimized for programming tasks
- Adds prompt templates for coding contexts
- Same architecture, different system prompts
- Install: npx -y @anthropic-ai/code-reasoning-mcp-server

3. MAS Sequential Thinking

Repository: https://github.com/FradSer/mcp-server-mas-sequential-thinking (272★)

- Multi-Agent System with 6 specialized agents:
  - Factual (information retrieval)
  - Emotional (sentiment/impact)
  - Critical (analysis/flaws)
  - Optimistic (opportunities)
  - Creative (novel solutions)
  - Synthesis (combines perspectives)
- Python/Agno framework
- Optional Exa web search integration
- Higher token usage (parallel agent processing)
- Install: uvx mcp-server-mas-sequential-thinking

4. Sequential Thinking Tools

Repository: https://github.com/spences10/mcp-sequentialthinking-tools (526★)

- Guides tool usage at each reasoning step
- Helps LLM decide which MCP tools to call during chain-of-thought
- Useful when you have many MCP tools and want structured tool selection
- Install: npx -y mcp-sequentialthinking-tools

Comparison

| Server                    | Focus                      | Token Usage | Complexity |
| ------------------------- | -------------------------- | ----------- | ---------- |
| Sequential Thinking       | General reasoning          | Low         | Simple     |
| Code Reasoning            | Programming tasks          | Low         | Simple     |
| MAS Sequential Thinking   | Multi-perspective analysis | High        | Complex    |
| Sequential Thinking Tools | Tool orchestration         | Medium      | Medium     |
