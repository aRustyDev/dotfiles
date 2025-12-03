---
id: 528D3D34-4750-408B-85F7-EF910ED87DA2
title: ADR: YAML Frontmatter Standard for All Markdown Documents
status: ✅ Accepted
date: 2025-11-21
author: aRustyDev
---

# ADR: YAML Frontmatter Standard for All Markdown Documents

**Status:** Proposed
**Date:** 2025-11-21
**Context:** Zettelkasten knowledge management system with graph-based document relationships

---

## Problem Statement

The project needs a consistent way to:

1. Uniquely identify documents independent of file paths
2. Create relationships between documents (related, hierarchical)
3. Track document metadata (status, author, dates)
4. Enable Zettelkasten-style knowledge graph navigation
5. Support future tooling (graph visualization, link validation, index generation)

### Current State

- Some documents have no frontmatter
- HTTP_IMPLEMENTATION.md has the new frontmatter standard
- No documented standard for future documents
- No enforcement mechanism for frontmatter consistency

---

## Decision

**Adopt YAML frontmatter for ALL project markdown documents** (plans, ADRs, guides, documentation) with the following standard structure:

```yaml
---
id: <UUID>
title: <Document Title>
status: <Status with Emoji>
date: <YYYY-MM-DD>
author: <Author Username>
related:
  - <UUID>
  - <UUID>
children:
  - <UUID>
  - <UUID>
---
```

---

## Frontmatter Field Specifications

### Required Fields

#### `id` (UUID v4)

- **Format:** Uppercase UUID with hyphens (e.g., `15754957-34F7-418C-8E2A-319175C225C3`)
- **Purpose:** Unique, stable identifier for the document
- **Generation:** Use `uuidgen` (macOS/Linux) or `python -c "import uuid; print(str(uuid.uuid4()).upper())"`
- **Immutable:** Once assigned, never changes even if file is renamed/moved

#### `title` (String)

- **Format:** Human-readable title matching the H1 heading
- **Purpose:** Display name for indexes, references, and tooling
- **Example:** `"HTTP Transport Implementation Plan"`

#### `status` (String with Emoji)

- **Format:** Emoji prefix + status text
- **Purpose:** Visual indication of document state
- **Standard Values:**
  - `✅ Completed` - Work finished, document archived
  - `⏳ In Progress` - Actively being worked on
  - `📝 Draft` - Initial draft, not reviewed
  - `🗄️ Archived` - Historical, no longer maintained
  - `🔄 Under Review` - Awaiting review/approval
  - `❌ Deprecated` - Superseded by newer document
  - `🎯 Proposed` - Proposed but not approved
- **Custom:** Projects can define additional statuses

#### `date` (ISO 8601 Date)

- **Format:** `YYYY-MM-DD`
- **Purpose:** Creation date or last major update
- **Usage:** Sorting, filtering, temporal queries
- **Example:** `2025-11-21`

#### `author` (String)

- **Format:** GitHub username or author identifier
- **Purpose:** Document ownership and accountability
- **Example:** `aRustyDev`
- **Multi-author:** Use primary author or comma-separated list

### Optional Fields

#### `related` (Array of UUIDs)

- **Format:** YAML array of document UUIDs
- **Purpose:** Zettelkasten "related notes" / "see also" links
- **Relationship:** Bidirectional, non-hierarchical connections
- **Example:**
  ```yaml
  related:
    - B9935AA5-778E-4280-8116-4B19306C02DB
    - A1234567-89AB-CDEF-0123-456789ABCDEF
  ```
- **Usage:** "This document relates to these other documents"

#### `children` (Array of UUIDs)

- **Format:** YAML array of document UUIDs
- **Purpose:** Hierarchical parent-child relationships
- **Relationship:** Directional (parent → child)
- **Example:** Plan document → Archived phase documents
  ```yaml
  children:
    - B9935AA5-778E-4280-8116-4B19306C02DB # Phase 1
    - C2345678-9ABC-DEF0-1234-56789ABCDEF0 # Phase 2
  ```
- **Usage:** "This document contains/spawned these sub-documents"

#### `tags` (Array of Strings) - Future

- **Format:** YAML array of lowercase tags
- **Purpose:** Topic-based categorization
- **Example:**
  ```yaml
  tags:
    - http-transport
    - architecture
    - testing
  ```

#### `version` (String) - Future

- **Format:** Semantic version or revision number
- **Purpose:** Track document versions
- **Example:** `1.2.0`

---

## Document Type Standards

### Plan Documents (`.ai/plans/*.md`)

**Required Fields:** All required fields + `children` (if has archived phases)

**Example:**

```yaml
---
id: 15754957-34F7-418C-8E2A-319175C225C3
title: HTTP Transport Implementation Plan
status: ✅ Completed
date: 2025-11-20
author: aRustyDev
related:
  - B9935AA5-778E-4280-8116-4B19306C02DB # ADR: HTTP Transport Architecture
children:
  - 4F8A9B3C-1D2E-4A5B-9C6D-7E8F9A0B1C2D # Phase 1
  - 5G9B0C4D-2E3F-5B6C-0D7E-8F9G0A1B2C3E # Phase 2
---
```

### Archived Phase Documents (`.ai/plans/completed/*.md`)

**Required Fields:** All required fields + `related` pointing back to parent plan

**Example:**

```yaml
---
id: 4F8A9B3C-1D2E-4A5B-9C6D-7E8F9A0B1C2D
title: HTTP Transport Implementation - Phase 1: Add Dependencies
status: ✅ Completed
date: 2025-11-20
author: aRustyDev
related:
  - 15754957-34F7-418C-8E2A-319175C225C3  # Parent plan
---
```

### ADR Documents (`docs/project-knowledge/dev/adr-*.md`)

**Required Fields:** All required fields + `related` for related ADRs

**Example:**

```yaml
---
id: B9935AA5-778E-4280-8116-4B19306C02DB
title: ADR: HTTP Transport Architecture
status: ✅ Accepted
date: 2025-11-20
author: aRustyDev
related:
  - 15754957-34F7-418C-8E2A-319175C225C3  # HTTP Implementation Plan
  - C3456789-0ABC-DEF1-2345-6789ABCDEF01  # ADR: Lazy Loading
---
```

### User/Developer Guides (`docs/project-knowledge/*/`)

**Required Fields:** All required fields, `related` if applicable

**Example:**

```yaml
---
id: D4567890-1BCD-EF23-4567-890ABCDEF012
title: HTTP Transport Troubleshooting Guide
status: ✅ Published
date: 2025-11-21
author: aRustyDev
related:
  - B9935AA5-778E-4280-8116-4B19306C02DB # ADR: HTTP Transport
  - E5678901-2CDE-F345-6789-01BCDEF01234 # HTTP Usage Guide
---
```

### Index Documents (`.ai/INDEX.md`)

**Required Fields:** All required fields, `children` for navigational structure

**Example:**

```yaml
---
id: F6789012-3DEF-4567-890A-BCDEF0123456
title: Zettelkasten MCP - Project Index
status: ⏳ Living Document
date: 2025-11-21
author: aRustyDev
children:
  - 15754957-34F7-418C-8E2A-319175C225C3 # HTTP Implementation Plan
---
```

---

## Implementation Strategy

### Phase 1: Foundation (Priority: High)

1. **Create ADR** (this document)
2. **Document standard** in `.rules`
3. **Update template** (`.ai/templates/EXAMPLE_PLAN.md`)
4. **Create UUID generator script** (`.ai/scripts/generate-uuid.sh`)

### Phase 2: Retroactive Application (Priority: High)

1. **Add frontmatter to HTTP_IMPLEMENTATION.md** ✅ Already done
2. **Add frontmatter to all 13 archived phases**
3. **Add frontmatter to .ai/INDEX.md**
4. **Add frontmatter to all ADRs** (5 documents)
5. **Add frontmatter to all user/dev guides** (10+ documents)

### Phase 3: Validation & Tooling (Priority: Medium)

1. **Create frontmatter validation script** (Python)
2. **Create UUID cross-reference checker**
3. **Add pre-commit hook** for frontmatter validation
4. **Create document graph visualizer** (optional)

### Phase 4: Documentation & Enforcement (Priority: High)

1. **Update .rules** with frontmatter requirements
2. **Update CONTRIBUTING.md** (if exists) with frontmatter guide
3. **Add to plan template** archival instructions
4. **Create examples** in template

---

## Benefits

### Immediate

1. **Stable References:** UUIDs never change, even when files are renamed
2. **Graph Structure:** Documents form a navigable knowledge graph
3. **Metadata Rich:** Status, dates, authors captured consistently
4. **Visual Scanning:** Emoji status enables quick document state assessment

### Long-term

1. **Tooling Support:** Can build graph visualizers, link checkers, index generators
2. **Export Compatibility:** Can export to Obsidian, Foam, Logseq (all support frontmatter)
3. **Search Enhancement:** Filter by status, date, author, related docs
4. **Automated Indexes:** Generate INDEX.md automatically from frontmatter
5. **Link Integrity:** Validate all UUID references, detect orphaned docs

### Zettelkasten Alignment

1. **Atomic Notes:** Each document is a discrete unit
2. **Bidirectional Links:** `related` creates non-hierarchical connections
3. **Hierarchical Structure:** `children` supports structured breakdown
4. **Unique IDs:** UUID enables stable, path-independent references
5. **Emergent Structure:** Graph relationships emerge organically

---

## Tradeoffs

### Added Complexity

- **Manual UUID Generation:** Requires running a command for each new doc
- **Frontmatter Maintenance:** Keeping `related` and `children` updated
- **Learning Curve:** Contributors must understand frontmatter standard

**Mitigation:**

- Provide `generate-uuid.sh` script for easy UUID creation
- Document standard clearly in `.rules` and templates
- Create validation tools to catch errors early

### Frontmatter Overhead

- **File Size:** Adds ~10 lines to each document
- **Visual Noise:** Frontmatter before content

**Mitigation:**

- Most editors collapse frontmatter by default (Obsidian, VS Code with extensions)
- Benefits far outweigh minor overhead
- Frontmatter is standard practice in static site generators (Jekyll, Hugo, etc.)

### Migration Effort

- **Retroactive Application:** ~30+ existing documents need frontmatter
- **UUID Assignment:** Each document needs a unique UUID
- **Relationship Mapping:** Identifying `related` and `children` links

**Mitigation:**

- Phased approach: Critical docs first (plans, ADRs), then user docs
- Batch script to add basic frontmatter (ID, title, date)
- Manual relationship mapping (most important for knowledge graph)

---

## Alternatives Considered

### 1. No Frontmatter Standard

**Rejected:** Misses opportunity to create knowledge graph structure, no stable document IDs

### 2. Path-Based References

**Rejected:** File renames break links, not refactoring-safe

### 3. Numeric IDs Instead of UUIDs

**Rejected:** Requires central registry, collision risk in distributed workflow

### 4. Minimal Frontmatter (Just ID and Title)

**Rejected:** Loses valuable metadata (status, author, dates), reduces tooling potential

### 5. Custom Markdown Link Syntax

**Rejected:** Not compatible with standard Markdown tools, reinventing the wheel

---

## Success Metrics

### Adoption

- Target: 100% of plan documents have frontmatter (by end of implementation)
- Target: 100% of ADRs have frontmatter
- Target: 80%+ of user/dev guides have frontmatter

### Quality

- Target: Zero broken UUID references (validated by script)
- Target: All bi-directional links properly maintained (related documents reference each other)

### Tooling

- Target: Validation script catches frontmatter errors pre-commit
- Target: INDEX.md can be auto-generated from frontmatter

---

## Validation Rules

### Automated Checks (Pre-commit Hook)

1. **Frontmatter Exists:** All `.md` files in `docs/`, `.ai/plans/`, `.ai/templates/` have frontmatter
2. **Required Fields Present:** `id`, `title`, `status`, `date`, `author` all exist
3. **UUID Format Valid:** `id` matches UUID v4 pattern (uppercase with hyphens)
4. **Date Format Valid:** `date` matches YYYY-MM-DD pattern
5. **Status Values:** `status` uses one of the standard emoji prefixes
6. **UUID References Valid:** All UUIDs in `related`/`children` exist in another document
7. **Title Matches H1:** `title` field matches first H1 heading in document

### Manual Checks (Code Review)

1. **Bidirectional Links:** If A relates to B, does B relate to A?
2. **Appropriate Relationships:** Are `related` vs `children` used correctly?
3. **Status Accuracy:** Does document status reflect actual state?

---

## Migration Checklist

### Per Document

- [ ] Generate UUID with `uuidgen` or script
- [ ] Add frontmatter block at top of file
- [ ] Fill required fields (id, title, status, date, author)
- [ ] Add `related` links to related documents
- [ ] Add `children` links if parent document
- [ ] Validate frontmatter with validation script
- [ ] Update related documents to link back (bidirectional)

### Bulk Operations

- [ ] Plan documents (`.ai/plans/*.md`)
- [ ] Archived phases (`.ai/plans/completed/*.md`)
- [ ] ADRs (`docs/project-knowledge/dev/adr-*.md`)
- [ ] Dev guides (`docs/project-knowledge/dev/*.md`)
- [ ] User guides (`docs/project-knowledge/user/*.md`)
- [ ] Templates (`.ai/templates/*.md`)
- [ ] Index (`.ai/INDEX.md`)

---

## Implementation Timeline

**Phase 1 (Day 1):** Foundation

- Create ADR ✅
- Update .rules
- Update template
- Create UUID generator

**Phase 2 (Day 1-2):** Critical Documents

- All plan documents
- All archived phases
- INDEX.md
- All ADRs

**Phase 3 (Day 2-3):** Supporting Documents

- Dev guides
- User guides
- Prompts (optional)

**Phase 4 (Day 3):** Tooling & Validation

- Validation script
- Pre-commit hook
- Documentation

**Total Estimated Time:** 2-3 days of focused work

---

## Related Decisions

- **ADR: Plan Archival Strategy** - Uses frontmatter for archived phases
- **Zettelkasten Methodology** - Project's core knowledge management approach

---

## References

- [Zettelkasten Method](https://zettelkasten.de/)
- [YAML Frontmatter](https://jekyllrb.com/docs/front-matter/)
- [UUID RFC 4122](https://tools.ietf.org/html/rfc4122)
- [Obsidian Frontmatter](https://help.obsidian.md/Advanced+topics/YAML+front+matter)

---

**Next Steps:**

1. Review and approve this ADR
2. Update `.rules` with frontmatter requirements
3. Begin Phase 2 implementation (retroactive application)

**Owner:** Development team
**Tags:** #architecture #documentation #zettelkasten #metadata

---

**Last Updated:** 2025-11-21
**Review Date:** After full implementation (estimated 2025-11-24)
