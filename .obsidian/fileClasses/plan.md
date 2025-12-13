---
filesPaths:
  - .ai/plans
excludedFields:
  - id
  - created
  - updated
fields:
  - name: fileClass
    type: Input
    options:
      default: plan
  - name: status
    type: Select
    options:
      - "0": "📝 draft"
      - "1": "🚧 in-progress"
      - "2": "👀 awaiting-review"
      - "3": "🔍 in-review"
      - "4": "❓ needs-info"
      - "5": "✅ approved"
      - "6": "☑️ completed"
      - "7": "⏸️ backlog"
      - "8": "⚠️ deprecated"
      - "9": "📦 archived"
  - name: plan.phase
    type: Select
    options:
      - "0": discovery
      - "1": design
      - "2": implementation
      - "3": testing
      - "4": deployment
      - "5": review
  - name: plan.priority
    type: Select
    options:
      - "0": critical
      - "1": high
      - "2": medium
      - "3": low
  - name: plan.effort
    type: Select
    options:
      - "0": XS
      - "1": S
      - "2": M
      - "3": L
      - "4": XL
  - name: plan.dependencies
    type: MultiFile
    options:
      dvQueryString: "fileClass = \"plan\" OR type = \"plan\""
  - name: plan.blocked_by
    type: MultiFile
    options:
      dvQueryString: ""
  - name: plan.owner
    type: Input
    options: {}
  - name: plan.stakeholders
    type: Multi
    options: []
  - name: scope
    type: Multi
    options:
      - "0": docker
      - "1": git
      - "2": just
      - "3": k9s
      - "4": zsh
      - "5": tmux
      - "6": nvim
      - "7": nix
      - "8": terraform
      - "9": mcp
      - "10": ai
      - "11": obsidian
      - "12": general
      - "13": kubernetes
      - "14": security
  - name: project
    type: Input
    options:
      default: dotfiles
  - name: publish
    type: Boolean
  - name: tags
    type: Multi
    options: []
---
