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
- [ ] Draft Pydantic models for structured entity extraction
- [ ] Create agent rules for leveraging these entity types effectively

## Custom Entity Types Planning

📚 Key Insights from Graphiti Documentation

Based on the Graphiti docs, here's what I learned about entity types:

1. **Descriptions are critical** - They're fed directly to the LLM during extraction to guide what type to assign
2. **Simple YAML format** - Just `name` + `description` pairs (your `attributes` field is custom and may not be natively supported)
3. **Pydantic models for structured attributes** - If you want actual typed attributes on entities, you need Python-side Pydantic models, not YAML
4. **Descriptions guide LLM classification** - The more precise the description, the better the LLM can distinguish between

### Current External Assessment

| Strength                           | Examples                                                                       |
| ---------------------------------- | ------------------------------------------------------------------------------ |
| **Clear disambiguation rules**     | "Company" vs "Organization" - excellent "for-profit vs non-profit" distinction |
| **Priority hints in descriptions** | "PRIORITIZE over most other types except User/Assistant" in Preference         |
| **Negative guidance**              | "NOT for tasks or one-off work" in Project                                     |
| **Concrete examples**              | Technology includes "FalkorDB", "Docker", "Python 3.12"                        |
| **Deprecation strategy**           | Process marked as DEPRECATED with migration path                               |
| **Strong reasoning types**         | Decision, Insight, Assumption - great for agent reasoning                      |

Overlapping Types Without Clear Rules

| Type A       | Type B        | Ambiguity                                                              |
| ------------ | ------------- | ---------------------------------------------------------------------- |
| `Constraint` | `Requirement` | Both describe "musts" - when is something a constraint vs requirement? |
| `Goal`       | `Requirement` | Your description says Goal is "broader" but needs clearer boundary     |
| `Convention` | `Procedure`   | "Naming schemes" could be either                                       |
| `Dependency` | `Constraint`  | "Feature X blocked by Y" - is that a dependency or constraint?         |

```yaml
# Graphiti Configuration File
---
graphiti:
  group_id: ${GRAPHITI_GROUP_ID:-main}
  semaphore_limit: 10
  episode_id_prefix: ${EPISODE_ID_PREFIX:}
  user_id: ${USER_ID:mcp_user}
  # Entity_types: should enable the agent to "reason"
  # Data_stores: handles _operations_ on data (CRUD)
  entity_types:
    - name: "Preference" # Default
      description: "User preferences, choices, opinions, or selections (PRIORITIZE over most other types except User/Assistant)"
    - name: "Requirement" # Default
      description: "Specific needs, features, or functionality that must be fulfilled"
    - name: "Location" # Default
      description: "Physical or virtual places where activities occur"
    - name: "Event" # Default
      description: "Time-bound activities, occurrences, or experiences"

    - name: "Organization" # Default
      description: "Companies, institutions, groups, or formal entities"
    # Company vs Organization
    - name: "Company"
      description: "A for-profit business entity (employer, vendor, client). For non-profits, government, or informal groups, use Organization."

    - name: "Document" # Default
      description: "Information content in various forms (books, articles, reports, etc.)"
    - name: "Topic" # Default
      description: "Subject of conversation, interest, or knowledge domain (use as last resort)"
    - name: "Object" # Default
      description: "Physical items, tools, devices, or possessions (use as last resort)"
    - name: "Error"
      description: "Errors, bugs, issues, or problems encountered. Must include the context and error message if available."
    - name: "Project"
      description: "A defined initiative with scope, timeline, and deliverables. Use for named efforts like 'MCP Server v2' or 'Infrastructure Migration'. NOT for tasks or one-off work."
    - name: "Experiment"
      description: "A time-boxed exploration to test a hypothesis. Must have clear success/failure criteria. Use for 'testing if X works' scenarios."
    - name: "Technology"
      description: "A specific tool, framework, language, or platform (e.g., 'FalkorDB', 'Docker', 'Python 3.12'). For general knowledge domains, use Topic instead."
    - name: "Skill"
      description: "A capability or competency that can be learned/improved. Use for abilities like 'Kubernetes administration' or 'GraphQL API design'. For tools themselves, use Technology."
    - name: "Constraint"
      description: "A limitation, restriction, or boundary that affects decisions. Use for 'must use Python 3.10+' or 'no external API calls allowed'."
    - name: "Convention"
      description: "An agreed-upon pattern, naming scheme, or standard. Use for 'files named *.spec.ts' or 'commits use conventional format'."

    # Process vs Procedure vs Workflow
    - name: "Process"
      description: "DEPRECATED - Use Procedure for instructions or Workflow for automated/event-driven flows."
    - name: "Procedure" # Default
      description: "Standard operating procedures and sequential Step-by-step instructions for a human to follow. Manual, sequential, discrete."
    - name: "Workflow"
      description: "A repeatable multi-step process triggered by events. Use for 'CI/CD pipeline' or 'code review process'. For one-off procedures, use Procedure. Has conditional branches, runs in systems."

    - name: "Fact"
      description: "A verified, objective piece of information that is true independent of context. Use for 'Python 3.12 was released in October 2023' or 'The API rate limit is 100 req/min'. NOT for opinions (use Preference) or unverified beliefs (use Assumption)."

    # - name: "Feature"
    #   description: ""
    # - name: "SPEC"
    #   description: ""
    # - name: "Resource"
    #   description: ""
    # - name: "Contact"
    #   description: ""
    # - name: "Agent"
    #   description: ""
    # - name: "Role"
    #   description: ""
    - name: "Plan"
      description: "A structured approach to achieve a goal. Should include objective, phases, and success criteria. Types: research, debugging, analysis, experiment, project, refactor, reverse-engineering, library. Status can be draft, active, paused, completed, or abandoned. For individual actions, use Procedure instead."
      # description: "A structured approach to achieve a goal. MUST include: objective, phases, success criteria."
      # attributes:
      #   - plan_type: "research|debugging|analysis|experiment|project|refactor|reverse-engineering|library"
      #   - status: "draft|active|paused|completed|abandoned"
      #   - phases: "[list of phase IDs]"
      # The `attributes` field is **not** native Graphiti YAML config. Per the docs, if you want typed attributes you need:
      # <!--- **Python Pydantic models** passed to `add_episode()` as `entity_types` dict
      # - The YAML only supports `name` + `description`

      # Your attributes will likely be ignored by the MCP server.-->

    # - name: "Thesis"
    #   description: ""

    - name: "Decision" # Suggested Gaps
      description: "A choice made between alternatives with rationale. Use for architectural choices, technology selections, or design trade-offs. MUST include reasoning."
    - name: "Insight" # Suggested Gaps
      description: "A learned understanding or discovery from experience. Use for 'I learned that X behaves like Y' or 'The root cause was Z'."
    - name: "Goal" # Suggested Gaps
      description: "A desired outcome or objective. Broader than Requirement, represents intent. Use for 'I want to improve performance' before specific requirements exist."
    - name: "Assumption" # Suggested Gaps
      description: "A belief taken as true without verification. Use for 'I'm assuming the API is stable' to track what might need validation."
    - name: "Dependency" # Suggested Gaps
      description: "A relationship where one thing requires another. Use for 'Service A needs Redis running' or 'Feature X blocked by Y'."
    - name: "Pattern" # Suggested Gaps
      description: "A recurring solution or approach that works across multiple situations. Use for 'retry with exponential backoff' or 'circuit breaker pattern'. For one-time solutions, use Insight."
    - name: "Problem" # Suggested Gaps
      description: "An identified issue, bug, or challenge that needs resolution. Use for 'memory leak in service X' or 'flaky tests in CI'. For errors with specific messages, use Error."
    - name: "Rationale" # Suggested Gaps
      description: "The reasoning behind a decision or approach. Use when capturing WHY something was done. Often paired with Decision entities. Use for 'chose Postgres over MongoDB because of ACID requirements'."
```

```mermaid

```
