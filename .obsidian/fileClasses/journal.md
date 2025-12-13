---
filesPaths:
  - docs/notes/journal
excludedFields:
  - id
  - created
  - updated
fields:
  - name: fileClass
    type: Input
    options:
      default: journal
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
  - name: journal.date
    type: Date
    options:
      dateFormat: YYYY-MM-DD
  - name: journal.day_of_week
    type: Select
    options:
      - "0": Monday
      - "1": Tuesday
      - "2": Wednesday
      - "3": Thursday
      - "4": Friday
      - "5": Saturday
      - "6": Sunday
  - name: journal.mood
    type: Select
    options:
      - "0": "🔥 productive"
      - "1": "😊 good"
      - "2": "😐 neutral"
      - "3": "😓 struggling"
      - "4": "🤒 sick"
  - name: journal.energy
    type: Select
    options:
      - "0": high
      - "1": medium
      - "2": low
  - name: journal.focus_areas
    type: Multi
    options:
      - "0": coding
      - "1": learning
      - "2": planning
      - "3": meetings
      - "4": reviews
      - "5": documentation
      - "6": debugging
      - "7": devops
      - "8": personal
  - name: journal.wins
    type: Multi
    options: []
  - name: journal.blockers
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
