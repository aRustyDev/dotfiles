---
filesPaths:
  - .ai/docs/adr
excludedFields:
  - id
  - created
  - updated
fields:
  - name: fileClass
    type: Input
    options:
      default: adr
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
  - name: adr.number
    type: Input
    options:
      placeholder: "e.g., 001"
  - name: adr.status
    type: Select
    options:
      - "0": Proposed
      - "1": Accepted
      - "2": Deprecated
      - "3": Superseded
  - name: adr.supersedes
    type: File
    options:
      dvQueryString: "fileClass = \"adr\""
  - name: adr.superseded_by
    type: File
    options:
      dvQueryString: "fileClass = \"adr\""
  - name: adr.deciders
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
