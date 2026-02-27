---
id: 528d3d34-4750-408b-85f7-ef910ed87da2
title: "ADR: YAML Frontmatter Standard"
created: 2025-11-21T00:00:00
updated: 2025-12-13T00:00:00
project: dotfiles
scope:
  - obsidian
  - general
type: adr
status: ✅ approved
publish: false
tags:
  - adr
  - architecture
  - documentation
  - zettelkasten
  - metadata
aliases:
  - Frontmatter Standard ADR
  - YAML Frontmatter
related:
  - ref: "[[doc-note]]"
    description: Document note template
adr:
  number: "003"
  supersedes: null
  superseded_by: null
  deciders:
    - arustydev
---

# ADR: YAML Frontmatter Standard for All Markdown Documents

## Status

Accepted

## Context

The project needs a consistent way to:

1. Uniquely identify documents independent of file paths
2. Create relationships between documents
3. Track document metadata (status, author, dates)
4. Enable Zettelkasten-style knowledge graph navigation
5. Support future tooling (graph visualization, link validation)

---

## Decision

**Adopt YAML frontmatter for ALL project markdown documents** with the following standard structure:

```yaml
---
id: <UUID>
title: <Document Title>
created: <ISO 8601 datetime>
updated: <ISO 8601 datetime>
project: <project name>
scope:
  - <scope1>
  - <scope2>
type: <document type>
status: <emoji> <status>
publish: <boolean>
tags:
  - <tag1>
  - <tag2>
aliases:
  - <alias1>
related:
  - ref: "[[linked-doc]]"
    description: <relationship description>
---
```

---

## Field Specifications

### Required Fields

| Field | Format | Purpose |
|-------|--------|---------|
| `id` | UUID v4 | Unique, stable identifier (immutable after creation) |
| `title` | String | Human-readable title matching H1 heading |
| `created` | ISO 8601 | Creation timestamp |
| `updated` | ISO 8601 | Last update timestamp |
| `project` | String | Project identifier |
| `type` | String | Document type (reference, guide, adr, etc.) |
| `status` | Emoji + String | Document state with visual indicator |

### Status Values

| Status | Meaning |
|--------|---------|
| 📝 draft | Initial creation, not ready for review |
| 🚧 in-progress | Actively being worked on |
| 👀 awaiting-review | Ready for review, waiting for reviewer |
| 🔍 in-review | Currently being reviewed |
| ❓ needs-info | Blocked, waiting for clarification |
| ✅ approved | Reviewed and approved |
| ☑️ completed | Done |
| ⏸️ backlog | Not started/paused, not a priority |
| ⚠️ deprecated | Outdated, superseded |
| 📦 archived | No longer active, preserved for reference |

### Optional Fields

| Field | Format | Purpose |
|-------|--------|---------|
| `scope` | Array of strings | Topic areas (docker, mcp, ai, etc.) |
| `publish` | Boolean | Whether to publish externally |
| `tags` | Array of strings | Topic-based categorization |
| `aliases` | Array of strings | Alternative names for linking |
| `related` | Array of objects | Zettelkasten "see also" links |

---

## Document Type Standards

### ADR Documents

**Additional fields:**
```yaml
adr:
  number: "001"
  supersedes: null
  superseded_by: null
  deciders:
    - username
```

### Plan Documents

```yaml
plan:
  phase: discovery | design | implementation | testing | deployment
  priority: critical | high | medium | low
  effort: XS | S | M | L | XL
```

### Research Documents

```yaml
research:
  hypothesis: "What are you trying to prove?"
  methodology: experimental | observational | comparative
  conclusion: pending | confirmed | rejected | inconclusive
```

---

## Benefits

### Immediate

1. **Stable References:** UUIDs never change, even when files are renamed
2. **Graph Structure:** Documents form a navigable knowledge graph
3. **Metadata Rich:** Status, dates, authors captured consistently
4. **Visual Scanning:** Emoji status enables quick assessment

### Long-term

1. **Tooling Support:** Graph visualizers, link checkers, index generators
2. **Export Compatibility:** Works with Obsidian, Foam, Logseq
3. **Search Enhancement:** Filter by status, date, author, scope
4. **Automated Indexes:** Generate INDEX.md from frontmatter
5. **Link Integrity:** Validate UUID references, detect orphaned docs

---

## Consequences

### Positive

- Path-independent document references
- Rich metadata for querying and filtering
- Zettelkasten-style knowledge management
- Compatible with multiple tools (Obsidian, static site generators)

### Negative

- Manual UUID generation required
- Frontmatter maintenance overhead
- Learning curve for contributors

### Mitigations

- Templates with pre-populated frontmatter
- UUID generator scripts
- Metadata Menu plugin for validation
- Clear documentation in templates

---

## Validation Rules

### Automated Checks

1. Frontmatter exists in all markdown files
2. Required fields present
3. UUID format valid (lowercase with hyphens)
4. Date format valid (ISO 8601)
5. Status uses standard values
6. All UUID references exist in another document

---

## References

- [Zettelkasten Method](https://zettelkasten.de/)
- [YAML Frontmatter](https://jekyllrb.com/docs/front-matter/)
- [UUID RFC 4122](https://tools.ietf.org/html/rfc4122)
- [Obsidian Frontmatter](https://help.obsidian.md/Advanced+topics/YAML+front+matter)

---

> [!info] Metadata
> **ADR**: `= this.adr.number`
> **Status**: `= this.status`
> **Deciders**: `= this.adr.deciders`
