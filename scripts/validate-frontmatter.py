#!/usr/bin/env python3
"""
Validate frontmatter in docs/notes markdown files.
Used as a pre-commit hook to enforce schema compliance.
"""

import sys
import re
import uuid
from pathlib import Path

# Valid values for enum fields
VALID_STATUSES = [
    "📝 draft",
    "✅ active",
    "🔍 review",
    "📦 archived",
    "🚧 wip",
    "⚠️ deprecated",
]

VALID_TYPES = [
    "guide",
    "reference",
    "tutorial",
    "adr",
    "runbook",
    "cheatsheet",
    "note",
]

VALID_SCOPES = [
    "docker",
    "git",
    "just",
    "k9s",
    "zsh",
    "tmux",
    "nvim",
    "nix",
    "terraform",
    "mcp",
    "ai",
    "obsidian",
    "general",
]

REQUIRED_FIELDS = ["id", "title", "created", "project", "scope", "type", "status"]


def extract_frontmatter(content: str) -> dict | None:
    """Extract YAML frontmatter from markdown content."""
    match = re.match(r"^---\n(.*?)\n---", content, re.DOTALL)
    if not match:
        return None

    frontmatter = {}
    current_key = None
    current_list = None

    for line in match.group(1).split("\n"):
        # Skip empty lines
        if not line.strip():
            continue

        # Check for list item
        if line.startswith("  - "):
            if current_list is not None:
                value = line.strip()[2:].strip()
                if value:  # Skip empty list items
                    current_list.append(value)
            continue

        # Check for key: value
        if ":" in line:
            key, _, value = line.partition(":")
            key = key.strip()
            value = value.strip()

            if value == "":
                # Could be a list or empty value
                current_key = key
                current_list = []
                frontmatter[key] = current_list
            else:
                frontmatter[key] = value
                current_key = None
                current_list = None

    return frontmatter


def validate_uuid(value: str) -> bool:
    """Check if value is a valid UUID v4."""
    try:
        uuid.UUID(value, version=4)
        return True
    except (ValueError, AttributeError):
        return False


def validate_file(filepath: Path) -> list[str]:
    """Validate a single file's frontmatter. Returns list of errors."""
    errors = []

    try:
        content = filepath.read_text(encoding="utf-8")
    except Exception as e:
        return [f"Could not read file: {e}"]

    frontmatter = extract_frontmatter(content)
    if frontmatter is None:
        return ["Missing frontmatter (no YAML block found)"]

    # Check required fields
    for field in REQUIRED_FIELDS:
        if field not in frontmatter:
            errors.append(f"Missing required field: {field}")
        elif not frontmatter[field]:
            errors.append(f"Empty required field: {field}")

    # Validate specific fields
    if "id" in frontmatter and frontmatter["id"]:
        if not validate_uuid(frontmatter["id"]):
            errors.append(f"Invalid UUID format: {frontmatter['id']}")

    if "status" in frontmatter and frontmatter["status"]:
        if frontmatter["status"] not in VALID_STATUSES:
            errors.append(
                f"Invalid status: '{frontmatter['status']}'\n"
                f"       Valid: {VALID_STATUSES}"
            )

    if "type" in frontmatter and frontmatter["type"]:
        if frontmatter["type"] not in VALID_TYPES:
            errors.append(
                f"Invalid type: '{frontmatter['type']}'\n" f"       Valid: {VALID_TYPES}"
            )

    if "scope" in frontmatter:
        scopes = frontmatter["scope"]
        if isinstance(scopes, list):
            for scope in scopes:
                if scope and scope not in VALID_SCOPES:
                    errors.append(
                        f"Invalid scope: '{scope}'\n" f"       Valid: {VALID_SCOPES}"
                    )
        elif scopes and scopes not in VALID_SCOPES:
            errors.append(
                f"Invalid scope: '{scopes}'\n" f"       Valid: {VALID_SCOPES}"
            )

    return errors


def main():
    """Main entry point for pre-commit hook."""
    failed = False

    # Get files from command line args (pre-commit passes staged files)
    files = [Path(f) for f in sys.argv[1:] if f.endswith(".md")]

    # Filter to only docs/notes files
    notes_files = [f for f in files if "docs/notes" in str(f)]

    # Skip validation dashboard itself
    notes_files = [f for f in notes_files if "validation-dashboard" not in str(f)]

    for filepath in notes_files:
        errors = validate_file(filepath)
        if errors:
            failed = True
            print(f"\n❌ {filepath}")
            for error in errors:
                print(f"   • {error}")

    if failed:
        print("\n" + "=" * 60)
        print("Frontmatter validation failed. Fix errors above.")
        print("=" * 60 + "\n")
        sys.exit(1)

    if notes_files:
        print(f"✅ Validated {len(notes_files)} docs/notes file(s)")

    sys.exit(0)


if __name__ == "__main__":
    main()
