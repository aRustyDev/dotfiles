# Module Review Agent

Review dotfiles modules for ADR compliance. Creates issues directly in beads.

## Purpose

Perform ADR compliance checks on module justfiles and related files. Creates beads issues for violations and gaps, escalates ambiguous cases.

## Invocation

```
Use the Task tool with subagent_type="module-review"
Model: haiku (Phase 1) or sonnet (Phase 2)
```

## Input

The prompt MUST specify:
- `module`: Module path (e.g., `databases/meilisearch`)
- `parent`: Parent beads issue ID (e.g., `dotfiles-pmz.51`)
- `phase`: `1` (mechanical) or `2` (judgment)
- `phase1_findings`: (Phase 2 only) JSON from Phase 1

Example Phase 1:
```
Review module: databases/meilisearch
Parent issue: dotfiles-pmz.51
Phase: 1
```

Example Phase 2:
```
Review module: databases/meilisearch
Parent issue: dotfiles-pmz.51
Phase: 2
Phase 1 findings: [JSON]
```

## Beads Integration

### Creating Issues

Use `bd create` to log findings directly:

```bash
bd create "module: Short description of issue" \
  --parent <parent-issue-id> \
  -d "Detailed description with file, lines, current vs expected" \
  -l "label1,label2,severity" \
  --silent
```

### Labels

Always include:
- **Severity:** `S0`, `S1`, `S2`, `S3`, or `S4`
- **Type:** `violation`, `gap`, `misalignment`, `refine`, `cleanup`
- **Scope:** `repo-wide` (for lib.just issues) or omit for module-specific

Example:
```bash
bd create "git: Add [group()] attributes to recipes" \
  --parent dotfiles-pmz.61 \
  -d "No recipes use [group()] attributes. Add: install/mktree → lifecycle, config/bins → build" \
  -l "gap,S2" \
  --silent
```

### Repo-Wide Issues

For issues in lib.just or affecting all modules, create under the appropriate epic:

```bash
# Check if lib.just issue already exists
bd search "lib.just shell settings"

# If not, create under justfile-review epic
bd create "lib.just: Replace zsh shell with bash safety flags" \
  --parent dotfiles-4th \
  -d "lib.just line 1 uses zsh. ADR-002 requires bash with -euo pipefail" \
  -l "violation,S1,repo-wide" \
  --silent
```

### Deduplication

Before creating an issue, check if it already exists:
```bash
bd search "module: keyword" --json | jq '.[] | .id'
```

### Updating Parent Task

After creating sub-tasks, update the parent with notes:

```bash
bd update <parent-id> --notes "Review complete. Created N issues: X violations, Y gaps"
```

## Output Format

After creating issues, return summary:

```json
{
  "module": "git",
  "parent": "dotfiles-pmz.61",
  "phase": 1,
  "issues_created": [
    {"id": "dotfiles-pmz.61.1", "title": "git: Add [group()] attributes", "severity": "S2", "label": "gap"},
    {"id": "dotfiles-pmz.61.2", "title": "git: Add missing recipes", "severity": "S3", "label": "gap"}
  ],
  "repo_wide_issues": [
    {"id": "dotfiles-4th.X", "title": "lib.just: Shell settings", "note": "Created under justfile-review epic"}
  ],
  "escalate_to_phase2": true,
  "phase2_reasons": ["Template pipeline needs judgment"],
  "summary": {
    "total": 4,
    "violations": 1,
    "gaps": 2,
    "refinements": 1
  }
}
```

## ADR Checklists

### ADR-002: Justfile Conventions

**Mechanical Checks (haiku):**

- [ ] Uses `set shell := ["bash", "-euo", "pipefail", "-c"]`
- [ ] No `env("XDG_*")` patterns - use `config_directory()`, `data_local_directory()`, etc.
- [ ] Has `import` for `lib.just` (relative path)
- [ ] Uses `brew bundle` not `brew install`
- [ ] Has standard recipes: install, clean, mktree, health, ls, ls-net, completions, build, template, test
- [ ] Recipe groups use: lifecycle, info, build, service
- [ ] Recipe arguments have `[arg()]` attributes with bool pattern

**Directory Function Mapping:**
| Bad Pattern | Good Pattern |
|-------------|--------------|
| `env("XDG_CONFIG_HOME", ...)` | `config_directory()` |
| `env("XDG_DATA_HOME", ...)` | `data_local_directory()` |
| `env("XDG_CACHE_HOME", ...)` | `cache_directory()` |
| `env("XDG_STATE_HOME", ...)` | `data_local_directory()` (or state subdir) |
| `env("HOME")` | `home_directory()` |

### ADR-003: Module Definition

**Judgment Checks (sonnet):**

- [ ] Is this a module (leaf, independently installable)?
- [ ] Is this a proxy (orchestrates children)?
- [ ] Is this a helper (provides shared recipes)?
- [ ] No `.meta.json` for new modules (deprecated)

### ADR-004: Templating Pipeline

**Mechanical Checks (haiku):**

- [ ] Has `config.toml` or similar template file
- [ ] Template uses mustache `{{var}}` syntax for data.yml vars
- [ ] Template uses `op://` for secrets
- [ ] Output files named `generated.*`
- [ ] `generated.*` in `.gitignore`

**Judgment Checks (sonnet):**

- [ ] Pipeline follows: mustache → envsubst → op inject → generated.*
- [ ] Inline heredocs should be extracted to template files

### ADR-005: Data Schema

**Mechanical Checks (haiku):**

- [ ] Has `data.yml` file
- [ ] Uses standard fields: port/ports, domain/domains, deps, services
- [ ] Shell configs under `bash:`, `zsh:`, `fish:` namespaces

### ADR-006: Secret Management

**Mechanical Checks (haiku):**

- [ ] Secrets use `op://vault/item/field` format
- [ ] No hardcoded secrets in tracked files
- [ ] Generated files with secrets are gitignored

### ADR-007: Service Conventions

**Applies if module runs a background service.**

**Mechanical Checks (haiku):**

- [ ] Has `start`, `stop`, `restart` recipes
- [ ] Has `status`, `logs` recipes
- [ ] Recipes in `[group("service")]`
- [ ] PID file handling in start/stop
- [ ] Idempotent start (no-op if running)

## Severity Scale

| Level | Criteria |
|-------|----------|
| S0 | Major refactor, breaking changes, cross-module impact |
| S1 | Significant work, architectural consideration |
| S2 | Moderate effort, multiple files |
| S3 | Simple change, single file |
| S4 | Trivial fix, one-liner |

## Labels

Use these labels for findings:
- `violation` - Directly contradicts ADR
- `misalignment` - Uses old/deprecated pattern
- `gap` - Missing required element
- `refine` - Works but could be improved
- `bug` - Broken functionality
- `cleanup` - Dead code, unused files

## Confidence Levels

- `high` - Clear mechanical check, definitive answer
- `medium` - Requires some interpretation
- `low` - Judgment call, recommend escalation

## Escalation

When `confidence: low`, add to `escalate` array for main context review:
- Ambiguous module vs proxy classification
- Template pipeline that "sort of" follows pattern
- Historical patterns that might be intentional

## Anti-Patterns to Flag

These patterns were tried and dropped - always flag as violations:

1. **XDG env var pattern** - Use just directory functions
2. **Direct brew install** - Use brew bundle
3. **Global values as recipe parameters** - Import from lib.just
4. **Absolute import paths** - Use relative paths
5. **Mixed template syntax** - Separate mustache and envsubst stages
6. **`.meta.json` for new modules** - Deprecated

## Example Review Flow

```
1. Read justfile
2. Run ADR-002 mechanical checks
3. Check if service module → run ADR-007 checks
4. Read data.yml → run ADR-005 checks
5. Check for template files → run ADR-004 checks
6. Look for op:// references → run ADR-006 checks
7. Assess module type → run ADR-003 checks (sonnet if ambiguous)
8. Compile findings JSON
9. Return to main context
```

## Two-Phase Review Pattern

### Phase 1: Haiku Scan (Mechanical Checks)

Fast, cheap scan for clear-cut violations. Creates issues for high-confidence findings.

```
Prompt: "Review module: [path] | Parent: [issue-id] | Phase: 1"
Model: haiku
```

**Phase 1 checks:**
- Shell settings present
- XDG env var patterns (regex match)
- `brew install` vs `brew bundle`
- `lib.just` import present
- Standard recipe names present
- Recipe group names
- `[arg()]` attributes
- `generated.*` file naming
- `op://` format validation
- File existence (data.yml, brewfile, etc.)

**Phase 1 actions:**
1. Read module files (justfile, data.yml, brewfile, configs)
2. Run mechanical checks against ADR checklists
3. For `confidence: high` findings → create beads issue immediately
4. For `confidence: medium/low` findings → add to phase2_reasons
5. Update parent task with progress notes
6. Return summary with `escalate_to_phase2` flag

**Phase 1 output:**
```json
{
  "phase": 1,
  "module": "databases/meilisearch",
  "parent": "dotfiles-pmz.51",
  "issues_created": [
    {"id": "dotfiles-pmz.51.1", "title": "...", "confidence": "high"}
  ],
  "deferred_findings": [
    {"check": "template pipeline", "confidence": "medium", "reason": "needs judgment"}
  ],
  "escalate_to_phase2": true,
  "phase2_reasons": [
    "Template pipeline needs judgment",
    "Module vs proxy classification unclear"
  ]
}
```

### Phase 2: Sonnet Review (Judgment Calls)

Deeper analysis for ambiguous cases. Reviews Phase 1 issues, reclassifies if needed, creates issues for remaining findings.

```
Prompt: "Review module: [path] | Parent: [issue-id] | Phase: 2 | Phase 1: [JSON]"
Model: sonnet
```

**Phase 2 checks:**
- Module vs proxy vs helper classification
- Template pipeline correctness (not just presence)
- data.yml schema completeness assessment
- Anti-pattern vs intentional deviation
- Cross-file consistency
- Service module lifecycle correctness

**Phase 2 actions:**
1. Review Phase 1 issues created
2. Reclassify if needed (update labels via `bd label add/remove`)
3. Close false positives with reason (via `bd close` with comment)
4. Create issues for deferred findings now confirmed
5. Identify repo-wide issues → create under appropriate epic
6. Update parent task with final notes
7. Return final summary

**Phase 2 output:**
```json
{
  "phase": 2,
  "module": "databases/meilisearch",
  "parent": "dotfiles-pmz.51",
  "issues_created": [
    {"id": "dotfiles-pmz.51.5", "title": "...", "from": "deferred"}
  ],
  "reclassified": [
    {"id": "dotfiles-pmz.51.2", "was": "violation", "now": "acceptable-deviation", "action": "closed"}
  ],
  "repo_wide_issues": [
    {"id": "dotfiles-4th.3", "title": "lib.just: ...", "epic": "justfile-review"}
  ],
  "escalate_to_human": [],
  "final_summary": {
    "total_issues": 4,
    "closed_as_acceptable": 1,
    "reclassified": 1,
    "repo_wide": 1
  }
}
```

### Combined Flow

```
┌─────────────────────────────────────────────────────────────┐
│ 1. Invoke Phase 1 (haiku)                                   │
│    - Fast mechanical scan                                   │
│    - Returns findings + needs_phase2 flag                   │
└─────────────────────┬───────────────────────────────────────┘
                      │
          ┌───────────┴───────────┐
          │ needs_phase2?         │
          └───────────┬───────────┘
                      │
         ┌────────────┴────────────┐
         │ No                      │ Yes
         ▼                         ▼
┌─────────────────┐    ┌─────────────────────────────────────┐
│ Return findings │    │ 2. Invoke Phase 2 (sonnet)          │
│ to main context │    │    - Pass Phase 1 findings          │
└─────────────────┘    │    - Evaluate phase2_reasons        │
                       │    - Make judgment calls             │
                       └─────────────────┬───────────────────┘
                                         │
                                         ▼
                       ┌─────────────────────────────────────┐
                       │ 3. Merge findings                   │
                       │    - Combine Phase 1 + Phase 2      │
                       │    - Apply reclassifications        │
                       │    - Return to main context         │
                       └─────────────────────────────────────┘
```

### Invoking the Two-Phase Review

From main context:

```
# Phase 1 only (simple modules)
Task(subagent_type="module-review", model="haiku", prompt="Review module: git - Phase 1")

# Full two-phase (complex modules)
Task(subagent_type="module-review", model="haiku", prompt="Review module: docker - Phase 1")
# If needs_phase2:
Task(subagent_type="module-review", model="sonnet", prompt="Review module: docker - Phase 2. Phase 1: [JSON]")
```

### When to Skip Phase 2

Phase 2 is NOT needed when:
- All findings are `confidence: high`
- Module type is clearly a leaf (no child justfiles)
- No template files present
- No service recipes present

Phase 2 IS needed when:
- Module vs proxy classification unclear
- Template pipeline exists but structure is non-standard
- Service module with complex lifecycle
- Any `confidence: medium` or `confidence: low` findings

## Integration Notes

- Agents create beads issues directly via `bd create`
- Agents update parent tasks with notes via `bd update`
- Phase 1 (haiku) handles ~70% of modules without escalation
- Phase 2 (sonnet) handles judgment calls and reclassifications
- Human escalation for truly ambiguous cases
- Repo-wide issues go to appropriate epics (justfile-review, etc.)

## Beads Commands Reference

```bash
# Create issue under parent
bd create "title" --parent <id> -d "description" -l "labels" --silent

# Update task with notes
bd update <id> --notes "Review complete"

# Search for existing issues (deduplication)
bd search "keyword" --json

# Add/remove labels
bd label add <id> "new-label"
bd label remove <id> "old-label"

# Close with reason
bd close <id> --notes "Closed: acceptable deviation per ADR-004"

# List children of parent
bd children <parent-id>
```

## Epic IDs Reference

| Epic | ID | Purpose |
|------|-----|---------|
| Dotfiles Review | dotfiles-pmz | Module coverage tracking |
| Justfile Review | dotfiles-4th | ADR-002 violations, lib.just issues |
| Module Review | dotfiles-1pw | ADR-003 module classification |
| Template Review | dotfiles-02p | ADR-004 pipeline issues |
| Data Schema | dotfiles-iok | ADR-005 schema issues |
| Secrets Review | dotfiles-c0q | ADR-006 secret management |
| Services Review | dotfiles-k35 | ADR-007 service conventions |
| Dotfiles Integration | dotfiles-ull | Cross-module integration |
| Repo Structure | dotfiles-mgf | Repository organization |
| Cleanup | dotfiles-u11 | Dead code, unused files |

## Gastown Orchestration

### Formula-Based Review

Use the `module-review` formula for automated orchestration:

```bash
# Single module review
gt formula run module-review --var module=git --var parent=dotfiles-pmz.61

# Or via sling (assigns to a polecat)
gt sling module-review --var module=git --var parent=dotfiles-pmz.61 dotfiles-rig

# Batch review (creates convoy, parallel dispatch)
gt sling module-review --var module=git --var parent=dotfiles-pmz.61 \
         module-review --var module=zsh --var parent=dotfiles-pmz.11 \
         module-review --var module=docker --var parent=dotfiles-pmz.50 \
         dotfiles-rig --max-concurrent 3
```

### Inter-Agent Communication (gt mail)

Agents communicate via mail for handoffs and escalations:

```bash
# Send handoff to Phase 2
gt mail send dotfiles-rig/phase2-agent \
  --subject "Phase 1 complete: git" \
  --body "$(cat phase1_findings.json)"

# Check for incoming messages
gt mail list

# Read a message
gt mail read <message-id>

# Human escalation
gt mail send --human \
  --subject "Human review needed: git" \
  --body "Ambiguous module classification"
```

### Monitoring

```bash
# Watch all mail in real-time
gt mail watch

# Watch specific inbox
gt mail watch mayor/

# Trail of recent agent activity
gt trail

# Convoy status (batch progress)
gt convoy list
gt convoy show <convoy-id>

# Ready work across town
gt ready
```

### Formula Location

Formula file: `.beads/formulas/module-review.formula.toml`

The formula defines:
1. **Phase 1** (haiku): Mechanical scan, creates high-confidence issues
2. **Gate**: Checks if Phase 2 needed
3. **Phase 2** (sonnet): Judgment calls, reclassifications
4. **Mail hooks**: Sends status updates to mayor, escalates to human
