# Multi-Model Module Review Workflow (Gastown)

Decomposed workflow for multi-model orchestration in gastown polecats.

> **Note:** This is for **gastown polecat orchestration**. For Claude Code Task tool
> orchestration, see `module-review.md` which uses haiku successfully via Task tool.

## Model Selection for Gastown Polecats

**Haiku does NOT work reliably as a gastown polecat** - it fails to follow instructions,
gets distracted, and doesn't complete tasks. Use Sonnet as the minimum model for
autonomous polecat work.

| Role | Model | Rationale |
|------|-------|-----------|
| Phase 1 (mechanical) | **Sonnet** | Reliable instruction-following for bounded tasks |
| Phase 2 (judgment) | Sonnet | Judgment calls, reclassifications |
| Orchestration | Opus | Cross-cutting issues, complex reasoning |

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           ORCHESTRATOR (Opus)                                │
│                                                                             │
│  Creates work batches, monitors progress, handles cross-cutting issues      │
└─────────────────────────────────────────┬───────────────────────────────────┘
                                          │
                    ┌─────────────────────┴─────────────────────┐
                    │                                           │
                    ▼                                           ▼
┌─────────────────────────────────┐     ┌─────────────────────────────────────┐
│   SONNET POOL (Phase 1)         │     │      SONNET POOL (Phase 2)          │
│                                 │     │                                     │
│  • Mechanical scans             │     │  • Judgment calls                   │
│  • HIGH confidence issues       │ ──▶ │  • Reclassifications                │
│  • Bounded, simple tasks        │mail │  • Repo-wide pattern detection      │
│  • ~1-2 min per module          │     │  • ~2-3 min per module              │
└─────────────────────────────────┘     └──────────────────┬──────────────────┘
                                                           │
                                                           │ mail
                                                           ▼
                                        ┌─────────────────────────────────────┐
                                        │      OPUS (Final Review)            │
                                        │                                     │
                                        │  • Cross-cutting issues             │
                                        │  • Epic management                  │
                                        │  • Human escalations                │
                                        └─────────────────────────────────────┘
```

## Rig Configuration

### Option A: Single Rig with --agent Override (Simpler)

```bash
# Use existing rig, specify agent per sling
gt sling <phase1-bead> adam --agent claude-sonnet --create
gt sling <phase2-bead> adam --agent claude-sonnet --create
```

### Option B: Dedicated Rigs per Model (Cleaner Separation)

```bash
# Create phase1 rig (sonnet for mechanical scans)
gt rig add adam-phase1
gt dolt init-rig adam-phase1
gt rig settings set adam-phase1 role_agents.polecat claude-sonnet

# Create sonnet rig
gt rig add adam-sonnet
gt dolt init-rig adam-sonnet
gt rig settings set adam-sonnet role_agents.polecat claude-sonnet

# Now sling without --agent flag
gt sling <phase1-bead> adam-phase1 --create   # Uses sonnet
gt sling <phase2-bead> adam-sonnet --create  # Uses sonnet
```

## Bead Design (Bounded Tasks)

### Phase 1 Bead Template

```bash
bd create "phase1: Review ${MODULE} for ADR violations" \
  --parent ${EPIC_ID} \
  -d "$(cat <<'EOF'
## Task: Mechanical ADR Scan

**Module:** ${MODULE}
**Parent:** ${PARENT_ID}
**Model:** sonnet (bounded mechanical checks)

### Instructions

1. Read module files:
   - ${MODULE}/justfile
   - ${MODULE}/data.yml (if exists)
   - ${MODULE}/brewfile (if exists)
   - ${MODULE}/.meta.json (if exists)

2. Run mechanical checks (HIGH confidence only):
   - [ ] Shell settings: `set shell := ["bash", "-euo", "pipefail", "-c"]`
   - [ ] No `env("XDG_*")` patterns
   - [ ] Has `import` for lib.just
   - [ ] Uses `brew bundle` not `brew install`
   - [ ] Standard recipes present
   - [ ] `op://` format for secrets

3. For each HIGH confidence violation:
   ```bash
   bd create "${MODULE}: <issue>" --parent ${PARENT_ID} \
     -d "<file, line, current vs expected>" \
     -l "violation,S3" --silent
   ```

4. Compile findings JSON and send to Phase 2:
   ```bash
   gt mail send adam/sonnet-inbox \
     --subject "Phase1: ${MODULE}" \
     --body '<JSON findings>'
   ```

5. Update parent and exit:
   ```bash
   bd update ${PARENT_ID} --notes "Phase 1 complete: N issues, M deferred"
   gt done
   ```

### Output Format
```json
{
  "module": "${MODULE}",
  "parent": "${PARENT_ID}",
  "phase": 1,
  "issues_created": [],
  "deferred": [],
  "needs_phase2": true|false
}
```
EOF
)" \
  -l "phase1,mechanical,${MODULE}" \
  --silent
```

### Phase 2 Bead Template

```bash
bd create "phase2: Judgment review for ${MODULE}" \
  --parent ${EPIC_ID} \
  -d "$(cat <<'EOF'
## Task: Judgment Calls

**Module:** ${MODULE}
**Parent:** ${PARENT_ID}
**Model:** sonnet (judgment and reclassification)
**Phase 1 Findings:** <attached via mail>

### Instructions

1. Read Phase 1 findings from mail:
   ```bash
   gt mail inbox | grep "Phase1: ${MODULE}"
   ```

2. For each deferred finding, determine:
   - CONFIRM → create issue
   - REJECT → document reason
   - REPO-WIDE → create under appropriate epic

3. Review Phase 1 issues for reclassification:
   - False positive? → close with reason
   - Wrong severity? → update labels

4. Check for repo-wide patterns:
   - Same issue in multiple modules?
   - Create under epic: dotfiles-4th (justfile), dotfiles-02p (template), etc.

5. Send summary to main thread:
   ```bash
   gt mail send --human \
     --subject "Phase2 Complete: ${MODULE}" \
     --body '<JSON summary>'
   ```

6. Exit:
   ```bash
   bd update ${PARENT_ID} --notes "Review complete: N total issues"
   gt done
   ```

### Output Format
```json
{
  "module": "${MODULE}",
  "phase": 2,
  "issues_created": [],
  "reclassified": [],
  "repo_wide": [],
  "escalate_to_human": []
}
```
EOF
)" \
  -l "phase2,judgment,${MODULE}" \
  --silent
```

## Orchestration Script

```bash
#!/bin/bash
# multi-model-review.sh - Orchestrate multi-model module review

set -euo pipefail

MODULES=("git" "zsh" "bash" "docker")
EPIC="dotfiles-adam-c4k"
RIG="adam"

# Phase 1: Spawn sonnet polecats for mechanical scans
echo "=== Phase 1: Mechanical Scans (Haiku) ==="
for module in "${MODULES[@]}"; do
  # Create parent task
  parent=$(bd create "Review: ${module}" --parent "$EPIC" -l "review" --silent)
  echo "Created parent: $parent"

  # Create Phase 1 bead
  phase1_id=$(bd create "phase1: Scan ${module}" --parent "$parent" \
    -d "Mechanical ADR scan for ${module}. Parent: ${parent}" \
    -l "phase1,mechanical" --silent)
  echo "Created Phase 1: $phase1_id"

  # Sling to sonnet polecat
  gt sling "$phase1_id" "$RIG" --agent claude-sonnet --create --hook-raw-bead &
  sleep 2  # Stagger spawns
done

wait
echo "Phase 1 complete. Check mail for findings."

# Phase 2: Spawn sonnet polecats for judgment
echo "=== Phase 2: Judgment Calls (Sonnet) ==="
# Read Phase 1 results from mail, create Phase 2 beads...
# (This would be triggered by witness or run manually)
```

## Mail-Based Handoff Protocol

### Haiku → Sonnet Handoff

```bash
# Haiku polecat sends findings:
gt mail send adam/phase2-queue \
  --subject "Phase1 Complete: git" \
  --body "$(cat <<'EOF'
{
  "module": "git",
  "parent": "dotfiles-adam-c4k.2",
  "phase1_issues": ["dotfiles-adam-c4k.2.1", "dotfiles-adam-c4k.2.2"],
  "deferred": [
    {"finding": "duplicate files", "confidence": "medium"},
    {"finding": "template structure", "confidence": "low"}
  ],
  "needs_phase2": true
}
EOF
)"
```

### Sonnet → Opus Handoff

```bash
# Sonnet polecat sends summary:
gt mail send --human \
  --subject "Review Complete: git" \
  --body "$(cat <<'EOF'
{
  "module": "git",
  "total_issues": 5,
  "repo_wide": ["dotfiles-02p.3"],
  "escalations": [],
  "summary": "4 violations, 1 enhancement"
}
EOF
)"
```

## Convoy-Based Batch Processing

For processing multiple modules in parallel:

```bash
# Create convoy for batch
gt convoy create "Module Review Batch" \
  --beads phase1-git phase1-zsh phase1-bash phase1-docker

# Or use batch sling
gt sling phase1-git phase1-zsh phase1-bash phase1-docker \
  adam --agent claude-sonnet --max-concurrent 4
```

## Witness Integration

Configure witness to auto-dispatch Phase 2 when Phase 1 completes:

```yaml
# In rig's witness config
triggers:
  - match: "label:phase1 AND status:closed"
    action: "create-phase2"
    agent: claude-sonnet
```

## Error Handling

### Haiku Fails Mid-Task
```bash
# Check mail for partial results
gt mail inbox adam/polecats/<name>

# Restart with same bead
gt session restart adam/<polecat>
# Note: Will revert to default agent - use --agent on new sling instead
```

### Phase 2 Missing Phase 1 Data
```bash
# Query mail archive
gt mail search "Phase1 Complete: ${MODULE}"

# Or query beads directly
bd children ${PARENT_ID} --json | jq '.[] | select(.labels | contains(["phase1"]))'
```

## Summary

| Component | Model | Task Type | Duration |
|-----------|-------|-----------|----------|
| Phase 1 polecats | **Sonnet** | Mechanical scans | ~1-2min |
| Phase 2 polecats | Sonnet | Judgment calls | ~2-3min |
| Main thread | Opus | Cross-cutting, escalations | As needed |

**Key Principles:**
1. **Bounded tasks** - each bead is completable by its target model
2. **Mail for handoffs** - structured JSON between tiers
3. **No molecules** - molecules bundle phases; we want separation
4. **Explicit model selection** - `--agent` flag or `role_agents.polecat`
5. **Sonnet minimum** - Haiku fails as autonomous polecat (use Task tool for haiku)
