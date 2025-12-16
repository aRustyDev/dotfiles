---
id: 9b0c1d2e-3f4a-5b6c-7d8e-9f0a1b2c3d4e
title: Create Claude Code Hook
created: 2025-12-15T00:00:00
updated: 2025-12-15T00:00:00
project: dotfiles
scope: ai
type: reference
status: active
publish: false
tags:
  - claude
  - hooks
  - automation
aliases:
  - Create Claude Hook
  - Add Claude Hook
related:
  - ref: "[[create-pre-commit-hook.md]]"
    description: Similar workflow for pre-commit hooks
---

# Create Claude Code Hook

Create a new Claude Code hook and contribute it to the aRustyDev/ai repository under the `hooks/` directory.

## Arguments

`$ARGUMENTS` should be one of:
- A hook description: `"file-watcher PreToolUse - Log all file operations to a JSON file"`
- A hook event and name: `"PostToolUse format-on-save"`
- A hook purpose: `"block dangerous git commands"`

## Overview

This command supports two workflows:

### Workflow A: Existing Local Hook (PR Only)
If a hook already exists in `.claude/hooks/` or `~/.claude/hooks/`:
1. Detect existing hook script
2. Copy hook to aRustyDev/ai repository
3. Create tests and documentation
4. Open a PR to contribute the hook

### Workflow B: New Hook Development
If creating a new hook from scratch:
1. Creating a tracking issue on GitHub
2. Local MVP development on a feature branch
3. Writing the hook script (shell or Python)
4. Writing tests
5. Opening a PR when MVP is complete
6. Adding settings.json configuration

## Repository Information

- **Repository**: https://github.com/aRustyDev/ai
- **Hooks Directory**: `hooks/`
- **Scripts Directory**: `hooks/.scripts/`
- **Config Directory**: `hooks/.config/`
- **Tests Directory**: `hooks/.tests/`
- **Local Path**: `$AI_HOOKS` or `$XDG_DATA_HOME/ai/hooks`

## Hook Events Reference

| Event | Purpose | Can Block | Supports Matchers |
|-------|---------|-----------|-------------------|
| `PreToolUse` | Before tool calls (Bash, Read, Write, Edit, etc.) | Yes (exit 2) | Yes (tool name) |
| `PostToolUse` | After tool completes successfully | No | Yes (tool name) |
| `UserPromptSubmit` | User submits prompt, before Claude processes | Yes (exit 2) | No |
| `Notification` | When Claude Code sends notifications | No | Yes (notification_type) |
| `Stop` | When main Claude Code agent finishes | Yes (exit 2) | No |
| `SubagentStop` | When a subagent task completes | Yes (exit 2) | No |
| `PreCompact` | Before context compaction | No | Yes (manual/auto) |
| `SessionStart` | When session starts or resumes | No | Yes (startup/resume) |
| `SessionEnd` | When session ends | No | No |
| `PermissionRequest` | When permission dialog is shown | Yes (exit 2) | Yes |

## Execution Steps

### Phase 0: Detect Existing Hook

**IMPORTANT**: Before starting, check if the hook already exists locally.

```bash
# Check common hook locations
HOOK_ID="<hook-id>"  # Extract from $ARGUMENTS

LOCAL_HOOKS=(
    ".claude/hooks/${HOOK_ID}.sh"
    ".claude/hooks/${HOOK_ID}.py"
    ".claude/hooks/${HOOK_ID}.ts"
    ".claude/hooks/index.ts"  # TypeScript (johnlindquist/claude-hooks style)
    "${HOME}/.claude/hooks/${HOOK_ID}.sh"
    "${HOME}/.claude/hooks/${HOOK_ID}.py"
    "${HOME}/.claude/hooks/${HOOK_ID}.ts"
    "${HOME}/.claude/hooks/index.ts"
    "${CLAUDE_PROJECT_DIR}/.claude/hooks/${HOOK_ID}.sh"
    "${CLAUDE_PROJECT_DIR}/.claude/hooks/${HOOK_ID}.py"
    "${CLAUDE_PROJECT_DIR}/.claude/hooks/${HOOK_ID}.ts"
    "${CLAUDE_PROJECT_DIR}/.claude/hooks/index.ts"
)

EXISTING_HOOK=""
for hook_path in "${LOCAL_HOOKS[@]}"; do
    if [ -f "$hook_path" ]; then
        EXISTING_HOOK="$hook_path"
        echo "Found existing hook: $EXISTING_HOOK"
        break
    fi
done

if [ -n "$EXISTING_HOOK" ]; then
    echo "Using Workflow A: Existing Local Hook (PR Only)"
    # Skip to Phase 0-A
else
    echo "Using Workflow B: New Hook Development"
    # Continue with Phase 0-B
fi
```

---

# Workflow A: Existing Local Hook (PR Only)

Use this workflow when a hook already exists in `.claude/hooks/` and you want to contribute it to aRustyDev/ai.

### Phase 0-A: Analyze Existing Hook

```bash
# Extract hook metadata from the existing script
EXISTING_HOOK="<path-to-existing-hook>"

# Determine language from extension
if [[ "$EXISTING_HOOK" == *.py ]]; then
    LANGUAGE="python"
    EXT="py"
elif [[ "$EXISTING_HOOK" == *.ts ]]; then
    LANGUAGE="typescript"
    EXT="ts"
else
    LANGUAGE="shell"
    EXT="sh"
fi

# Extract hook details from script header/docstring
# Look for: Event type, Matcher pattern, Description
# Parse from comments like:
#   # Event: PreToolUse
#   # Matcher: Bash|Write
#   # Description: ...
```

### Phase 1-A: Setup Repository

```bash
# Determine aRustyDev/ai repository path
if [ -n "$AI_HOOKS" ]; then
    HOOKS_REPO="$AI_HOOKS"
elif [ -n "$XDG_DATA_HOME" ]; then
    HOOKS_REPO="$XDG_DATA_HOME/ai"
else
    HOOKS_REPO="$HOME/.local/share/ai"
fi

# Clone if not exists
if [ ! -d "$HOOKS_REPO" ]; then
    git clone https://github.com/aRustyDev/ai.git "$HOOKS_REPO"
fi

cd "$HOOKS_REPO"
git fetch origin
git checkout main
git pull origin main

# Create feature branch
BRANCH_NAME="feat/hook-<hook-id>"
git checkout -b "$BRANCH_NAME"
```

### Phase 2-A: Copy Hook to Repository

```bash
# Copy existing hook to repository
cp "$EXISTING_HOOK" "$HOOKS_REPO/hooks/.scripts/<hook-id>.$EXT"
chmod +x "$HOOKS_REPO/hooks/.scripts/<hook-id>.$EXT"

# If hook has associated config, copy that too
if [ -f "$(dirname $EXISTING_HOOK)/../.config/<hook-id>.json" ]; then
    cp "$(dirname $EXISTING_HOOK)/../.config/<hook-id>.json" "$HOOKS_REPO/hooks/.config/"
fi
```

### Phase 3-A: Create Tests

Create `hooks/.tests/test_<hook-id>.bats` based on the hook's functionality.
Analyze the existing hook to determine:
- What tools it targets
- What patterns it blocks (if blocking hook)
- What modifications it makes (if modifying hook)

Generate appropriate test cases for each scenario.

### Phase 4-A: Update Documentation

1. Add entry to `hooks/settings.json.template`
2. Add section to `hooks/README.md`

### Phase 5-A: Create Pull Request

```bash
cd "$HOOKS_REPO"

git add .
git commit -m "feat(hooks): add <hook-name> hook

Contribute existing hook from local .claude/hooks/ directory.

- Add <hook-id>.$EXT for <event-type> events
- Add test suite
- Update settings.json.template
- Document in README.md"

git push -u origin "$BRANCH_NAME"

gh pr create \
    --repo aRustyDev/ai \
    --title "feat(hooks): Add <hook-name> hook" \
    --body "$(cat <<EOF
## Summary

Contributing an existing Claude Code hook: **<hook-name>**

This hook was developed locally in \`.claude/hooks/\` and is now being contributed to the shared hooks repository.

<description>

## Hook Details

| Property | Value |
|----------|-------|
| **Event** | \`<event-type>\` |
| **Matcher** | \`<matcher-pattern>\` |
| **Language** | \`$LANGUAGE\` |
| **Blocking** | \`<yes\|no>\` |
| **Source** | Local \`.claude/hooks/\` |

## Changes

- \`hooks/.scripts/<hook-id>.$EXT\` - Hook implementation
- \`hooks/.tests/test_<hook-id>.bats\` - Test suite
- \`hooks/.config/<hook-id>.json\` - Configuration (if applicable)
- \`hooks/settings.json.template\` - Settings configuration
- \`hooks/README.md\` - Documentation

## Testing

\`\`\`bash
# Run tests
bats hooks/.tests/test_<hook-id>.bats

# Test manually
echo '{"tool_name": "<tool>", "tool_input": {...}}' | hooks/.scripts/<hook-id>.$EXT
\`\`\`

## Checklist

- [x] Hook implementation (from existing local hook)
- [x] Tests added
- [x] Settings configuration added
- [x] README documentation added
- [ ] CI passes

---

Generated with [Claude Code](https://claude.ai/claude-code)
EOF
)"

echo "PR created! Hook contributed from: $EXISTING_HOOK"
```

---

# Workflow B: New Hook Development

Use this workflow when creating a new hook from scratch.

### Phase 0-B: Setup & Validation

#### 0-B.1 Determine Local Repository Path

```bash
# Check for environment variable first
if [ -n "$AI_HOOKS" ]; then
  HOOKS_REPO="$AI_HOOKS"
elif [ -n "$XDG_DATA_HOME" ]; then
  HOOKS_REPO="$XDG_DATA_HOME/ai"
else
  HOOKS_REPO="$HOME/.local/share/ai"
fi

# Clone if not exists
if [ ! -d "$HOOKS_REPO" ]; then
  git clone https://github.com/aRustyDev/ai.git "$HOOKS_REPO"
fi

cd "$HOOKS_REPO"
git fetch origin
git checkout main
git pull origin main
```

#### 0-B.2 Parse Hook Details

From `$ARGUMENTS`, extract:
- **Hook ID**: kebab-case identifier (e.g., `file-watcher`, `security-scan`)
- **Hook Name**: Human-readable name (e.g., `File Watcher`, `Security Scanner`)
- **Event Type**: Claude Code hook event (PreToolUse, PostToolUse, etc.)
- **Language**: Implementation language (shell, python, or typescript)
- **Matcher**: Tool/event pattern to match (regex, e.g., `Bash|Write|Edit`)
- **Description**: Brief description of what the hook does
- **Blocking**: Whether hook can block execution (exit code 2)

### Phase 1-B: Create Tracking Issue

#### 1-B.1 Create Parent Issue

```bash
gh issue create \
  --repo aRustyDev/ai \
  --title "feat(hooks): Add <hook-name> hook" \
  --label "hooks,enhancement" \
  --body "$(cat <<'EOF'
## Overview

Add a new Claude Code hook: **<hook-name>**

## Description

<description>

## Hook Details

| Property | Value |
|----------|-------|
| **Event** | `<event-type>` |
| **Matcher** | `<matcher-pattern>` |
| **Language** | `<shell\|python\|typescript>` |
| **Blocking** | `<yes\|no>` |

## Implementation Plan

### Phase 1: Core Implementation
- [ ] Create hook script at `hooks/.scripts/<hook-id>.<ext>`
- [ ] Implement core functionality
- [ ] Handle stdin JSON input correctly
- [ ] Use appropriate exit codes (0=success, 2=block)
- [ ] Add logging to `logs/` directory

### Phase 2: Testing
- [ ] Create test file at `hooks/.tests/test_<hook-id>.bats`
- [ ] Test hook existence and executability
- [ ] Test success cases
- [ ] Test blocking cases (if applicable)
- [ ] Test edge cases

### Phase 3: Configuration
- [ ] Add entry to `hooks/settings.json.template`
- [ ] Update `hooks/README.md` with documentation
- [ ] Add configuration options to `hooks/.config/` (if needed)

### Phase 4: Integration
- [ ] Verify hook works with Claude Code
- [ ] Test in consumer project

## Acceptance Criteria

- [ ] Hook passes all tests
- [ ] Hook is documented in README
- [ ] Hook configuration added to settings.json.template
- [ ] Hook works in real Claude Code session
EOF
)"
```

#### 1-B.2 Store Issue Number

```bash
PARENT_ISSUE=$(gh issue list --repo aRustyDev/ai --search "feat(hooks): Add <hook-name>" --json number -q '.[0].number')
echo "Created parent issue: #$PARENT_ISSUE"
```

### Phase 2-B: Create Feature Branch

```bash
cd "$HOOKS_REPO"
git checkout main
git pull origin main

# Create feature branch
BRANCH_NAME="feat/hook-<hook-id>"
git checkout -b "$BRANCH_NAME"
```

### Phase 3-B: Implement Hook

#### 3-B.1 Hook Input Format

All hooks receive JSON via stdin with this structure:

```json
{
  "session_id": "abc123",
  "transcript_path": "/path/to/transcript.jsonl",
  "cwd": "/current/working/dir",
  "permission_mode": "default|plan|acceptEdits|bypassPermissions",
  "hook_event_name": "PreToolUse|PostToolUse|etc",
  "tool_name": "Bash|Write|Read|etc",
  "tool_input": {
    "command": "...",
    "file_path": "...",
    "content": "..."
  }
}
```

#### 3-B.2 Hook Output Format

**Exit Codes:**
- `0` - Success (stdout shown in verbose mode)
- `2` - Block execution (stderr fed to Claude as feedback)
- Other - Non-blocking error (shown in verbose mode only)

**Advanced JSON Output** (exit code 0 only):
```json
{
  "continue": true,
  "stopReason": "Optional stop message",
  "suppressOutput": false,
  "systemMessage": "Optional warning to user",
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow|deny|ask",
    "permissionDecisionReason": "Explanation",
    "updatedInput": { }
  }
}
```

#### 3-B.3 Shell Hook Template

Create `hooks/.scripts/<hook-id>.sh`:

```bash
#!/usr/bin/env bash
# =============================================================================
# <Hook Name> - Claude Code Hook
# =============================================================================
# Description: <description>
#
# Event: <event-type>
# Matcher: <matcher-pattern>
#
# Exit Codes:
#   0 - Success (allow tool execution)
#   2 - Block (prevent tool execution, stderr sent to Claude)
#
# Input: JSON via stdin (see Claude Code hooks documentation)
# Output: JSON to stdout (optional), errors to stderr
#
# Environment Variables:
#   CLAUDE_PROJECT_DIR - Project root directory
#   CLAUDE_CODE_REMOTE - "true" if running remotely
# =============================================================================

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${CLAUDE_PROJECT_DIR:-.}/.claude/logs"
LOG_FILE="$LOG_DIR/<hook-id>.log"

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Logging function
log() {
    echo "[$(date -Iseconds)] $*" >> "$LOG_FILE"
}

# Read JSON input from stdin
INPUT=$(cat)

# Parse input using jq
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
TOOL_INPUT=$(echo "$INPUT" | jq -r '.tool_input // {}')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

log "Hook triggered: tool=$TOOL_NAME session=$SESSION_ID"

# =============================================================================
# Hook Logic
# =============================================================================

# Example: Check for dangerous patterns
check_dangerous_patterns() {
    local input="$1"

    # Add your pattern matching logic here
    # Return 0 if safe, 1 if dangerous

    return 0
}

# Example: Modify tool input
modify_input() {
    local input="$1"

    # Add your input modification logic here
    # Echo modified JSON to stdout

    echo "$input"
}

# =============================================================================
# Main Logic
# =============================================================================

main() {
    # Skip if not matching target tool (safety check)
    case "$TOOL_NAME" in
        <target-tools>)
            # Process matching tools
            ;;
        *)
            # Pass through non-matching tools
            exit 0
            ;;
    esac

    # Check for dangerous patterns
    if ! check_dangerous_patterns "$TOOL_INPUT"; then
        log "BLOCKED: Dangerous pattern detected"
        echo "BLOCKED: <reason>" >&2
        exit 2
    fi

    # Optional: Output modified input
    # echo '{"hookSpecificOutput": {"updatedInput": {...}}}'

    log "Hook completed successfully"
    exit 0
}

# Handle errors gracefully
trap 'log "Error on line $LINENO"; exit 0' ERR

main "$@"
```

#### 3-B.4 Python Hook Template

Create `hooks/.scripts/<hook-id>.py`:

```python
#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.8"
# dependencies = []
# ///
"""
<Hook Name> - Claude Code Hook

Description: <description>

Event: <event-type>
Matcher: <matcher-pattern>

Exit Codes:
    0 - Success (allow tool execution)
    2 - Block (prevent tool execution, stderr sent to Claude)

Input: JSON via stdin (see Claude Code hooks documentation)
Output: JSON to stdout (optional), errors to stderr
"""

import json
import sys
import re
from pathlib import Path
from datetime import datetime
from typing import Any, Optional


def get_log_path() -> Path:
    """Get the log file path."""
    import os
    project_dir = os.environ.get('CLAUDE_PROJECT_DIR', '.')
    log_dir = Path(project_dir) / '.claude' / 'logs'
    log_dir.mkdir(parents=True, exist_ok=True)
    return log_dir / '<hook-id>.log'


def log(message: str) -> None:
    """Log a message with timestamp."""
    timestamp = datetime.now().isoformat()
    with open(get_log_path(), 'a') as f:
        f.write(f"[{timestamp}] {message}\n")


def check_dangerous_patterns(tool_input: dict) -> tuple[bool, Optional[str]]:
    """
    Check for dangerous patterns in tool input.

    Returns:
        Tuple of (is_safe, reason_if_blocked)
    """
    # Add your pattern matching logic here
    # Example patterns:
    patterns = [
        # (pattern, description)
    ]

    for pattern, description in patterns:
        # Check pattern
        pass

    return True, None


def modify_input(tool_input: dict) -> dict:
    """
    Optionally modify tool input before execution.

    Returns:
        Modified tool input dictionary
    """
    # Add your modification logic here
    return tool_input


def main() -> int:
    """Main entry point."""
    try:
        # Read JSON input from stdin
        input_data = json.load(sys.stdin)

        tool_name = input_data.get('tool_name', '')
        tool_input = input_data.get('tool_input', {})
        session_id = input_data.get('session_id', '')
        cwd = input_data.get('cwd', '')

        log(f"Hook triggered: tool={tool_name} session={session_id}")

        # Skip if not matching target tool
        target_tools = ['<tool1>', '<tool2>']  # Update with your targets
        if tool_name not in target_tools:
            return 0

        # Check for dangerous patterns
        is_safe, reason = check_dangerous_patterns(tool_input)
        if not is_safe:
            log(f"BLOCKED: {reason}")
            print(f"BLOCKED: {reason}", file=sys.stderr)
            return 2

        # Optional: Modify input and output JSON
        # modified = modify_input(tool_input)
        # output = {
        #     "hookSpecificOutput": {
        #         "hookEventName": "PreToolUse",
        #         "updatedInput": modified
        #     }
        # }
        # print(json.dumps(output))

        log("Hook completed successfully")
        return 0

    except json.JSONDecodeError as e:
        log(f"JSON decode error: {e}")
        return 0  # Don't block on parse errors
    except Exception as e:
        log(f"Error: {e}")
        return 0  # Don't block on unexpected errors


if __name__ == '__main__':
    sys.exit(main())
```

#### 3-B.5 TypeScript Hook Template (using johnlindquist/claude-hooks)

For TypeScript-based hooks, use the [johnlindquist/claude-hooks](https://github.com/johnlindquist/claude-hooks) library which provides full type safety and a streamlined development experience.

**Prerequisites:**
- [Bun](https://bun.sh) runtime installed (`curl -fsSL https://bun.sh/install | bash`)

**Initial Setup (one-time per project):**

```bash
# Initialize claude-hooks in your project
npx claude-hooks

# This creates:
# .claude/
# ├── settings.json      # Auto-configured hook settings
# └── hooks/
#     ├── index.ts       # Main hook handlers (edit this)
#     ├── lib.ts         # Type definitions and utilities
#     └── session.ts     # Session tracking utilities
```

**Create or edit** `.claude/hooks/index.ts`:

```typescript
#!/usr/bin/env bun
// =============================================================================
// <Hook Name> - Claude Code Hook (TypeScript)
// =============================================================================
// Description: <description>
//
// Event: <event-type>
// Matcher: <matcher-pattern>
//
// Exit Codes:
//   0 - Success (allow tool execution)
//   2 - Block (prevent tool execution, stderr sent to Claude)
//
// Setup:
//   1. Install Bun: curl -fsSL https://bun.sh/install | bash
//   2. Run: npx claude-hooks (if not already initialized)
//   3. Edit this file with your hook logic
// =============================================================================

import type {
  PreToolUsePayload,
  PostToolUsePayload,
  UserPromptSubmitPayload,
  NotificationPayload,
  StopPayload,
  HookResponse,
} from "./lib";

import { log, getSessionInfo } from "./session";

// =============================================================================
// Type Definitions for Tool Inputs
// =============================================================================

interface WriteToolInput {
  file_path: string;
  content: string;
}

interface BashToolInput {
  command: string;
  timeout?: number;
}

interface EditToolInput {
  file_path: string;
  old_string: string;
  new_string: string;
}

interface ReadToolInput {
  file_path: string;
  offset?: number;
  limit?: number;
}

// =============================================================================
// Hook Configuration
// =============================================================================

const CONFIG = {
  // Add your configuration here
  blockedPatterns: [
    // Example: /rm\s+-rf\s+\//i,
  ],
  allowedPaths: [
    // Example: /^\/Users\/.*\/projects\//,
  ],
  logFile: ".claude/logs/<hook-id>.log",
};

// =============================================================================
// Helper Functions
// =============================================================================

function checkDangerousPatterns(input: string): { safe: boolean; reason?: string } {
  for (const pattern of CONFIG.blockedPatterns) {
    if (pattern.test(input)) {
      return { safe: false, reason: `Blocked pattern detected: ${pattern}` };
    }
  }
  return { safe: true };
}

// =============================================================================
// PreToolUse Hook Handler
// =============================================================================

async function preToolUse(payload: PreToolUsePayload): Promise<HookResponse> {
  const { tool_name, tool_input, session_id } = payload;

  log(`PreToolUse: ${tool_name}`, { session_id });

  // Example: Handle Write tool
  if (tool_name === "Write" && tool_input) {
    const { file_path, content } = tool_input as WriteToolInput;

    // Example: Block writes to sensitive paths
    if (file_path.includes(".env") || file_path.includes("secrets")) {
      return {
        action: "block",
        reason: "Cannot write to sensitive files (.env, secrets)",
      };
    }

    // Example: Modify input before execution
    // return {
    //   action: "continue",
    //   updatedInput: { file_path, content: content + "\n// Modified by hook" },
    // };
  }

  // Example: Handle Bash tool
  if (tool_name === "Bash" && tool_input) {
    const { command } = tool_input as BashToolInput;

    const check = checkDangerousPatterns(command);
    if (!check.safe) {
      return {
        action: "block",
        reason: check.reason!,
      };
    }
  }

  // Allow all other tools
  return { action: "continue" };
}

// =============================================================================
// PostToolUse Hook Handler
// =============================================================================

async function postToolUse(payload: PostToolUsePayload): Promise<HookResponse> {
  const { tool_name, tool_input, tool_output, session_id } = payload;

  log(`PostToolUse: ${tool_name}`, { session_id });

  // Example: Log file changes for audit trail
  if (tool_name === "Write" && tool_input) {
    const { file_path } = tool_input as WriteToolInput;
    log(`File written: ${file_path}`, { session_id, audit: true });
  }

  return { action: "continue" };
}

// =============================================================================
// UserPromptSubmit Hook Handler
// =============================================================================

async function userPromptSubmit(
  payload: UserPromptSubmitPayload
): Promise<HookResponse> {
  const { prompt, session_id } = payload;

  log(`UserPromptSubmit: ${prompt.slice(0, 50)}...`, { session_id });

  // Example: Block certain prompts
  // if (prompt.toLowerCase().includes("delete everything")) {
  //   return { action: "block", reason: "Potentially dangerous prompt detected" };
  // }

  return { action: "continue" };
}

// =============================================================================
// Notification Hook Handler
// =============================================================================

async function notification(payload: NotificationPayload): Promise<HookResponse> {
  const { notification_type, message, session_id } = payload;

  log(`Notification: ${notification_type}`, { session_id });

  // Example: Send to external service (Slack, Discord, etc.)
  // await sendSlackNotification(message);

  return { action: "continue" };
}

// =============================================================================
// Stop Hook Handler
// =============================================================================

async function stop(payload: StopPayload): Promise<HookResponse> {
  const { session_id, stop_reason } = payload;

  log(`Stop: ${stop_reason}`, { session_id });

  // Example: Generate session summary
  // await generateSessionSummary(session_id);

  return { action: "continue" };
}

// =============================================================================
// Main Entry Point
// =============================================================================

async function main() {
  try {
    const input = await Bun.stdin.text();
    const payload = JSON.parse(input);

    const { hook_event_name } = payload;

    let response: HookResponse;

    switch (hook_event_name) {
      case "PreToolUse":
        response = await preToolUse(payload as PreToolUsePayload);
        break;
      case "PostToolUse":
        response = await postToolUse(payload as PostToolUsePayload);
        break;
      case "UserPromptSubmit":
        response = await userPromptSubmit(payload as UserPromptSubmitPayload);
        break;
      case "Notification":
        response = await notification(payload as NotificationPayload);
        break;
      case "Stop":
        response = await stop(payload as StopPayload);
        break;
      default:
        response = { action: "continue" };
    }

    // Handle response
    if (response.action === "block") {
      console.error(`BLOCKED: ${response.reason || "Hook blocked execution"}`);
      process.exit(2);
    }

    // Output JSON for input modifications
    if (response.updatedInput) {
      console.log(
        JSON.stringify({
          hookSpecificOutput: {
            hookEventName: payload.hook_event_name,
            updatedInput: response.updatedInput,
          },
        })
      );
    }

    process.exit(0);
  } catch (error) {
    log(`Error: ${error}`, { error: true });
    process.exit(0); // Don't block on errors
  }
}

main();
```

**Type definitions** (`.claude/hooks/lib.ts` - auto-generated by npx claude-hooks):

```typescript
// Core payload types
export interface BasePayload {
  session_id: string;
  transcript_path: string;
  cwd: string;
  permission_mode: "default" | "plan" | "acceptEdits" | "bypassPermissions";
  hook_event_name: string;
}

export interface PreToolUsePayload extends BasePayload {
  hook_event_name: "PreToolUse";
  tool_name: string;
  tool_input?: Record<string, unknown>;
}

export interface PostToolUsePayload extends BasePayload {
  hook_event_name: "PostToolUse";
  tool_name: string;
  tool_input?: Record<string, unknown>;
  tool_output?: string;
}

export interface UserPromptSubmitPayload extends BasePayload {
  hook_event_name: "UserPromptSubmit";
  prompt: string;
}

export interface NotificationPayload extends BasePayload {
  hook_event_name: "Notification";
  notification_type: string;
  message: string;
}

export interface StopPayload extends BasePayload {
  hook_event_name: "Stop";
  stop_reason: string;
}

// Response types
export interface HookResponse {
  action: "continue" | "block";
  reason?: string;
  updatedInput?: Record<string, unknown>;
  systemMessage?: string;
}
```

#### 3-B.6 Make Executable

```bash
chmod +x hooks/.scripts/<hook-id>.<ext>
```

### Phase 4-B: Write Tests

Create `hooks/.tests/test_<hook-id>.bats`:

```bash
#!/usr/bin/env bats

# Test setup
setup() {
    HOOK_SCRIPT="$BATS_TEST_DIRNAME/../.scripts/<hook-id>.<ext>"
    TEST_DIR=$(mktemp -d)
    cd "$TEST_DIR"
}

teardown() {
    rm -rf "$TEST_DIR"
}

# =============================================================================
# Basic Tests
# =============================================================================

@test "hook exists and is executable" {
    [ -x "$HOOK_SCRIPT" ]
}

@test "hook handles empty input gracefully" {
    echo '{}' | run "$HOOK_SCRIPT"
    [ "$status" -eq 0 ]
}

@test "hook handles malformed JSON gracefully" {
    echo 'not json' | run "$HOOK_SCRIPT"
    [ "$status" -eq 0 ]
}

# =============================================================================
# Success Cases
# =============================================================================

@test "hook allows safe <tool> commands" {
    input='{"tool_name": "<tool>", "tool_input": {"<field>": "<safe-value>"}}'
    echo "$input" | run "$HOOK_SCRIPT"
    [ "$status" -eq 0 ]
}

@test "hook passes through non-matching tools" {
    input='{"tool_name": "Read", "tool_input": {"file_path": "/some/file"}}'
    echo "$input" | run "$HOOK_SCRIPT"
    [ "$status" -eq 0 ]
}

# =============================================================================
# Blocking Cases (if applicable)
# =============================================================================

@test "hook blocks dangerous <pattern>" {
    input='{"tool_name": "<tool>", "tool_input": {"<field>": "<dangerous-value>"}}'
    echo "$input" | run "$HOOK_SCRIPT"
    [ "$status" -eq 2 ]
    [[ "$output" == *"BLOCKED"* ]]
}

# =============================================================================
# Edge Cases
# =============================================================================

@test "hook handles missing tool_name" {
    input='{"tool_input": {}}'
    echo "$input" | run "$HOOK_SCRIPT"
    [ "$status" -eq 0 ]
}

@test "hook handles missing tool_input" {
    input='{"tool_name": "<tool>"}'
    echo "$input" | run "$HOOK_SCRIPT"
    [ "$status" -eq 0 ]
}
```

#### 4-B.2 TypeScript Test Template (for TypeScript hooks)

For TypeScript hooks using johnlindquist/claude-hooks, create `hooks/.tests/test_<hook-id>.test.ts`:

```typescript
import { describe, it, expect, beforeAll, afterAll } from "bun:test";
import { spawn } from "bun";
import { mkdtemp, rm } from "fs/promises";
import { join } from "path";
import { tmpdir } from "os";

const HOOK_SCRIPT = join(__dirname, "../.scripts/<hook-id>.ts");

describe("<Hook Name>", () => {
  let testDir: string;

  beforeAll(async () => {
    testDir = await mkdtemp(join(tmpdir(), "hook-test-"));
  });

  afterAll(async () => {
    await rm(testDir, { recursive: true, force: true });
  });

  // Helper to run hook with input
  async function runHook(input: object): Promise<{ exitCode: number; stdout: string; stderr: string }> {
    const proc = spawn(["bun", "run", HOOK_SCRIPT], {
      stdin: "pipe",
      stdout: "pipe",
      stderr: "pipe",
      cwd: testDir,
    });

    proc.stdin.write(JSON.stringify(input));
    proc.stdin.end();

    const [stdout, stderr] = await Promise.all([
      new Response(proc.stdout).text(),
      new Response(proc.stderr).text(),
    ]);

    const exitCode = await proc.exited;
    return { exitCode, stdout, stderr };
  }

  // ==========================================================================
  // Basic Tests
  // ==========================================================================

  it("handles empty input gracefully", async () => {
    const result = await runHook({});
    expect(result.exitCode).toBe(0);
  });

  it("handles malformed JSON gracefully", async () => {
    const proc = spawn(["bun", "run", HOOK_SCRIPT], {
      stdin: "pipe",
      stdout: "pipe",
      stderr: "pipe",
    });

    proc.stdin.write("not json");
    proc.stdin.end();

    const exitCode = await proc.exited;
    expect(exitCode).toBe(0); // Should not block on parse errors
  });

  // ==========================================================================
  // Success Cases
  // ==========================================================================

  it("allows safe commands", async () => {
    const result = await runHook({
      hook_event_name: "PreToolUse",
      tool_name: "<tool>",
      tool_input: { "<field>": "<safe-value>" },
      session_id: "test-session",
      cwd: testDir,
    });

    expect(result.exitCode).toBe(0);
  });

  it("passes through non-matching tools", async () => {
    const result = await runHook({
      hook_event_name: "PreToolUse",
      tool_name: "Read",
      tool_input: { file_path: "/some/file" },
      session_id: "test-session",
      cwd: testDir,
    });

    expect(result.exitCode).toBe(0);
  });

  // ==========================================================================
  // Blocking Cases (if applicable)
  // ==========================================================================

  it("blocks dangerous patterns", async () => {
    const result = await runHook({
      hook_event_name: "PreToolUse",
      tool_name: "<tool>",
      tool_input: { "<field>": "<dangerous-value>" },
      session_id: "test-session",
      cwd: testDir,
    });

    expect(result.exitCode).toBe(2);
    expect(result.stderr).toContain("BLOCKED");
  });

  // ==========================================================================
  // Edge Cases
  // ==========================================================================

  it("handles missing tool_name", async () => {
    const result = await runHook({
      hook_event_name: "PreToolUse",
      tool_input: {},
      session_id: "test-session",
      cwd: testDir,
    });

    expect(result.exitCode).toBe(0);
  });

  it("handles missing tool_input", async () => {
    const result = await runHook({
      hook_event_name: "PreToolUse",
      tool_name: "<tool>",
      session_id: "test-session",
      cwd: testDir,
    });

    expect(result.exitCode).toBe(0);
  });
});
```

Run TypeScript tests with:
```bash
bun test hooks/.tests/test_<hook-id>.test.ts
```

### Phase 5-B: Add Configuration

#### 5-B.1 Update settings.json.template

Add to `hooks/settings.json.template`:

```json
{
  "hooks": {
    "<EventType>": [
      {
        "matcher": "<matcher-pattern>",
        "hooks": [
          {
            "type": "command",
            "command": "${WORKSPACE}/.claude/hooks/<hook-id>.<ext>",
            "description": "<description>"
          }
        ]
      }
    ]
  }
}
```

#### 5-B.2 Add Config File (if needed)

Create `hooks/.config/<hook-id>.json`:

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "description": "<Hook Name> configuration",
  "patterns": [],
  "whitelist": [],
  "options": {}
}
```

### Phase 6-B: Update Documentation

Add section to `hooks/README.md`:

```markdown
### <N>. <Hook Name> (`<hook-id>.<ext>`)

**Purpose**: <description>

**Trigger**: `<EventType>` for `<matcher-pattern>`

**Features**:
- <Feature 1>
- <Feature 2>
- <Feature 3>

**Customization**:
- Edit `config/<hook-id>.json` to customize patterns
- <Other customization options>
```

### Phase 7-B: Create Pull Request

```bash
cd "$HOOKS_REPO"

# Ensure all changes are committed
git add .
git commit -m "feat(hooks): add <hook-name> hook

- Implement <hook-id>.<ext> for <event-type> events
- Add comprehensive test suite
- Update settings.json.template
- Document in README.md

Closes #$PARENT_ISSUE"

# Push branch
git push -u origin "$BRANCH_NAME"

# Create PR
gh pr create \
  --repo aRustyDev/ai \
  --title "feat(hooks): Add <hook-name> hook" \
  --body "$(cat <<EOF
## Summary

Adds a new Claude Code hook: **<hook-name>**

<description>

## Hook Details

| Property | Value |
|----------|-------|
| **Event** | \`<event-type>\` |
| **Matcher** | \`<matcher-pattern>\` |
| **Language** | \`<shell\|python\|typescript>\` |
| **Blocking** | \`<yes\|no>\` |
| **Runtime** | \`<bash\|python\|bun>\` |

## Changes

- \`hooks/.scripts/<hook-id>.<ext>\` - Hook implementation
- \`hooks/.tests/test_<hook-id>.<bats\|test.ts>\` - Test suite
- \`hooks/.config/<hook-id>.json\` - Configuration (if applicable)
- \`hooks/settings.json.template\` - Settings configuration
- \`hooks/README.md\` - Documentation

## Testing

\`\`\`bash
# Run tests (shell/python hooks)
bats hooks/.tests/test_<hook-id>.bats

# Run tests (TypeScript hooks)
bun test hooks/.tests/test_<hook-id>.test.ts

# Test manually
echo '{"tool_name": "<tool>", "tool_input": {...}}' | hooks/.scripts/<hook-id>.<ext>
\`\`\`

## Checklist

- [x] Hook implementation complete
- [x] Tests pass locally
- [x] Settings configuration added
- [x] README documentation added
- [ ] CI passes
- [ ] Tested in real Claude Code session

## Related Issues

Closes #$PARENT_ISSUE

---

Generated with [Claude Code](https://claude.ai/claude-code)
EOF
)"
```

### Phase 8-B: Consumer Installation

After PR is merged, install in consumer project:

```bash
# Copy hook script
cp hooks/.scripts/<hook-id>.<ext> ~/.claude/hooks/
chmod +x ~/.claude/hooks/<hook-id>.<ext>

# Update settings.json
# Add the hook configuration to ~/.claude/settings.json
```

## Output Summary

After completion, output:

```markdown
## Claude Code Hook Created: <hook-id>

### GitHub Issue

- **Issue**: #<issue-number>
- **URL**: https://github.com/aRustyDev/ai/issues/<issue-number>

### Pull Request

- **PR**: #<pr-number>
- **Branch**: `feat/hook-<hook-id>`
- **Status**: <status>

### Files Created

| File | Description |
|------|-------------|
| `hooks/.scripts/<hook-id>.<ext>` | Hook implementation |
| `hooks/.tests/test_<hook-id>.bats` | Test suite |
| `hooks/.config/<hook-id>.json` | Configuration (if applicable) |
| `hooks/settings.json.template` | Updated settings |
| `hooks/README.md` | Updated documentation |

### Hook Configuration

Add to your `~/.claude/settings.json` or `.claude/settings.json`:

\`\`\`json
{
  "hooks": {
    "<EventType>": [
      {
        "matcher": "<matcher-pattern>",
        "hooks": [
          {
            "type": "command",
            "command": "${WORKSPACE}/.claude/hooks/<hook-id>.<ext>"
          }
        ]
      }
    ]
  }
}
\`\`\`

### Local Testing

\`\`\`bash
# Run tests
bats hooks/.tests/test_<hook-id>.bats

# Test with sample input
echo '{"tool_name": "<tool>", "tool_input": {}}' | ./.claude/hooks/<hook-id>.<ext>

# View logs
tail -f .claude/logs/<hook-id>.log
\`\`\`
```

## Reference Files

- **Repository**: https://github.com/aRustyDev/ai
- **Hooks Documentation**: https://docs.anthropic.com/en/docs/claude-code/hooks
- **TypeScript Hooks Library**: https://github.com/johnlindquist/claude-hooks
- **Example Shell Hook**: `hooks/.scripts/mcp-security-scan.sh`
- **Example Python Hook**: `hooks/.scripts/pre_tool_use.py`
- **Settings Template**: `hooks/settings.json.template`
- **Tests Directory**: `hooks/.tests/`

## Examples

### Create a PreToolUse blocking hook (Shell)
```
/create-claude-hook "dangerous-command-blocker PreToolUse shell - Block dangerous shell commands like rm -rf /"
```

### Create a PostToolUse logging hook (Python)
```
/create-claude-hook "file-change-logger PostToolUse python - Log all file changes to a JSON audit trail"
```

### Create a Notification hook (TypeScript)
```
/create-claude-hook "slack-notifier Notification typescript - Send Slack messages when Claude needs input"
```

### Create a SessionStart hook (TypeScript with Bun)
```
/create-claude-hook "env-loader SessionStart typescript - Load project-specific environment variables"
```

### Create a TypeScript PreToolUse hook for security scanning
```
/create-claude-hook "security-scanner PreToolUse typescript - Scan file writes for potential secrets and block if found"
```

## TypeScript Hook Quick Start

For TypeScript hooks using johnlindquist/claude-hooks:

```bash
# 1. Install Bun (if not installed)
curl -fsSL https://bun.sh/install | bash

# 2. Initialize claude-hooks in your project
npx claude-hooks

# 3. Edit .claude/hooks/index.ts with your hook logic

# 4. Test your hook
echo '{"hook_event_name": "PreToolUse", "tool_name": "Write", "tool_input": {"file_path": "/test.txt"}}' | bun .claude/hooks/index.ts
```

TypeScript hooks provide:
- Full type safety with typed payloads
- Session tracking utilities
- Logging helpers
- Easy access to all hook events in one file
