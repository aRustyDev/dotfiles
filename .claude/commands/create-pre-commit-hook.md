---
id: 8a9b0c1d-2e3f-4a5b-6c7d-8e9f0a1b2c3d
title: Create Pre-Commit Hook
created: 2025-12-14T00:00:00
updated: 2025-12-14T00:00:00
project: dotfiles
scope: ai
type: reference
status: ✅ active
publish: false
tags:
  - claude
  - pre-commit
  - hooks
aliases:
  - Create Pre-Commit Hook
  - Add Pre-Commit Hook
related: []
---

# Create Pre-Commit Hook

Create a new pre-commit hook and contribute it to the aRustyDev/pre-commit-hooks repository.

## Arguments

`$ARGUMENTS` should be one of:
- A hook description: `"validate-toml - Validate TOML file syntax"`
- A hook name and language: `"check-json python"`
- A tool to wrap: `"shellcheck for shell scripts"`

## Overview

This command guides you through:
1. Creating a tracking issue on GitHub linked to the "Pre-Commit Hooks" project
2. Local MVP development on a feature branch
3. Writing tests using bats framework
4. Opening a PR when MVP is complete
5. Updating consumer `.pre-commit-config.yaml`

## Repository Information

- **Repository**: https://github.com/aRustyDev/pre-commit-hooks
- **GitHub Project**: https://github.com/users/aRustyDev/projects/21
- **Local Path**: `$PRE_COMMIT_HOOKS` or `$XDG_DATA_HOME/hooks/pre-commit`

## Execution Steps

### Phase 0: Setup & Validation

#### 0.1 Determine Local Repository Path

```bash
# Check for environment variable first
if [ -n "$PRE_COMMIT_HOOKS" ]; then
  HOOKS_REPO="$PRE_COMMIT_HOOKS"
elif [ -n "$XDG_DATA_HOME" ]; then
  HOOKS_REPO="$XDG_DATA_HOME/hooks/pre-commit"
else
  HOOKS_REPO="$HOME/.local/share/hooks/pre-commit"
fi

# Clone if not exists
if [ ! -d "$HOOKS_REPO" ]; then
  git clone https://github.com/aRustyDev/pre-commit-hooks.git "$HOOKS_REPO"
fi

cd "$HOOKS_REPO"
git fetch origin
git checkout main
git pull origin main
```

#### 0.2 Parse Hook Details

From `$ARGUMENTS`, extract:
- **Hook ID**: kebab-case identifier (e.g., `validate-toml`)
- **Hook Name**: Human-readable name (e.g., `Validate TOML Files`)
- **Language**: Implementation language (shell, python, golang, rust, node)
- **Description**: Brief description of what the hook does
- **File Types**: What file types this hook operates on

### Phase 1: Create Tracking Issue

#### 1.1 Create Parent Issue

Create a GitHub issue to track the overall work:

```bash
gh issue create \
  --repo aRustyDev/pre-commit-hooks \
  --title "feat: Add <hook-name> pre-commit hook" \
  --label "<language>,enhancement" \
  --project "Pre-Commit Hooks" \
  --body "$(cat <<'EOF'
## Overview

Add a new pre-commit hook: **<hook-name>**

## Description

<description>

## Implementation Plan

### Phase 1: Core Implementation
- [ ] Create hook script at `hooks/<language>/<hook-id>/` or `hooks/shell/<hook-id>.sh`
- [ ] Implement core functionality
- [ ] Handle missing dependencies gracefully
- [ ] Support common CLI arguments

### Phase 2: Testing
- [ ] Create bats test file at `tests/<category>/test_<hook-id>.bats`
- [ ] Test hook existence and executability
- [ ] Test success cases
- [ ] Test failure cases
- [ ] Test edge cases (empty input, malformed files)

### Phase 3: Documentation
- [ ] Add entry to `.pre-commit-hooks.yaml`
- [ ] Update README.md with hook documentation
- [ ] Add usage examples

### Phase 4: Integration
- [ ] Verify hook works with pre-commit framework
- [ ] Test in consumer repository

## Technical Details

- **Language**: <language>
- **File Types**: <file-types>
- **Dependencies**: <dependencies>
- **Entry Point**: `hooks/<path>/<hook-id>.<ext>`

## Child Issues

_Child issues will be created for each phase as work progresses._

## Acceptance Criteria

- [ ] Hook passes all tests
- [ ] Hook is documented in README
- [ ] Hook is registered in `.pre-commit-hooks.yaml`
- [ ] Hook works in consumer `.pre-commit-config.yaml`
EOF
)"
```

#### 1.2 Store Issue Number

```bash
PARENT_ISSUE=$(gh issue list --repo aRustyDev/pre-commit-hooks --search "feat: Add <hook-name>" --json number -q '.[0].number')
echo "Created parent issue: #$PARENT_ISSUE"
```

### Phase 2: Create Feature Branch

```bash
cd "$HOOKS_REPO"
git checkout main
git pull origin main

# Create feature branch
BRANCH_NAME="feat/<hook-id>"
git checkout -b "$BRANCH_NAME"
```

### Phase 3: Implement Hook

#### 3.1 Determine Hook Location

| Language | Location | Entry Format |
|----------|----------|--------------|
| Shell (bash) | `hooks/shell/<hook-id>.sh` | Single script |
| Python | `hooks/python/<hook-id>/<hook-id>.py` | Package with `__init__.py` |
| Golang | `hooks/go/<hook-id>/main.go` | Go module |
| Rust | `hooks/cargo/<hook-id>/` | Cargo package |
| Node | `hooks/node/<hook-id>/index.js` | npm package |

#### 3.2 Shell Hook Template

For shell-based hooks, create `hooks/shell/<hook-id>.sh`:

```bash
#!/usr/bin/env bash
# =============================================================================
# <Hook Name> - Pre-commit Hook
# =============================================================================
# Description: <description>
#
# Usage:
#   ./<hook-id>.sh [options] [files...]
#
# Options:
#   --check     Check mode (don't modify files)
#   --fix       Fix mode (modify files in place)
#   --help      Show this help message
#
# Exit Codes:
#   0 - Success (all files pass/fixed)
#   1 - Failure (files failed validation/fixing)
#   2 - Error (missing dependencies, invalid arguments)
#
# Dependencies:
#   - <tool>: <install instructions>
# =============================================================================

set -euo pipefail

# Configuration
TOOL_NAME="<tool>"
CHECK_MODE="${<HOOK_ENV>_CHECK:-false}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log_error() { echo -e "${RED}ERROR:${NC} $*" >&2; }
log_warn() { echo -e "${YELLOW}WARN:${NC} $*" >&2; }
log_success() { echo -e "${GREEN}✓${NC} $*"; }
log_info() { echo "$*"; }

# Check if tool is installed
check_dependency() {
  if ! command -v "$TOOL_NAME" &> /dev/null; then
    log_error "$TOOL_NAME is not installed"
    log_info "Install with: <install command>"
    exit 2
  fi
}

# Show help
show_help() {
  sed -n '/^# Usage:/,/^# ====/p' "$0" | sed 's/^# //' | head -n -1
  exit 0
}

# Parse arguments
parse_args() {
  local files=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --check)
        CHECK_MODE="true"
        shift
        ;;
      --fix)
        CHECK_MODE="false"
        shift
        ;;
      --help|-h)
        show_help
        ;;
      --)
        shift
        files+=("$@")
        break
        ;;
      -*)
        log_error "Unknown option: $1"
        exit 2
        ;;
      *)
        files+=("$1")
        shift
        ;;
    esac
  done

  # Return files via global
  FILES=("${files[@]}")
}

# Process a single file
process_file() {
  local file="$1"
  local status=0

  # Skip if file doesn't exist
  if [[ ! -f "$file" ]]; then
    log_warn "File not found: $file"
    return 0
  fi

  # Skip if not target file type
  if [[ ! "$file" =~ \.<ext>$ ]]; then
    return 0
  fi

  if [[ "$CHECK_MODE" == "true" ]]; then
    # Check mode
    if ! $TOOL_NAME --check "$file" 2>&1; then
      log_error "$file failed validation"
      status=1
    else
      log_success "$file"
    fi
  else
    # Fix mode
    if ! $TOOL_NAME "$file" 2>&1; then
      log_error "Failed to process $file"
      status=1
    else
      log_success "Processed $file"
    fi
  fi

  return $status
}

# Main
main() {
  check_dependency
  parse_args "$@"

  local exit_code=0

  for file in "${FILES[@]}"; do
    if ! process_file "$file"; then
      exit_code=1
    fi
  done

  exit $exit_code
}

main "$@"
```

#### 3.3 Python Hook Template

For Python hooks, create `hooks/python/<hook-id>/<hook-id>.py`:

```python
#!/usr/bin/env python3
"""
<Hook Name> - Pre-commit Hook

Description: <description>

Usage:
    python <hook-id>.py [options] [files...]

Options:
    --check     Check mode (don't modify files)
    --fix       Fix mode (modify files in place)
    --help      Show this help message

Exit Codes:
    0 - Success (all files pass/fixed)
    1 - Failure (files failed validation/fixing)
    2 - Error (missing dependencies, invalid arguments)
"""

import argparse
import sys
from pathlib import Path
from typing import List, Sequence


def check_file(filepath: Path, fix: bool = False) -> bool:
    """
    Check or fix a single file.

    Args:
        filepath: Path to the file to check
        fix: If True, fix issues in place

    Returns:
        True if file passes/was fixed, False otherwise
    """
    if not filepath.exists():
        print(f"WARN: File not found: {filepath}", file=sys.stderr)
        return True

    try:
        content = filepath.read_text()

        # TODO: Implement validation logic
        is_valid = True  # Replace with actual check

        if not is_valid and fix:
            # TODO: Implement fix logic
            fixed_content = content  # Replace with fixed content
            filepath.write_text(fixed_content)
            print(f"✓ Fixed {filepath}")
            return True
        elif not is_valid:
            print(f"ERROR: {filepath} failed validation", file=sys.stderr)
            return False
        else:
            print(f"✓ {filepath}")
            return True

    except Exception as e:
        print(f"ERROR: Failed to process {filepath}: {e}", file=sys.stderr)
        return False


def main(argv: Sequence[str] | None = None) -> int:
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description="<description>",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument(
        "--check",
        action="store_true",
        help="Check mode (don't modify files)",
    )
    parser.add_argument(
        "--fix",
        action="store_true",
        help="Fix mode (modify files in place)",
    )
    parser.add_argument(
        "files",
        nargs="*",
        help="Files to process",
    )

    args = parser.parse_args(argv)

    if not args.files:
        return 0

    fix_mode = args.fix and not args.check
    exit_code = 0

    for file_path in args.files:
        path = Path(file_path)
        if not check_file(path, fix=fix_mode):
            exit_code = 1

    return exit_code


if __name__ == "__main__":
    sys.exit(main())
```

Also create `hooks/python/<hook-id>/__init__.py`:

```python
"""<Hook Name> pre-commit hook."""
from .<hook-id> import main

__all__ = ["main"]
```

#### 3.4 Make Executable

```bash
chmod +x hooks/<path>/<hook-id>.<ext>
```

### Phase 4: Create Child Issue for Implementation

```bash
gh issue create \
  --repo aRustyDev/pre-commit-hooks \
  --title "impl: <hook-name> core implementation" \
  --label "<language>,implementation" \
  --body "$(cat <<EOF
## Parent Issue

Closes part of #$PARENT_ISSUE

## Scope

Implement the core functionality of the <hook-name> hook.

## Tasks

- [ ] Create hook script at \`hooks/<path>/<hook-id>.<ext>\`
- [ ] Implement file validation logic
- [ ] Handle CLI arguments (--check, --fix, --help)
- [ ] Handle missing dependencies gracefully
- [ ] Add proper exit codes
- [ ] Test manually with sample files

## Files to Create/Modify

- \`hooks/<path>/<hook-id>.<ext>\` (new)

## Acceptance Criteria

- [ ] Hook runs without errors on valid files
- [ ] Hook reports errors on invalid files
- [ ] Hook handles missing dependencies with helpful message
- [ ] All CLI arguments work as documented
EOF
)"
```

### Phase 5: Write Tests

#### 5.1 Create Test File

Create `tests/<category>/test_<hook-id>.bats`:

```bash
#!/usr/bin/env bats

load ../test_helper

setup() {
  setup_test_env
}

teardown() {
  teardown_test_env
}

# =============================================================================
# Basic Tests
# =============================================================================

@test "<hook-id> hook exists and is executable" {
  run test -x "$ORIGINAL_DIR/hooks/<path>/<hook-id>.<ext>"
  [ "$status" -eq 0 ]
}

@test "<hook-id> shows help with --help" {
  run "$ORIGINAL_DIR/hooks/<path>/<hook-id>.<ext>" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage"* ]]
}

# =============================================================================
# Success Cases
# =============================================================================

@test "<hook-id> passes valid files" {
  # Create valid test file
  create_test_file "valid.<ext>" '<valid-content>'

  run "$ORIGINAL_DIR/hooks/<path>/<hook-id>.<ext>" "valid.<ext>"
  [ "$status" -eq 0 ]
}

@test "<hook-id> handles multiple files" {
  create_test_file "file1.<ext>" '<valid-content>'
  create_test_file "file2.<ext>" '<valid-content>'

  run "$ORIGINAL_DIR/hooks/<path>/<hook-id>.<ext>" "file1.<ext>" "file2.<ext>"
  [ "$status" -eq 0 ]
}

# =============================================================================
# Failure Cases
# =============================================================================

@test "<hook-id> fails on invalid files" {
  create_test_file "invalid.<ext>" '<invalid-content>'

  run "$ORIGINAL_DIR/hooks/<path>/<hook-id>.<ext>" "invalid.<ext>"
  [ "$status" -eq 1 ]
}

@test "<hook-id> reports specific errors" {
  create_test_file "invalid.<ext>" '<invalid-content>'

  run "$ORIGINAL_DIR/hooks/<path>/<hook-id>.<ext>" "invalid.<ext>"
  [ "$status" -eq 1 ]
  [[ "$output" == *"ERROR"* ]] || [[ "$output" == *"error"* ]]
}

# =============================================================================
# Edge Cases
# =============================================================================

@test "<hook-id> handles missing files gracefully" {
  run "$ORIGINAL_DIR/hooks/<path>/<hook-id>.<ext>" "nonexistent.<ext>"
  # Should not crash - either skip or warn
  [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "<hook-id> handles empty file list" {
  run "$ORIGINAL_DIR/hooks/<path>/<hook-id>.<ext>"
  [ "$status" -eq 0 ]
}

@test "<hook-id> handles empty files" {
  create_test_file "empty.<ext>" ""

  run "$ORIGINAL_DIR/hooks/<path>/<hook-id>.<ext>" "empty.<ext>"
  # Document expected behavior
  [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

# =============================================================================
# Dependency Tests
# =============================================================================

@test "<hook-id> reports missing dependency" {
  # Mock the dependency as not available
  mock_command "<tool>" "exit 127"

  run "$ORIGINAL_DIR/hooks/<path>/<hook-id>.<ext>" "test.<ext>"
  [ "$status" -eq 2 ]
  [[ "$output" == *"not installed"* ]] || [[ "$output" == *"not found"* ]]
}
```

#### 5.2 Create Test Fixtures (if needed)

Create `tests/<category>/fixtures/` with sample files:

```bash
mkdir -p tests/<category>/fixtures
# Add valid and invalid sample files
```

#### 5.3 Create Child Issue for Testing

```bash
gh issue create \
  --repo aRustyDev/pre-commit-hooks \
  --title "test: <hook-name> test suite" \
  --label "<language>,testing" \
  --body "$(cat <<EOF
## Parent Issue

Closes part of #$PARENT_ISSUE

## Scope

Create comprehensive test suite for the <hook-name> hook.

## Tasks

- [ ] Create test file at \`tests/<category>/test_<hook-id>.bats\`
- [ ] Test hook existence and executability
- [ ] Test success cases with valid files
- [ ] Test failure cases with invalid files
- [ ] Test edge cases (empty files, missing files)
- [ ] Test dependency handling
- [ ] Create test fixtures if needed
- [ ] Ensure all tests pass locally
- [ ] Verify tests pass in CI

## Files to Create/Modify

- \`tests/<category>/test_<hook-id>.bats\` (new)
- \`tests/<category>/fixtures/\` (new, if needed)

## Acceptance Criteria

- [ ] All tests pass locally
- [ ] Tests cover success, failure, and edge cases
- [ ] Tests are documented
- [ ] Tests follow existing patterns
EOF
)"
```

### Phase 6: Register Hook

#### 6.1 Add to `.pre-commit-hooks.yaml`

Add entry to `.pre-commit-hooks.yaml`:

```yaml
- id: <hook-id>
  name: <Hook Name>
  description: <description>
  entry: hooks/<path>/<hook-id>.<ext>
  language: <script|python|golang|rust|node>
  files: \.<ext>$
  types: [<type>]
  args: []
  pass_filenames: true
  require_serial: false
  minimum_pre_commit_version: "0"
```

#### 6.2 Language-Specific Settings

| Language | `language` Value | Additional Settings |
|----------|------------------|---------------------|
| Shell | `script` | None |
| Python | `python` | `additional_dependencies: []` |
| Golang | `golang` | None |
| Rust | `rust` | None |
| Node | `node` | `additional_dependencies: []` |
| Docker | `docker_image` | `entry: <image>:<tag>` |

### Phase 7: Update Issue Progress

After each phase, update the parent issue:

```bash
# Add comment showing progress
gh issue comment $PARENT_ISSUE \
  --repo aRustyDev/pre-commit-hooks \
  --body "## Progress Update

### Completed
- [x] Core implementation
- [x] Test suite
- [ ] Documentation
- [ ] Integration testing

### Next Steps
- Update README with hook documentation
- Test in consumer repository
"
```

### Phase 8: Create Pull Request

When MVP is complete:

```bash
cd "$HOOKS_REPO"

# Ensure all changes are committed
git add .
git commit -m "feat(<hook-id>): add <hook-name> pre-commit hook

- Implement core hook functionality
- Add comprehensive test suite
- Register hook in .pre-commit-hooks.yaml

Closes #$PARENT_ISSUE"

# Push branch
git push -u origin "$BRANCH_NAME"

# Create PR
gh pr create \
  --repo aRustyDev/pre-commit-hooks \
  --title "feat(<hook-id>): Add <hook-name> pre-commit hook" \
  --body "$(cat <<EOF
## Summary

Adds a new pre-commit hook: **<hook-name>**

<description>

## Changes

- \`hooks/<path>/<hook-id>.<ext>\` - Hook implementation
- \`tests/<category>/test_<hook-id>.bats\` - Test suite
- \`.pre-commit-hooks.yaml\` - Hook registration

## Testing

\`\`\`bash
# Run tests
bats tests/<category>/test_<hook-id>.bats

# Test with pre-commit
pre-commit try-repo . <hook-id> --files <test-file>
\`\`\`

## Checklist

- [x] Hook implementation complete
- [x] Tests pass locally
- [x] Hook registered in \`.pre-commit-hooks.yaml\`
- [ ] CI passes
- [ ] README updated (if needed)

## Related Issues

Closes #$PARENT_ISSUE

---

Generated with [Claude Code](https://claude.ai/claude-code)
EOF
)" \
  --project "Pre-Commit Hooks"
```

### Phase 9: Update Consumer Configuration

After PR is merged, update the consumer's `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: https://github.com/aRustyDev/pre-commit-hooks
    rev: <latest-tag-or-commit>  # Update to include new hook
    hooks:
      - id: <hook-id>
        # Optional: customize args
        # args: [--check]
        # Optional: limit to specific files
        # files: ^src/.*\.<ext>$
```

To find the latest version:

```bash
gh release list --repo aRustyDev/pre-commit-hooks --limit 1
# Or use main branch
rev: main
```

## Output Summary

After completion, output:

```markdown
## Pre-Commit Hook Created: <hook-id>

### GitHub Issues

| Issue | Title | Status |
|-------|-------|--------|
| #<parent> | feat: Add <hook-name> pre-commit hook | Open |
| #<impl> | impl: <hook-name> core implementation | Closed |
| #<test> | test: <hook-name> test suite | Closed |

### Pull Request

- **PR**: #<pr-number>
- **Branch**: `feat/<hook-id>`
- **Status**: <status>

### Files Created

| File | Description |
|------|-------------|
| `hooks/<path>/<hook-id>.<ext>` | Hook implementation |
| `tests/<category>/test_<hook-id>.bats` | Test suite |
| `.pre-commit-hooks.yaml` | Updated with hook entry |

### Usage

After PR is merged, add to consumer `.pre-commit-config.yaml`:

\`\`\`yaml
repos:
  - repo: https://github.com/aRustyDev/pre-commit-hooks
    rev: <version>
    hooks:
      - id: <hook-id>
\`\`\`

### Local Testing

\`\`\`bash
# Run hook directly
$HOOKS_REPO/hooks/<path>/<hook-id>.<ext> <test-file>

# Run tests
bats $HOOKS_REPO/tests/<category>/test_<hook-id>.bats

# Test with pre-commit framework
cd <consumer-repo>
pre-commit try-repo $HOOKS_REPO <hook-id> --files <test-file>
\`\`\`
```

## Reference Files

- **Repository**: https://github.com/aRustyDev/pre-commit-hooks
- **Hook Registry**: `.pre-commit-hooks.yaml`
- **Shell Hooks**: `hooks/shell/`
- **Python Hooks**: `hooks/python/`
- **Tests**: `tests/`
- **Test Helper**: `tests/test_helper.bash`

## Examples

### Create a shell-based hook
```
/create-pre-commit-hook "validate-toml - Validate TOML file syntax using tomlv"
```

### Create a Python hook
```
/create-pre-commit-hook "check-json python - Validate JSON files and check for duplicate keys"
```

### Create a hook wrapping an existing tool
```
/create-pre-commit-hook "taplo-fmt - Format TOML files using taplo"
```
