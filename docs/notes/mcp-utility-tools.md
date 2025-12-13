---
id: c3d4e5f6-a7b8-9012-cdef-345678901234
title: MCP Utility Tools Reference
created: 2025-12-13T00:00:00
updated: 2025-12-13T00:00:00
project: dotfiles
scope:
  - mcp
  - ai
type: reference
status: 📝 draft
publish: false
tags:
  - mcp
  - tools
  - utilities
aliases:
  - MCP Utility Reference
  - Char Index MCP
  - Diagram MCP
related:
  - ref: "[[mcp-memory-tools]]"
    description: Memory-related MCP tools
  - ref: "[[mcp-tasks-vs-memory]]"
    description: MCP comparison guide
---

# MCP Utility Tools Reference

Reference for utility MCP tools (string manipulation, diagrams, etc.).

---

## Char-Index MCP

Character and substring manipulation tools.

### Character & Substring Finding (4 tools)

| Tool | Description |
|------|-------------|
| `find_nth_char` | Find nth occurrence of a character |
| `find_all_char_indices` | Find all indices of a character |
| `find_nth_substring` | Find nth occurrence of a substring |
| `find_all_substring_indices` | Find all occurrences of a substring |

### Splitting (1 tool)

| Tool | Description |
|------|-------------|
| `split_at_indices` | Split string at multiple positions |

### String Modification (3 tools)

| Tool | Description |
|------|-------------|
| `insert_at_index` | Insert text at specific position |
| `delete_range` | Delete characters in range |
| `replace_range` | Replace range with new text |

### Utilities (3 tools)

| Tool | Description |
|------|-------------|
| `find_regex_matches` | Find regex pattern matches with positions |
| `extract_between_markers` | Extract text between two markers |
| `count_chars` | Character statistics (total, letters, digits, etc.) |

### Batch Processing (1 tool)

| Tool | Description |
|------|-------------|
| `extract_substrings` | Extract one or more substrings (unified tool) |

---

## Diagram MCP

Diagram generation and validation tools (Mermaid, PlantUML, etc.).

### Core Tools

| Tool | Description |
|------|-------------|
| `generateDiagram` | Generate and render diagrams to SVG files |
| `validateDiagram` | Validate syntax with detailed error reporting |
| `getDiagramInfo` | Analyze diagram complexity and metadata |
| `listSupportedTypes` | Show all 22+ supported diagram types |
| `convertDiagram` | Convert diagrams to different formats |

### Template Tools

| Tool | Description |
|------|-------------|
| `listTemplates` | Browse 50+ pre-built templates |
| `getTemplate` | Get specific template code and metadata |
| `searchTemplates` | Search templates by keyword |
| `createCustomTemplate` | Create reusable custom templates |

---

## Resources

- [Char-Index MCP](https://github.com/agent-hanju/char-index-mcp)
- [Mermaid Syntax](https://mermaid.js.org/syntax/)

---

> [!info] Metadata
> **Scope**: `= this.scope`
> **Type**: `= this.type`
> **Status**: `= this.status`
