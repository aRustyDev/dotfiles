"""
New component detection utilities.

Provides functionality to:
- Detect newly discovered components since last collection
- Track first-seen timestamps
- Generate new component reports
"""

from __future__ import annotations

import json
import logging
from dataclasses import dataclass, field
from datetime import UTC, date, datetime
from pathlib import Path
from typing import Any

logger = logging.getLogger(__name__)


@dataclass
class NewComponentReport:
    """Report of newly discovered components."""

    registry: str
    timestamp: str
    new_count: int
    components: list[dict] = field(default_factory=list)
    comparison_file: str | None = None
    notes: str | None = None


@dataclass
class DetectionResult:
    """Result from new component detection."""

    total_new: int = 0
    total_existing: int = 0
    by_registry: dict[str, NewComponentReport] = field(default_factory=dict)
    by_kind: dict[str, int] = field(default_factory=dict)

    @property
    def registries_with_new(self) -> list[str]:
        """Registries that have new components."""
        return [r for r, report in self.by_registry.items() if report.new_count > 0]


def load_component_ids(file_path: Path) -> dict[str, dict[str, Any]]:
    """Load component IDs and metadata from NDJSON file.

    Args:
        file_path: Path to NDJSON file

    Returns:
        Dict mapping component ID to metadata (id, discovered_at, source_name, type)
    """
    components = {}

    if not file_path.exists():
        logger.debug(f"File not found: {file_path}")
        return components

    with open(file_path) as f:
        for line in f:
            if line.strip():
                try:
                    comp = json.loads(line)
                    comp_id = comp.get("id")
                    if comp_id:
                        components[comp_id] = {
                            "id": comp_id,
                            "discovered_at": comp.get("discovered_at"),
                            "source_name": comp.get("source_name"),
                            "type": comp.get("type"),
                            "name": comp.get("name"),
                        }
                except json.JSONDecodeError:
                    pass

    logger.debug(f"Loaded {len(components)} component IDs from {file_path}")
    return components


def detect_new_components(
    current_file: Path,
    previous_file: Path | None = None,
    previous_ids: set[str] | None = None,
) -> list[dict]:
    """Detect components in current file that weren't in previous.

    Args:
        current_file: Path to current collection NDJSON file
        previous_file: Path to previous collection file (optional)
        previous_ids: Set of previous component IDs (alternative to previous_file)

    Returns:
        List of new component dictionaries with first_seen timestamp
    """
    # Load previous IDs
    if previous_ids is None:
        previous_ids = set()
        if previous_file and previous_file.exists():
            previous_data = load_component_ids(previous_file)
            previous_ids = set(previous_data.keys())

    # Find new components
    new_components = []
    now = datetime.now(UTC).isoformat()

    if not current_file.exists():
        logger.warning(f"Current file not found: {current_file}")
        return new_components

    with open(current_file) as f:
        for line in f:
            if line.strip():
                try:
                    comp = json.loads(line)
                    comp_id = comp.get("id")

                    if comp_id and comp_id not in previous_ids:
                        # Mark as newly discovered
                        comp["first_seen"] = now
                        comp["is_new"] = True
                        new_components.append(comp)

                except json.JSONDecodeError:
                    pass

    logger.info(f"Detected {len(new_components)} new components in {current_file.name}")
    return new_components


def detect_new_by_registry(
    current_dir: Path,
    previous_dir: Path | None = None,
    pattern: str = "*-bronze.ndjson",
) -> DetectionResult:
    """Detect new components across all registry files.

    Args:
        current_dir: Directory containing current bronze files
        previous_dir: Directory containing previous bronze files (defaults to current_dir)
        pattern: Glob pattern for bronze files

    Returns:
        DetectionResult with per-registry and aggregate counts
    """
    if previous_dir is None:
        previous_dir = current_dir

    result = DetectionResult()

    # Find all current bronze files
    current_files = list(current_dir.glob(pattern))

    for current_file in current_files:
        # Extract registry name from filename (e.g., "smithery-ai-bronze.ndjson" -> "smithery.ai")
        registry_name = current_file.stem.replace("-bronze", "").replace("-", ".")

        # Find matching previous file
        previous_file = previous_dir / current_file.name
        if not previous_file.exists():
            # Try backup location
            backup_dir = previous_dir / ".previous"
            previous_file = backup_dir / current_file.name

        # Load previous IDs
        previous_ids: set[str] = set()
        if previous_file.exists():
            previous_data = load_component_ids(previous_file)
            previous_ids = set(previous_data.keys())
            logger.debug(f"{registry_name}: {len(previous_ids)} previous components")

        # Count current and new
        current_data = load_component_ids(current_file)
        current_ids = set(current_data.keys())

        new_ids = current_ids - previous_ids
        new_components = []

        # Get full component data for new items
        if new_ids:
            with open(current_file) as f:
                for line in f:
                    if line.strip():
                        try:
                            comp = json.loads(line)
                            if comp.get("id") in new_ids:
                                comp["first_seen"] = datetime.now(UTC).isoformat()
                                comp["is_new"] = True
                                new_components.append(comp)

                                # Track by kind
                                kind = comp.get("type", "unknown")
                                result.by_kind[kind] = result.by_kind.get(kind, 0) + 1

                        except json.JSONDecodeError:
                            pass

        # Create report for this registry
        report = NewComponentReport(
            registry=registry_name,
            timestamp=datetime.now(UTC).isoformat(),
            new_count=len(new_components),
            components=new_components,
            comparison_file=str(previous_file) if previous_file.exists() else None,
        )

        result.by_registry[registry_name] = report
        result.total_new += len(new_components)
        result.total_existing += len(current_ids) - len(new_ids)

    return result


def generate_new_report(
    registry: str,
    new_components: list[dict],
    output_dir: Path,
) -> Path:
    """Generate report of newly discovered components.

    Args:
        registry: Registry name
        new_components: List of new component dictionaries
        output_dir: Directory to write report

    Returns:
        Path to generated report file
    """
    # Create reports subdirectory
    reports_dir = output_dir / "reports"
    reports_dir.mkdir(parents=True, exist_ok=True)

    # Generate filename with date
    today = date.today().isoformat()
    safe_registry = registry.replace(":", "-").replace("/", "-").replace(".", "-")
    report_file = reports_dir / f"{safe_registry}-new-{today}.ndjson"

    # Write new components
    with open(report_file, "w") as f:
        for comp in new_components:
            f.write(json.dumps(comp) + "\n")

    logger.info(f"New component report: {report_file} ({len(new_components)} components)")
    return report_file


def generate_detection_report(
    result: DetectionResult,
    output_dir: Path,
) -> Path:
    """Generate aggregate detection report as JSON.

    Args:
        result: DetectionResult from detection
        output_dir: Directory to write report

    Returns:
        Path to generated report file
    """
    reports_dir = output_dir / "reports"
    reports_dir.mkdir(parents=True, exist_ok=True)

    today = date.today().isoformat()
    report_file = reports_dir / f"detection-{today}.json"

    # Build report data
    data = {
        "timestamp": datetime.now(UTC).isoformat(),
        "summary": {
            "total_new": result.total_new,
            "total_existing": result.total_existing,
            "registries_with_new": result.registries_with_new,
        },
        "by_kind": result.by_kind,
        "by_registry": {},
    }

    for registry, report in result.by_registry.items():
        data["by_registry"][registry] = {
            "new_count": report.new_count,
            "comparison_file": report.comparison_file,
            "timestamp": report.timestamp,
            # Omit full component list for summary report
            "sample": report.components[:5] if report.components else [],
        }

    with open(report_file, "w") as f:
        json.dump(data, f, indent=2)

    logger.info(f"Detection report: {report_file}")
    return report_file


def format_detection_report(result: DetectionResult, verbose: bool = False) -> str:
    """Format detection result as human-readable text.

    Args:
        result: DetectionResult to format
        verbose: Include component details

    Returns:
        Formatted report string
    """
    lines = [
        "=" * 60,
        "NEW COMPONENT DETECTION REPORT",
        f"Generated: {datetime.now(UTC).isoformat()}",
        "=" * 60,
        "",
    ]

    # Summary
    lines.append("SUMMARY")
    lines.append("-" * 40)
    lines.append(f"Total New: {result.total_new}")
    lines.append(f"Total Existing: {result.total_existing}")
    lines.append(f"Registries with New: {len(result.registries_with_new)}")
    lines.append("")

    # By kind
    if result.by_kind:
        lines.append("BY KIND")
        lines.append("-" * 40)
        for kind, count in sorted(result.by_kind.items(), key=lambda x: -x[1]):
            lines.append(f"  {kind}: {count}")
        lines.append("")

    # By registry
    lines.append("BY REGISTRY")
    lines.append("-" * 40)

    for registry, report in sorted(result.by_registry.items()):
        if report.new_count > 0:
            lines.append(f"  [NEW] {registry}: {report.new_count} new")
            if verbose and report.components:
                for comp in report.components[:10]:
                    name = comp.get("name", "unknown")[:40]
                    kind = comp.get("type", "?")
                    lines.append(f"         - {name} ({kind})")
                if len(report.components) > 10:
                    lines.append(f"         ... and {len(report.components) - 10} more")
        else:
            lines.append(f"  [ -- ] {registry}: no new components")

    lines.append("")
    lines.append("=" * 60)

    return "\n".join(lines)


def backup_current_collection(
    current_dir: Path,
    backup_dir: Path | None = None,
    pattern: str = "*-bronze.ndjson",
) -> Path:
    """Backup current bronze files for future comparison.

    Args:
        current_dir: Directory containing current bronze files
        backup_dir: Destination for backups (defaults to current_dir/.previous)
        pattern: Glob pattern for bronze files

    Returns:
        Path to backup directory
    """
    import shutil

    if backup_dir is None:
        backup_dir = current_dir / ".previous"

    backup_dir.mkdir(parents=True, exist_ok=True)

    # Copy current files to backup
    for current_file in current_dir.glob(pattern):
        dest = backup_dir / current_file.name
        shutil.copy2(current_file, dest)
        logger.debug(f"Backed up: {current_file.name}")

    # Write timestamp
    timestamp_file = backup_dir / ".backup-timestamp"
    timestamp_file.write_text(datetime.now(UTC).isoformat())

    logger.info(f"Collection backed up to {backup_dir}")
    return backup_dir
