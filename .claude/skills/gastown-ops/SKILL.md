---
id: gastown-ops-skill
title: Gastown Operations Skill
created: 2026-02-24T00:00:00
updated: 2026-02-24T00:00:00
project: dotfiles
scope: ai
type: reference
status: active
publish: false
tags:
  - gastown
  - orchestration
  - agents
  - polecats
aliases:
  - gastown
  - gt
  - orchestration
  - multi-agent
related:
  - beads-ops
---

# Gastown Operations Skill

Comprehensive reference for `gt` CLI operations - multi-agent orchestration, rigs, polecats, formulas, and inter-agent communication.

## Activation Triggers

- "gastown"
- "gt"
- "orchestrate"
- "polecat"
- "rig"
- "formula"
- "sling"
- "multi-agent"
- "spawn agent"

## Core Concepts

### Architecture

```
Workspace (gt init)
├── .beads/formulas/          # Workflow definitions
├── .dolt-data/               # Dolt databases
└── rigs/
    └── <rig-name>/
        ├── config.json       # Rig configuration
        ├── mayor/            # Coordinator agent
        ├── witness/          # Watcher agent
        ├── refinery/         # Processing agent
        ├── polecats/         # Worker agents (spawned)
        └── crew/             # Permanent workers
```

### Key Components

| Component | Purpose |
|-----------|---------|
| **Rig** | Workspace for agents, contains all agent types |
| **Mayor** | Coordinator, manages work distribution |
| **Witness** | Watches for events, triggers workflows |
| **Refinery** | Processes completed work, handles merges |
| **Polecat** | Ephemeral worker agent, spawned for tasks |
| **Crew** | Permanent worker agents |
| **Convoy** | Batch of related work items |
| **Formula** | Reusable workflow definition |

## Prerequisites

**Required dependencies:**
```bash
brew install tmux    # Required for witness/refinery sessions
```

## Initialization

### Create Workspace

```bash
# Initialize gastown in current directory
gt init

# This creates:
# - .dolt-data/ directory
# - Registers workspace
```

### Add a Rig

```bash
# Add rig to workspace
gt rig add <rig-name>

# Initialize rig's Dolt database
gt dolt init-rig <rig-name>

# Start Dolt server
gt dolt start

# Boot rig agents
gt rig boot <rig-name>
```

## Rig Management

### Lifecycle Commands

```bash
# List all rigs
gt rig list

# Show rig status
gt rig status <rig-name>

# Boot witness + refinery
gt rig boot <rig-name>

# Start rig (resume operations)
gt rig start <rig-name>

# Stop rig
gt rig stop <rig-name>

# Restart rig
gt rig restart <rig-name>

# Shutdown gracefully
gt rig shutdown <rig-name>

# Park (stops, daemon won't restart)
gt rig park <rig-name>
gt rig unpark <rig-name>

# Dock (global persistent shutdown)
gt rig dock <rig-name>
gt rig undock <rig-name>
```

### Configuration

```bash
# View rig config
gt rig config show <rig-name>

# Set config value
gt rig config set <rig-name> <key>=<value>

# Unset config
gt rig config unset <rig-name> <key>
```

## Dolt Server Management

Gastown uses Dolt for distributed database functionality.

```bash
# Initialize rig database
gt dolt init-rig <rig-name>

# Start server (required for most operations)
gt dolt start

# Stop server
gt dolt stop

# Server details shown on start:
#   Port: 3307
#   Connection: root@tcp(127.0.0.1:3307)/
```

## Formulas & Molecules

### The MEOW Workflow

Gastown uses a chemistry-inspired workflow (MEOW = Molecules, Elements, Operators, Wisps):

```
Formula (.formula.toml)
    ↓ bd cook --persist
Proto (template bead in DB)
    ↓ bd mol pour / bd mol wisp
Mol (persistent) or Wisp (ephemeral)
    ↓ gt sling
Running work on polecat
```

### Creating and Running Formulas

```bash
# 1. List available formulas
bd formula list

# 2. Cook formula into a proto (REQUIRED before pour/wisp)
bd cook <formula-name> --persist

# 3a. Pour proto into persistent molecule
bd mol pour <proto-name> --var key=value

# 3b. OR create ephemeral wisp
bd mol wisp <proto-name> --var key=value

# 4. Sling molecule to polecat
gt sling <mol-id> <rig> --create --hook-raw-bead
```

**IMPORTANT**: Use `--hook-raw-bead` to skip the default `mol-polecat-work` formula which may not be available.

### Formula Location

Search paths (in order):
1. `<rig>/.beads/formulas/` - Rig-specific
2. `.beads/formulas/` - Workspace
3. `~/.beads/formulas/` - User global

### Formula File Format

File naming: `<name>.formula.toml`

```toml
# Formula header
description = """Multi-line description"""
formula = "formula-name"
version = 1

# Variables
[vars]
[vars.module]
description = "Module path"
required = true

[vars.skip_step]
description = "Skip optional step"
default = "false"

# Steps (array syntax - IMPORTANT!)
[[steps]]
id = "step1"
title = "First Step"
description = """
Instructions for this step.
"""

[[steps]]
id = "step2"
title = "Second Step"
needs = ["step1"]    # Dependencies
description = """
This runs after step1.
"""
```

### Formula Commands

```bash
# List available formulas
gt formula list

# Show formula details
gt formula show <formula-name>

# Create new formula template
gt formula create <name>

# Run formula (limited use)
gt formula run <name> --rig <rig>
```

## Slinging Work

The primary command for assigning work to agents.

### Basic Sling

```bash
# Sling issue to rig (auto-spawns polecat)
gt sling <bead-id> <rig-name> --create

# Sling formula with variables
gt sling <formula-name> \
  --var module=bash \
  --var parent=dotfiles-pmz.10 \
  <rig-name> --create
```

### Sling Flags

```bash
--create              # Create polecat if missing
--force               # Ignore unread mail
--account <handle>    # Use specific Claude account
--agent <runtime>     # Override agent (claude, gemini, codex)
--base-branch <name>  # Override base branch for worktree
--merge <strategy>    # direct | mr | local
--no-boot             # Skip rig boot after spawn
--no-convoy           # Skip auto-convoy creation
--no-merge            # Keep on feature branch
--args "instructions" # Natural language instructions
--message "context"   # Context message
--dry-run             # Preview without executing
```

### Target Resolution

```bash
gt sling issue-id                    # Self
gt sling issue-id crew               # Crew worker
gt sling issue-id <rig>              # Auto-spawn polecat
gt sling issue-id <rig>/<polecat>    # Specific polecat
gt sling issue-id mayor              # Mayor agent
```

## Inter-Agent Communication (Mail)

Agents communicate via mail for handoffs and escalations.

```bash
# Send mail to agent
gt mail send <rig>/<agent> \
  --subject "Subject line" \
  --body "Message body"

# Send to human (escalation)
gt mail send --human \
  --subject "Need review" \
  --body "Details..."

# List mail
gt mail list

# Read specific message
gt mail read <message-id>

# Watch mail in real-time
gt mail watch
gt mail watch <rig>/     # Watch specific inbox
```

## Convoy Management

Convoys track batches of related work.

```bash
# List convoys
gt convoy list

# Show convoy details
gt convoy show <convoy-id>
```

## Monitoring

```bash
# Recent agent activity
gt trail

# Ready work across workspace
gt ready

# Polecat status
gt polecat list <rig>

# Session management
gt session status <rig>/<polecat>    # Show session state
gt session capture <rig>/<polecat>   # Capture recent output
gt session capture <rig>/<polecat> -n 100  # Last 100 lines
gt session at <rig>/<polecat>        # Attach to session (interactive)
gt session restart <rig>/<polecat>   # Restart stopped session
gt session stop <rig>/<polecat>      # Stop running session

# Check mail
gt mail inbox                        # Your inbox
gt mail inbox <rig>/<agent>          # Agent's inbox
```

### Monitoring a Module Review

```bash
# Watch polecat work in real-time
gt session capture adam/quartz -n 50

# Check issues created under parent
bd children <parent-id>

# Check molecule progress
bd mol show <mol-id>
```

## Troubleshooting

### "executable file not found: tmux"

```bash
brew install tmux
```

### "Dolt server unreachable at 127.0.0.1:3307"

```bash
# Start Dolt server
gt dolt start

# If "no databases found":
gt dolt init-rig <rig-name>
gt dolt start
```

### "database not initialized: issue_prefix config is missing"

The rig's beads database needs initialization:

```bash
cd /path/to/rig/mayor/rig
bd init --prefix <prefix>
bd config set issue-prefix <prefix>
bd doctor --fix --yes
```

### "database not found: adam" (or rig name)

Gastown needs a Dolt database matching the rig name:

```bash
# Check existing databases
gt dolt status

# Initialize rig-named database
gt dolt init-rig <rig-name>

# Verify
gt dolt status  # Should show database: <rig-name>
```

**Note**: The database name must match the rig name exactly. `beads_<prefix>` databases are for beads, not gastown rig operations.

### "formula not found"

Formulas must be in the correct location relative to the rig:

```bash
# Check formula search paths
gt formula list

# Copy formula to rig's formula directory
mkdir -p <rig>/.beads/formulas/
cp .beads/formulas/<name>.formula.toml <rig>/.beads/formulas/
```

### "parsing formula: open ... no such file"

Formula path resolution issue when slinging formulas to polecats.

**Root Cause (v0.7.0):**
1. Polecat worktrees are created at `polecats/<name>/<rig-name>/` (nested under rig name)
2. Gastown looks for formulas at `<polecat-dir>/<rig-name>/<formula-name>`
3. This creates a path mismatch when rig name matches a repo directory

**Example:**
- Rig name: `adam`
- Polecat worktree: `polecats/obsidian/adam/` (contains full repo)
- Gastown looks for: `polecats/obsidian/adam/module-review`
- Actual location: `polecats/obsidian/adam/adam/module-review` (if formula at `adam/` in repo)

**Partial Fix (gets past path issue):**
1. Place formula at repo root (not in subdirectory)
2. Convert to JSON format (TOML fails with "invalid character '#'")
3. Push to remote and sync rig's `.repo.git`

```bash
# Convert formula to JSON
gt formula show <name> --json > <name>

# Sync rig's repo
git push origin main
git -C <rig>/.repo.git fetch origin main
git -C <rig>/.repo.git update-ref refs/heads/main origin/main
```

**Next Issue:** After cooking, "proto not found" error during wisp creation.

**Workaround**: Use general-purpose agent via Task tool instead of gastown sling for formula-like workflows.

### "proto not found: <formula-name>"

Occurs when trying to pour/wisp a formula that hasn't been cooked into a proto.

**Fix**: Cook the formula first:
```bash
bd cook <formula-name> --persist
bd mol pour <formula-name> --var key=value
```

### "mol-polecat-work: no such file or directory"

When slinging work to polecats, gastown auto-applies `mol-polecat-work` formula by default. If this formula isn't available, the sling fails.

**Fix**: Use `--hook-raw-bead` to skip the default formula:
```bash
gt sling <bead-id> <rig> --create --hook-raw-bead
```

Or create the `mol-polecat-work` formula in `.beads/formulas/`.

### Witness/Refinery Won't Start

```bash
# Check tmux sessions
tmux list-sessions

# Kill stale sessions if needed
tmux kill-session -t <session-name>

# Reboot rig
gt rig boot <rig-name>
```

### "polecat has unread mail"

```bash
# Force sling anyway
gt sling <issue> <rig> --force

# Or read the mail first
gt mail list
gt mail read <message-id>
```

## Directory Structure Deep Dive

### Rig Directory

```
<rig>/
├── .beads/
│   └── redirect           # Points to actual beads DB
├── .gitignore
├── .repo.git/             # Git worktree
├── config.json            # Rig metadata
├── crew/                  # Permanent workers
├── mayor/
│   └── rig/
│       └── .beads/        # Mayor's beads DB
│           ├── config.yaml
│           ├── dolt/
│           └── issues.jsonl
├── polecats/
│   └── .claude/           # Shared polecat config
├── refinery/
│   └── rig/
│       └── .beads/        # Refinery's beads
├── settings/
└── witness/
    └── rig/
        └── .beads/        # Witness's beads
```

### config.json

```json
{
  "type": "rig",
  "version": 1,
  "name": "rig-name",
  "git_url": "git@github.com:user/repo.git",
  "default_branch": "main",
  "created_at": "2026-02-24T00:00:00Z",
  "beads": {
    "prefix": "project"
  }
}
```

## Formula Step Syntax

**IMPORTANT**: Use array syntax `[[steps]]`, not table syntax `[steps.name]`

```toml
# CORRECT
[[steps]]
id = "step1"
title = "Step Title"
description = "..."

[[steps]]
id = "step2"
needs = ["step1"]

# WRONG - will not parse
[steps.step1]
title = "Step Title"
```

## Integration with Claude Code

When using gastown with Claude Code Task tool:

```bash
# Gastown formula workflows work best with general-purpose agent
Task(
  subagent_type="general-purpose",
  model="haiku",  # or sonnet for judgment
  prompt="Follow workflow steps..."
)
```

The Task tool can execute formula-like workflows without the formula path resolution issues of `gt sling`.

## Best Practices

1. **Always start Dolt server** before any sling/formula operations
2. **Initialize rig beads** with correct prefix before spawning polecats
3. **Use `--create` flag** when slinging to rigs (auto-spawns polecat)
4. **Check `gt formula list`** from correct directory (formula discovery is path-relative)
5. **Use mail for escalations** - human escalation via `gt mail send --human`
6. **Monitor with `gt trail`** to see recent agent activity
7. **Use convoys** for batch operations to track progress
8. **Keep tmux running** - witness/refinery require tmux sessions

## Model Selection

Gastown does **not** enforce model selection per formula phase. The agent runtime determines the model.

### Agent Configuration Commands

```bash
# List all agents (built-in + custom)
gt config agent list

# Get agent details
gt config agent get claude
# Output: Type: built-in, Command: claude, Args: --dangerously-skip-permissions

# Check/set default agent
gt config default-agent              # Show current
gt config default-agent claude-haiku # Set default

# Get/set config values
gt config get default_agent
gt config set default_agent claude-sonnet
```

### Creating Custom Model-Specific Agents

```bash
# Create agents for specific models
gt config agent set claude-haiku "claude --dangerously-skip-permissions --model haiku"
gt config agent set claude-sonnet "claude --dangerously-skip-permissions --model sonnet"
gt config agent set claude-opus "claude --dangerously-skip-permissions --model opus"

# Remove custom agent
gt config agent remove claude-haiku
```

### Using Custom Agents When Slinging

```bash
# Use specific agent for a sling
gt sling <bead> <rig> --agent claude-haiku --create

# Or set default for all operations
gt config default-agent claude-haiku
gt sling <bead> <rig> --create  # Uses haiku
```

**Key insight**: Formula descriptions mentioning "haiku for Phase 1, sonnet for Phase 2" are **documentation guidance**, not enforcement.

**Monitoring**: Use `gt session capture <rig>/<polecat>` to see which model is active in the polecat's Claude header (e.g., "Opus 4.5 · Claude Max").

### Multi-Model Workflow Limitations (Tested)

**Known issues when using smaller models (haiku) for autonomous workflows:**
1. **Haiku may fail complex workflows** - exits early without completing multi-step tasks
2. **Session restart resets agent** - `--agent` flag only applies to initial spawn; `gt session restart` reverts to default agent
3. **No native multi-model support** - cannot specify different models per molecule phase

**Workaround for multi-model workflows:**
```bash
# Manual phase handoff (not automated)
# 1. Sling Phase 1 step to haiku polecat
gt sling <phase1-step-id> <rig> --agent claude-haiku --create

# 2. Monitor completion
gt session capture <rig>/<polecat>

# 3. Manually sling Phase 2 to sonnet polecat
gt sling <phase2-step-id> <rig> --agent claude-sonnet --create
```

**Recommendation**: Use Opus or Sonnet for complex autonomous workflows. Haiku is better suited for simple, single-step tasks.

## Common Workflows

### Single Module Review (Tested Working)

```bash
# 1. Start Dolt
gt dolt start

# 2. Create parent issue hierarchy
bd create "Module Coverage Review" --type epic -l "review" --silent
# Returns: dotfiles-adam-xyz

bd create "Review: bash module" --parent dotfiles-adam-xyz -l "review" --silent
# Returns: dotfiles-adam-xyz.1

# 3. Cook formula into proto (one-time)
bd cook module-review --persist

# 4. Pour molecule with variables
bd mol pour module-review --var module=bash --var parent=dotfiles-adam-xyz.1
# Returns: dotfiles-adam-mol-abc

# 5. Sling molecule to polecat (--hook-raw-bead skips default formula)
gt sling dotfiles-adam-mol-abc adam --create --hook-raw-bead

# 6. Monitor progress
gt session capture adam/<polecat-name> -n 50
bd children dotfiles-adam-xyz.1
```

**Result:** Polecat executes the two-phase workflow autonomously:
- Phase 1: Mechanical scan, HIGH confidence issues
- Phase 2 Gate: Decides whether to escalate
- Phase 2: Judgment calls on deferred findings
- Complete: Verifies and runs `gt done`

### Batch Module Reviews

```bash
gt sling module-review --var module=git --var parent=dotfiles-pmz.61 \
         module-review --var module=zsh --var parent=dotfiles-pmz.11 \
         module-review --var module=docker --var parent=dotfiles-pmz.50 \
         <rig> --max-concurrent 3
```

### Manual Polecat Interaction

```bash
# Spawn polecat
gt sling <issue> <rig> --create

# Send instructions
gt mail send <rig>/polecats/<name> \
  --subject "Additional context" \
  --body "Focus on security aspects"

# Watch for completion
gt mail watch <rig>/
```
