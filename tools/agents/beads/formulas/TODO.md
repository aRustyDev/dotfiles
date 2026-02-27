What: YAML/JSON files defining reusable workflow templates with composition rules.

Lifecycle:
Formula (source) → Cook (compile) → Proto (template) → Pour/Wisp (instantiate)

Search Paths:
1. .beads/formulas/ (project)
2. ~/.beads/formulas/ (user)
3. $GT_ROOT/.beads/formulas/ (Gas-Town orchestrator)

When to Use:
- Repeatable workflows (PR review, bug triage, feature development)
- Multi-step agent tasks with dependencies
- Cross-agent coordination patterns

Example Formula:
```yaml
name: pr-review
steps:
  - id: checkout
    title: "Checkout PR branch"
    type: task
  - id: test
    title: "Run tests"
    type: task
    blocked_by: [checkout]
  - id: review
    title: "Code review"
    type: task
    blocked_by: [test]
```
