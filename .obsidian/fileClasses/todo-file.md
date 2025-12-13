---
filesPaths: []
excludedFields:
  - id
  - created
  - updated
fields:
  - name: fileClass
    type: Input
    options:
      default: todo-file
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
  - name: todo.priority
    type: Select
    options:
      - "0": critical
      - "1": high
      - "2": medium
      - "3": low
  - name: todo.category
    type: Select
    options:
      - "0": feature
      - "1": bugfix
      - "2": refactor
      - "3": documentation
      - "4": testing
      - "5": infrastructure
      - "6": security
      - "7": performance
      - "8": chore
  - name: todo.assignee
    type: Input
    options: {}
  - name: todo.due
    type: Date
    options:
      dateFormat: YYYY-MM-DD
  - name: todo.blocked_by
    type: MultiFile
    options:
      dvQueryString: ""
  - name: todo.progress
    type: Number
    options:
      min: 0
      max: 100
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
