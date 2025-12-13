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
      default: research
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
  - name: research.hypothesis
    type: Input
    options:
      placeholder: "What are you trying to prove/disprove?"
  - name: research.methodology
    type: Select
    options:
      - "0": experimental
      - "1": observational
      - "2": comparative
      - "3": literature-review
      - "4": survey
      - "5": case-study
      - "6": prototype
  - name: research.conclusion
    type: Select
    options:
      - "0": pending
      - "1": confirmed
      - "2": rejected
      - "3": inconclusive
      - "4": needs-more-data
  - name: research.confidence
    type: Select
    options:
      - "0": high
      - "1": medium
      - "2": low
      - "3": unknown
  - name: research.sources
    type: MultiFile
    options:
      dvQueryString: ""
  - name: research.related_experiments
    type: MultiFile
    options:
      dvQueryString: "type = \"experiment\" OR fileClass = \"research\""
  - name: research.next_steps
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
