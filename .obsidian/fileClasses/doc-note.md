---
filesPaths:
  - docs/notes
fields:
  - name: status
    type: Select
    options:
      - "0": "📝 draft"
      - "1": "🚧 wip"
      - "2": "🔍 review"
      - "3": "✅ active"
      - "4": "⚠️ deprecated"
      - "5": "📦 archived"
  - name: type
    type: Select
    options:
      - "0": guide
      - "1": reference
      - "2": tutorial
      - "3": adr
      - "4": runbook
      - "5": cheatsheet
      - "6": note
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
---
