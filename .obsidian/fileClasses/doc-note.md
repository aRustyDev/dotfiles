---
filesPaths:
  - docs/notes
  - docs/dashboards
excludedFields:
  - id
  - created
  - updated
fields:
  - name: status
    type: Select
    options:
      - "0": "📝 draft"
      - "1": "🚧 wip"
      - "2": "🔍 review"
      - "3": "✅ active"
      - "4": "⏸️ paused"
      - "5": "⚠️ deprecated"
      - "6": "📦 archived"
  - name: type
    type: Select
    options:
      - "0": reference
      - "1": tutorial
      - "2": guide
      - "3": dashboard
      - "4": research
      - "5": hypothesis
      - "6": plan
      - "7": roadmap
      - "8": changelog
      - "9": experiment
      - "10": bug-report
      - "11": issue
      - "12": PRD
      - "13": FRD
      - "14": BRD
      - "15": note
      - "16": cornell-note
      - "17": meeting-note
      - "18": slide
      - "19": adr
      - "20": runbook
      - "21": cheatsheet
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
      - "13": meta
      - "14": data
      - "15": kubernetes
      - "16": security
      - "17": shell
      - "18": python
      - "19": rust
      - "20": go
      - "21": typescript
  - name: project
    type: Input
    options:
      default: dotfiles
  - name: publish
    type: Boolean
  - name: tags
    type: MultiFile
    options:
      dvQueryString: ""
  - name: aliases
    type: Multi
    options: []
---
