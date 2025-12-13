---
filesPaths:
  - .ai/rules
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
  - name: ai_rules.category
    type: Select
    options:
      - "0": coding-style
      - "1": architecture
      - "2": testing
      - "3": documentation
      - "4": security
      - "5": performance
      - "6": framework
      - "7": language
      - "8": workflow
      - "9": persona
  - name: ai_rules.targets.cursor
    type: Boolean
  - name: ai_rules.targets.windsurf
    type: Boolean
  - name: ai_rules.targets.copilot
    type: Boolean
  - name: ai_rules.targets.vscode
    type: Boolean
  - name: ai_rules.targets.zed
    type: Boolean
  - name: ai_rules.targets.claude_code
    type: Boolean
  - name: ai_rules.targets.claude_desktop
    type: Boolean
  - name: ai_rules.targets.aider
    type: Boolean
  - name: ai_rules.targets.continue
    type: Boolean
  - name: ai_rules.languages
    type: Multi
    options:
      - "0": any
      - "1": typescript
      - "2": javascript
      - "3": python
      - "4": rust
      - "5": go
      - "6": java
      - "7": kotlin
      - "8": swift
      - "9": shell
      - "10": sql
      - "11": markdown
  - name: ai_rules.priority
    type: Number
    options:
      min: 0
      max: 100
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
