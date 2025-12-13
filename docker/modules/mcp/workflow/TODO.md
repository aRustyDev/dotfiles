---
id: 1bfbd44f-b9a6-4c84-9027-9d0b75de36c5
title: Better Tasks MCP
created: 2025-12-13T00:00:00
updated: 2025-12-13T16:38
project: dotfiles
scope: docker
type: plan
status: 🚧 in-progress
publish: false
tags:
  - docker
  - mcp
  - todo
aliases:
  - Better Tasks MCP
  - Todo
related: []
---

# Better Tasks MCP

## Task Management

- `create_task_file`: Create new project task files
- `add_task`: Add tasks to projects with descriptions and subtasks
- `update_task_status`: Update the status of tasks and subtasks
- `get_next_task`: Get the next uncompleted task from a project

## Project Planning

- `parse_prd`: Convert PRDs into structured tasks automatically
- `expand_task`: Break down tasks into smaller, manageable subtasks
- `estimate_task_complexity`: Estimate task complexity and time requirements
- `get_task_dependencies`: Track task dependencies

## Development Support

- `generate_task_file`: Generate file templates based on task descriptions
- `suggest_next_actions`: Get AI-powered suggestions for next steps

| Tool Name                 | Description                                                                 | Key Features                                                              |
| ------------------------- | --------------------------------------------------------------------------- | ------------------------------------------------------------------------- |
| workflow_return_list      | Discovers and lists available workflows.                                    | - category: Filter by a specific category.                                |
|                           |                                                                             | - tags: Filter by a list of tags.                                         |
|                           |                                                                             | - includeTools: Optionally include a list of tools used in each workflow. |
| workflow_get_instructions | Retrieves the complete definition for a single workflow                     | . - name: The exact name of the workflow.                                 |
|                           |                                                                             | - version: The specific version to retrieve (defaults to latest).         |
|                           |                                                                             | - Dynamically injects global instructions for consistent execution.       |
| workflow_create_new       | Creates a new, permanent workflow YAML file.                                | - Takes a structured JSON object matching the workflow schema.            |
|                           |                                                                             | - Automatically categorizes and re-indexes workflows.                     |
| workflow_create_temporary | Creates a temporary workflow that is not listed, but can be called by name. | - Ideal for defining multi-step plans for complex tasks.                  |
|                           |                                                                             | - Can be passed to other agents by name.                                  |

---

- How to turn tasks into ROADMAP
- How to integrate Templates (with schemas)
- How to
<!-- https://github.com/Pimzino/spec-workflow-mcp -->
