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
      default: runbook
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
  - name: runbook.severity
    type: Select
    options:
      - "0": SEV1
      - "1": SEV2
      - "2": SEV3
      - "3": SEV4
  - name: runbook.service
    type: Input
    options:
      placeholder: "Service name"
  - name: runbook.on_call
    type: Multi
    options: []
  - name: runbook.escalation
    type: Multi
    options: []
  - name: runbook.sla
    type: Input
    options:
      placeholder: "e.g., 15m response, 1h resolution"
  - name: runbook.last_tested
    type: Date
    options:
      dateFormat: YYYY-MM-DD
  - name: runbook.automation
    type: Select
    options:
      - "0": manual
      - "1": semi-automated
      - "2": fully-automated
  - name: runbook.alert_source
    type: Multi
    options:
      - "0": prometheus
      - "1": datadog
      - "2": pagerduty
      - "3": cloudwatch
      - "4": grafana
      - "5": custom
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
