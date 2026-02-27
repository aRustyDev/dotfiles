#!/usr/bin/env python3
"""Add logging configuration to MCP server YAML files."""

import sys
import re
from pathlib import Path

LOGGING_BLOCK = """    logging:
      driver: "${O11Y_LOGGING_DRIVER:-json-file}"
      options:
        max-size: "${O11Y_LOG_MAX_SIZE:-10m}"
        max-file: "${O11Y_LOG_MAX_FILES:-3}"
        tag: "{{.Name}}"
"""

O11Y_LABELS = """      # Observability labels
      o11y.service: "{service_name}"
      o11y.component: "mcp"
"""


def get_service_name(file_path: Path) -> str:
    """Extract service name from filename."""
    return f"mcp-{file_path.stem}"


def has_logging(content: str) -> bool:
    """Check if file already has logging configured."""
    return bool(re.search(r"^\s{4}logging:", content, re.MULTILINE))


def has_o11y_labels(content: str) -> bool:
    """Check if file already has o11y labels."""
    return "o11y.service:" in content


def add_o11y_labels(content: str, service_name: str) -> str:
    """Add observability labels after traefik.docker.network."""
    if has_o11y_labels(content):
        return content

    # Find traefik.docker.network line and add o11y labels after it
    pattern = r"(traefik\.docker\.network:.*?)(\n)"
    replacement = r"\1\2" + O11Y_LABELS.format(service_name=service_name)
    return re.sub(pattern, replacement, content, count=1)


def add_logging(content: str) -> str:
    """Add logging block to service configuration."""
    if has_logging(content):
        return content

    # Strategy 1: Insert before 'configs:' section at root level
    if re.search(r"^configs:", content, re.MULTILINE):
        return re.sub(r"^(configs:)", LOGGING_BLOCK + r"\n\1", content, count=1, flags=re.MULTILINE)

    # Strategy 2: Append to end of file (before trailing newlines)
    content = content.rstrip("\n")
    return content + "\n" + LOGGING_BLOCK + "\n"


def process_file(file_path: Path, dry_run: bool = False) -> bool:
    """Process a single file."""
    content = file_path.read_text()
    service_name = get_service_name(file_path)

    if has_logging(content):
        print(f"[SKIP] {file_path} - already has logging")
        return False

    # Add o11y labels and logging
    new_content = add_o11y_labels(content, service_name)
    new_content = add_logging(new_content)

    if dry_run:
        print(f"[DRY-RUN] Would update: {file_path}")
    else:
        file_path.write_text(new_content)
        print(f"[UPDATE] {file_path}")

    return True


def main():
    dry_run = "--dry-run" in sys.argv
    modules_dir = Path(__file__).parent.parent / "modules" / "mcp"

    updated = 0
    skipped = 0

    print("=== MCP Logging Configuration Script ===")
    print(f"Scanning: {modules_dir}")
    print()

    for yaml_file in sorted(modules_dir.rglob("*.yaml")):
        if "TODO" in yaml_file.name:
            continue

        if process_file(yaml_file, dry_run):
            updated += 1
        else:
            skipped += 1

    print()
    print("=== Summary ===")
    print(f"Files updated: {updated}")
    print(f"Files skipped: {skipped}")

    if dry_run:
        print()
        print("Run without --dry-run to apply changes")


if __name__ == "__main__":
    main()
