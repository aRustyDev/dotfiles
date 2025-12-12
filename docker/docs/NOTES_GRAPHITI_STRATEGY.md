# Notes on Graphiti Strategy

**TODO Items**

- [ ] Define subtypes and attributes for each custom entity type.
- [ ] Create substantive 'description' fields for all entity types.
- [ ] Identify new entity types needed for specific use cases.
- [ ] Create `Rules` for Agents to use to leverage these entity types effectively.
- [ ] Strategize on how to use "group_id" and "episode_id_prefix" for better organization.
- [ ] Strategize on how useful a 'Thesis' type would be.
- [ ] Find the "SPEC" alternative that I can't remember, it was in a YouTube video by "AI Engineer"?.
- [ ] Strategize on Where things like "project:\*" should live. (Graphiti vs MongoDB vs etc.)
  - Plans, tasks, data, sprints, milestones, issues, requirements

## Custom Entity Types Planning

```yaml
# Graphiti Configuration File
---
graphiti:
  group_id: ${GRAPHITI_GROUP_ID:-main}
  semaphore_limit: 10
  episode_id_prefix: ${EPISODE_ID_PREFIX:}
  user_id: ${USER_ID:mcp_user}
  entity_types:
    - name: "Preference" # Default
      description: "User preferences, choices, opinions, or selections (PRIORITIZE over most other types except User/Assistant)"
    - name: "Requirement" # Default
      description: "Specific needs, features, or functionality that must be fulfilled"
    - name: "Procedure" # Default
      description: "Standard operating procedures and sequential instructions"
    - name: "Location" # Default
      description: "Physical or virtual places where activities occur"
    - name: "Event" # Default
      description: "Time-bound activities, occurrences, or experiences"
    - name: "Organization" # Default
      description: "Companies, institutions, groups, or formal entities"
    - name: "Document" # Default
      description: "Information content in various forms (books, articles, reports, etc.)"
    - name: "Topic" # Default
      description: "Subject of conversation, interest, or knowledge domain (use as last resort)"
    - name: "Object" # Default
      description: "Physical items, tools, devices, or possessions (use as last resort)"
    - name: "Error"
      description: "Errors, bugs, issues, or problems encountered. Must include the context and error message if available."
    - name: "Project"
      description: ""
    - name: "Experiment"
      description: ""
    - name: "Company"
      description: ""
    - name: "Skill"
      description: ""
    - name: "Fact"
      description: ""
    - name: "Process"
      description: ""
    - name: "Feature"
      description: ""
    - name: "Technology"
      description: ""
    - name: "Procedure"
      description: ""
    - name: "SPEC"
      description: ""
    - name: "Constraint"
      description: ""
    - name: "Resource"
      description: ""
    - name: "Contact"
      description: ""
    - name: "Agent"
      description: ""
    - name: "Role"
      description: ""
    - name: "Plan"
      description: ""
    - name: "Plan:Research"
      description: ""
    - name: "Plan:Debugging"
      description: ""
    - name: "Plan:Analysis"
      description: ""
    - name: "Plan:Experiment"
      description: ""
    - name: "Plan:Project"
      description: ""
    - name: "Plan:Refactor"
      description: ""
    - name: "Plan:ReverseEngineering"
      description: ""
    - name: "Plan:Library"
      description: ""
    - name: "Convention"
      description: ""
    - name: "Workflow"
      description: ""
    - name: "Thesis"
      description: ""
```

```mermaid

```
