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
      default: prd
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
  - name: prd.version
    type: Input
    options:
      default: "0.1"
  - name: prd.status
    type: Select
    options:
      - "0": draft
      - "1": review
      - "2": approved
      - "3": in-development
      - "4": shipped
  - name: prd.owner
    type: Input
    options: {}
  - name: prd.stakeholders
    type: Multi
    options: []
  - name: prd.target_release
    type: Input
    options:
      placeholder: "e.g., Q1 2025, v2.0"
  - name: prd.related_frd
    type: MultiFile
    options:
      dvQueryString: "type = \"FRD\" OR fileClass = \"frd\""
  - name: prd.related_brd
    type: MultiFile
    options:
      dvQueryString: "type = \"BRD\" OR fileClass = \"brd\""
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
