# Memory Types

| group_id | name | purpose |
| -------- | ---- | ------- |
|          |      |         |

## Hooks

- Query memory at session start
- store memory at session end
- store memory at major points
- store memory after analysis
- store memory after ADR
- store memory after error resolution

## Schemas

```json
{
  "name": "session-end-2024-12-09",
  "episode_body": "Completed: HTTP transport implementation phase 1. In progress: Testing SSE endpoints. Blocked: Need to configure CORS. Next: Implement client reconnection logic. Key
  insight: FastMCP's lifespan context doesn't work with starlette mount.",
  "source": "text",
  "group_id": "zettelkasten-sessions"
}
```

## Entity Types

```yaml
entity_types:
  # === Agent Performance ===
  - name: "ErrorPattern"
    description: "Known errors, exceptions, and failure modes with their root causes"

  - name: "Solution"
    description: "Verified fixes, workarounds, and resolutions to problems"

  - name: "AntiPattern"
    description: "Approaches that failed and should be avoided"

  # === Project Context ===
  - name: "Project"
    description: "Software projects, repositories, or codebases being worked on"

  - name: "Architecture"
    description: "System design patterns, component structures, data flows"

  - name: "Convention"
    description: "Naming conventions, coding standards, team practices"

  # === Knowledge Management ===
  - name: "Insight"
    description: "Learned information, discoveries, or conclusions from analysis"

  - name: "Decision"
    description: "Technical decisions made and their rationale"

  - name: "Task"
    description: "Work items, todos, or incomplete work requiring continuation"
```

## Strategy

- Task tracking vs memories
- knowledge vs memory
