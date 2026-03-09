"""
Coverage tracking and comparison utilities.

Provides functionality to:
- Load registry claims and coverage baselines
- Compare collected counts against claims
- Generate coverage reports

Data tiers:
- Claimed: What the registry advertises (extracted from homepage/API)
- Detected: What our crawling discovers (before download)
- Collected: What was actually downloaded/scraped
- Verified: Validated as unique and non-empty
- Refined: Final deduplicated/normalized set
"""

from __future__ import annotations

import json
import logging
from dataclasses import dataclass, field
from datetime import UTC, datetime
from pathlib import Path
from typing import Any

from rich.console import Console
from rich.table import Table
from rich.text import Text

logger = logging.getLogger(__name__)

# Default paths (relative to this module)
_MODULE_DIR = Path(__file__).parent
DEFAULT_CLAIMS_FILE = _MODULE_DIR / "registry_claims.json"
DEFAULT_BASELINE_FILE = _MODULE_DIR / "coverage_baseline.json"


@dataclass
class KindCoverage:
    """Coverage metrics for a specific component kind."""

    kind: str
    expected: int
    actual: int
    coverage_pct: float
    tolerance: float
    within_tolerance: bool
    min_acceptable: int

    @property
    def shortfall(self) -> int:
        """Number of components below expected."""
        return max(0, self.expected - self.actual)

    @property
    def surplus(self) -> int:
        """Number of components above expected."""
        return max(0, self.actual - self.expected)


@dataclass
class RegistryCoverage:
    """Coverage metrics for a single registry.

    Tracks five data tiers:
    - claimed: What the registry advertises
    - detected: What our crawling discovers (URLs found)
    - collected: What was actually downloaded
    - verified: Validated as unique and non-empty
    - refined: Final deduplicated/normalized set
    """

    registry: str
    claimed_total: int | None
    detected_total: int = 0  # URLs discovered during crawl
    collected_total: int = 0  # Records actually downloaded
    verified_total: int = 0  # Validated as unique/non-empty
    refined_total: int = 0  # Final deduplicated set
    coverage_pct: float | None = None  # collected/claimed
    by_kind: dict[str, KindCoverage] = field(default_factory=dict)
    discrepancy_alert: bool = False
    notes: str | None = None

    @property
    def has_claims(self) -> bool:
        """Whether the registry has claimed totals."""
        return self.claimed_total is not None

    @property
    def detected_pct(self) -> float | None:
        """Percentage of claimed that were detected."""
        if not self.claimed_total:
            return None
        return (self.detected_total / self.claimed_total) * 100

    @property
    def collected_pct(self) -> float | None:
        """Percentage of detected that were collected."""
        if not self.detected_total:
            return None
        return (self.collected_total / self.detected_total) * 100

    @property
    def verified_pct(self) -> float | None:
        """Percentage of collected that were verified."""
        if not self.collected_total:
            return None
        return (self.verified_total / self.collected_total) * 100

    @property
    def refined_pct(self) -> float | None:
        """Percentage of verified that were refined."""
        if not self.verified_total:
            return None
        return (self.refined_total / self.verified_total) * 100

    @property
    def status(self) -> str:
        """Coverage status string."""
        if not self.has_claims:
            return "unknown"
        if self.discrepancy_alert:
            return "alert"
        if self.coverage_pct and self.coverage_pct >= 90:
            return "good"
        if self.coverage_pct and self.coverage_pct >= 70:
            return "warning"
        return "critical"


@dataclass
class KindSummary:
    """Coverage metrics aggregated by component kind across all registries."""

    kind: str
    claimed_total: int = 0
    detected_total: int = 0
    collected_total: int = 0
    verified_total: int = 0
    refined_total: int = 0
    registries: list[str] = field(default_factory=list)

    @property
    def has_claims(self) -> bool:
        """Whether this kind has claimed totals."""
        return self.claimed_total > 0

    @property
    def detected_pct(self) -> float | None:
        """Percentage of claimed that were detected."""
        if not self.claimed_total:
            return None
        return (self.detected_total / self.claimed_total) * 100

    @property
    def collected_pct(self) -> float | None:
        """Percentage of detected that were collected."""
        if not self.detected_total:
            return None
        return (self.collected_total / self.detected_total) * 100

    @property
    def verified_pct(self) -> float | None:
        """Percentage of collected that were verified."""
        if not self.collected_total:
            return None
        return (self.verified_total / self.collected_total) * 100

    @property
    def refined_pct(self) -> float | None:
        """Percentage of verified that were refined."""
        if not self.verified_total:
            return None
        return (self.refined_total / self.verified_total) * 100

    @property
    def status(self) -> str:
        """Coverage status string."""
        if not self.has_claims:
            return "unknown"
        pct = self.detected_pct
        if pct and pct >= 90:
            return "good"
        if pct and pct >= 70:
            return "warning"
        return "critical"


@dataclass
class CoverageReport:
    """Full coverage report across all registries."""

    timestamp: str
    registries: dict[str, RegistryCoverage] = field(default_factory=dict)
    by_kind: dict[str, KindSummary] = field(default_factory=dict)
    total_claimed: int = 0
    total_detected: int = 0
    total_collected: int = 0
    total_verified: int = 0
    total_refined: int = 0
    # Legacy alias
    total_expected: int = 0
    alerts: list[str] = field(default_factory=list)

    @property
    def overall_coverage_pct(self) -> float | None:
        """Overall coverage percentage (collected/claimed)."""
        if self.total_claimed == 0:
            return None
        return (self.total_collected / self.total_claimed) * 100

    def add_registry(self, coverage: RegistryCoverage) -> None:
        """Add registry coverage to report."""
        self.registries[coverage.registry] = coverage

        # Accumulate totals
        self.total_detected += coverage.detected_total
        self.total_collected += coverage.collected_total
        self.total_verified += coverage.verified_total
        self.total_refined += coverage.refined_total

        if coverage.claimed_total is not None:
            self.total_claimed += coverage.claimed_total
            self.total_expected += coverage.claimed_total  # Legacy

        if coverage.discrepancy_alert and coverage.coverage_pct is not None:
            self.alerts.append(
                f"{coverage.registry}: collected {coverage.collected_total} "
                f"vs claimed {coverage.claimed_total} ({coverage.coverage_pct:.1f}%)"
            )


def load_registry_claims(path: Path | None = None) -> dict[str, Any]:
    """Load registry claims from JSON file.

    Args:
        path: Path to registry_claims.json (default: module directory)

    Returns:
        Dictionary with registry claims data
    """
    claims_path = path or DEFAULT_CLAIMS_FILE

    if not claims_path.exists():
        logger.warning(f"Registry claims file not found: {claims_path}")
        return {"registries": {}}

    with open(claims_path) as f:
        data = json.load(f)

    logger.debug(f"Loaded claims for {len(data.get('registries', {}))} registries")
    return data


def load_coverage_baseline(path: Path | None = None) -> dict[str, Any]:
    """Load coverage baseline from JSON file.

    Args:
        path: Path to coverage_baseline.json (default: module directory)

    Returns:
        Dictionary with baseline expectations
    """
    baseline_path = path or DEFAULT_BASELINE_FILE

    if not baseline_path.exists():
        logger.warning(f"Coverage baseline file not found: {baseline_path}")
        return {"baselines": {}, "global_settings": {}}

    with open(baseline_path) as f:
        data = json.load(f)

    logger.debug(f"Loaded baselines for {len(data.get('baselines', {}))} registries")
    return data


def get_registry_claim(registry: str, claims: dict[str, Any] | None = None) -> dict[str, Any]:
    """Get claims for a specific registry.

    Args:
        registry: Registry name
        claims: Pre-loaded claims data (loads from file if None)

    Returns:
        Dictionary with registry claims
    """
    if claims is None:
        claims = load_registry_claims()

    return claims.get("registries", {}).get(registry, {})


def get_kind_baseline(
    registry: str,
    kind: str,
    baselines: dict[str, Any] | None = None,
) -> dict[str, Any]:
    """Get baseline for a specific registry+kind combination.

    Args:
        registry: Registry name
        kind: Component kind
        baselines: Pre-loaded baseline data (loads from file if None)

    Returns:
        Dictionary with expected count and tolerance
    """
    if baselines is None:
        baselines = load_coverage_baseline()

    registry_baselines = baselines.get("baselines", {}).get(registry, {})
    return registry_baselines.get(kind, {})


@dataclass
class RegistryStats:
    """Statistics for a registry from collected data."""

    by_kind: dict[str, int] = field(default_factory=dict)
    total: int = 0
    unique_ids: int = 0  # Unique component IDs
    non_empty: int = 0  # Components with name and description
    duplicates: int = 0  # Duplicate IDs found
    # Per-kind tier metrics
    unique_by_kind: dict[str, int] = field(default_factory=dict)
    non_empty_by_kind: dict[str, int] = field(default_factory=dict)


def count_components_by_registry(
    output_file: Path,
) -> dict[str, dict[str, int]]:
    """Count collected components by registry and kind.

    Args:
        output_file: Path to NDJSON output file

    Returns:
        Nested dict: {registry: {kind: count}}
    """
    counts: dict[str, dict[str, int]] = {}

    if not output_file.exists():
        logger.warning(f"Output file not found: {output_file}")
        return counts

    with open(output_file) as f:
        for line in f:
            if line.strip():
                try:
                    comp = json.loads(line)
                    registry = comp.get("source_name", "unknown")
                    kind = comp.get("type", "unknown")

                    if registry not in counts:
                        counts[registry] = {}
                    counts[registry][kind] = counts[registry].get(kind, 0) + 1

                except json.JSONDecodeError:
                    pass

    return counts


def analyze_components_by_registry(
    output_file: Path,
) -> dict[str, RegistryStats]:
    """Analyze collected components with tier metrics.

    Computes:
    - collected: Total records in file
    - verified: Unique IDs (no duplicates)
    - refined: Unique IDs with non-empty name and description

    Args:
        output_file: Path to NDJSON output file

    Returns:
        Dict of {registry: RegistryStats}
    """
    stats: dict[str, RegistryStats] = {}

    if not output_file.exists():
        logger.warning(f"Output file not found: {output_file}")
        return stats

    # Track IDs per registry for deduplication
    registry_ids: dict[str, set[str]] = {}
    # Track IDs per registry+kind for per-kind deduplication
    registry_kind_ids: dict[str, dict[str, set[str]]] = {}

    with open(output_file) as f:
        for line in f:
            if line.strip():
                try:
                    comp = json.loads(line)
                    registry = comp.get("source_name", "unknown")
                    kind = comp.get("type", "unknown")
                    comp_id = comp.get("id", "")
                    name = comp.get("name", "")
                    description = comp.get("description", "")

                    # Initialize registry stats
                    if registry not in stats:
                        stats[registry] = RegistryStats()
                        registry_ids[registry] = set()
                        registry_kind_ids[registry] = {}

                    rs = stats[registry]

                    # Initialize kind tracking for this registry
                    if kind not in registry_kind_ids[registry]:
                        registry_kind_ids[registry][kind] = set()

                    # Count by kind
                    rs.by_kind[kind] = rs.by_kind.get(kind, 0) + 1
                    rs.total += 1

                    # Check for duplicates (registry-wide)
                    if comp_id in registry_ids[registry]:
                        rs.duplicates += 1
                    else:
                        registry_ids[registry].add(comp_id)
                        rs.unique_ids += 1

                        # Check if non-empty (has name and description)
                        if name and description:
                            rs.non_empty += 1

                    # Per-kind unique tracking
                    if comp_id not in registry_kind_ids[registry][kind]:
                        registry_kind_ids[registry][kind].add(comp_id)
                        rs.unique_by_kind[kind] = rs.unique_by_kind.get(kind, 0) + 1

                        # Per-kind non-empty tracking
                        if name and description:
                            rs.non_empty_by_kind[kind] = rs.non_empty_by_kind.get(kind, 0) + 1

                except json.JSONDecodeError:
                    pass

    return stats


def verify_registry_coverage(
    registry: str,
    collected_counts: dict[str, int],
    claims: dict[str, Any] | None = None,
    baselines: dict[str, Any] | None = None,
    registry_stats: RegistryStats | None = None,
) -> RegistryCoverage:
    """Verify coverage for a single registry.

    Args:
        registry: Registry name
        collected_counts: Dict of {kind: count} for collected components
        claims: Pre-loaded claims data
        baselines: Pre-loaded baseline data
        registry_stats: Optional detailed stats from analyze_components_by_registry

    Returns:
        RegistryCoverage with comparison results
    """
    if claims is None:
        claims = load_registry_claims()
    if baselines is None:
        baselines = load_coverage_baseline()

    registry_claim = claims.get("registries", {}).get(registry, {})
    registry_baseline = baselines.get("baselines", {}).get(registry, {})
    global_settings = baselines.get("global_settings", {})

    # Calculate totals
    collected_total = sum(collected_counts.values())
    claimed_total = registry_claim.get("claimed_total")

    # Tier metrics from stats
    if registry_stats:
        detected_total = collected_total  # For now, detected = collected
        verified_total = registry_stats.unique_ids
        refined_total = registry_stats.non_empty
    else:
        detected_total = collected_total
        verified_total = collected_total  # Assume all verified if no stats
        refined_total = collected_total  # Assume all refined if no stats

    # Calculate coverage percentage (collected/claimed)
    coverage_pct = None
    if claimed_total:
        coverage_pct = (collected_total / claimed_total) * 100

    # Check for discrepancy
    alert_threshold = global_settings.get("alert_threshold_pct", 10)
    discrepancy_alert = False
    if coverage_pct is not None and coverage_pct < (100 - alert_threshold):
        discrepancy_alert = True

    # Build per-kind coverage
    by_kind: dict[str, KindCoverage] = {}
    for kind, baseline in registry_baseline.items():
        expected = baseline.get("expected", 0)
        tolerance = baseline.get("tolerance", global_settings.get("default_tolerance", 0.20))
        min_acceptable = baseline.get("min_acceptable", int(expected * (1 - tolerance)))
        actual = collected_counts.get(kind, 0)

        kind_coverage_pct = (actual / expected * 100) if expected > 0 else 0
        within_tolerance = abs(actual - expected) / expected <= tolerance if expected > 0 else True

        by_kind[kind] = KindCoverage(
            kind=kind,
            expected=expected,
            actual=actual,
            coverage_pct=kind_coverage_pct,
            tolerance=tolerance,
            within_tolerance=within_tolerance,
            min_acceptable=min_acceptable,
        )

        # Alert if below minimum
        if actual < min_acceptable:
            discrepancy_alert = True

    return RegistryCoverage(
        registry=registry,
        claimed_total=claimed_total,
        detected_total=detected_total,
        collected_total=collected_total,
        verified_total=verified_total,
        refined_total=refined_total,
        coverage_pct=coverage_pct,
        by_kind=by_kind,
        discrepancy_alert=discrepancy_alert,
        notes=registry_claim.get("notes"),
    )


def aggregate_by_kind(
    report: CoverageReport,
    claims: dict[str, Any],
    stats: dict[str, RegistryStats],
) -> dict[str, KindSummary]:
    """Aggregate coverage data by component kind across all registries.

    Args:
        report: CoverageReport with per-registry data
        claims: Registry claims data
        stats: Per-registry statistics

    Returns:
        Dict of {kind: KindSummary}
    """
    summaries: dict[str, KindSummary] = {}

    for registry in report.registries:
        registry_claim = claims.get("registries", {}).get(registry, {})
        claimed_by_kind = registry_claim.get("claimed_by_kind") or {}
        registry_stats = stats.get(registry)

        if not registry_stats:
            continue

        # Get kinds from collected data
        for kind, count in registry_stats.by_kind.items():
            if kind not in summaries:
                summaries[kind] = KindSummary(kind=kind)

            s = summaries[kind]
            s.collected_total += count
            s.detected_total += count  # For now, detected = collected
            s.registries.append(registry)

            # Add claimed if available
            if kind in claimed_by_kind:
                s.claimed_total += claimed_by_kind[kind]

            # Add verified/refined from stats
            s.verified_total += registry_stats.unique_by_kind.get(kind, 0)
            s.refined_total += registry_stats.non_empty_by_kind.get(kind, 0)

    return summaries


def generate_coverage_report(
    output_file: Path,
    claims_file: Path | None = None,
    baseline_file: Path | None = None,
) -> CoverageReport:
    """Generate full coverage report comparing collected vs expected.

    Args:
        output_file: Path to NDJSON output file with collected components
        claims_file: Path to registry_claims.json
        baseline_file: Path to coverage_baseline.json

    Returns:
        CoverageReport with all registry comparisons
    """
    claims = load_registry_claims(claims_file)
    baselines = load_coverage_baseline(baseline_file)

    # Count and analyze collected components
    collected = count_components_by_registry(output_file)
    stats = analyze_components_by_registry(output_file)

    # Create report
    report = CoverageReport(
        timestamp=datetime.now(UTC).isoformat(),
    )

    # Get all registries from claims, collected, and baseline
    all_registries = (
        set(collected.keys())
        | set(baselines.get("baselines", {}).keys())
        | set(claims.get("registries", {}).keys())
    )

    for registry in sorted(all_registries):
        registry_counts = collected.get(registry, {})
        registry_stats = stats.get(registry)
        coverage = verify_registry_coverage(
            registry=registry,
            collected_counts=registry_counts,
            claims=claims,
            baselines=baselines,
            registry_stats=registry_stats,
        )
        report.add_registry(coverage)

    # Aggregate by component kind
    report.by_kind = aggregate_by_kind(report, claims, stats)

    return report, claims, stats


def generate_and_print_coverage_report(
    output_file: Path,
    claims_file: Path | None = None,
    baseline_file: Path | None = None,
    kinds_filter: set[str] | None = None,
) -> CoverageReport:
    """Generate and print full coverage report with per-kind breakdowns.

    Args:
        output_file: Path to NDJSON output file with collected components
        claims_file: Path to registry_claims.json
        baseline_file: Path to coverage_baseline.json
        kinds_filter: Optional set of kinds to filter per-kind tables (None = all)

    Returns:
        CoverageReport (also prints to console)
    """
    report, claims, stats = generate_coverage_report(output_file, claims_file, baseline_file)
    print_coverage_report(report, kinds_filter=kinds_filter, claims=claims, stats=stats)
    return report


def _format_tier_cell(count: int, pct: float | None) -> Text:
    """Format a tier cell with count and percentage."""
    if pct is None:
        return Text(f"{count:,}", style="dim")

    # Color based on percentage
    if pct >= 90:
        color = "green"
    elif pct >= 70:
        color = "yellow"
    elif pct >= 50:
        color = "orange1"
    else:
        color = "red"

    text = Text()
    text.append(f"{count:,}", style="bold")
    text.append(f" ({pct:.0f}%)", style=color)
    return text


def _status_text(status: str) -> Text:
    """Format status with appropriate color and icon."""
    status_map = {
        "good": ("✓", "green"),
        "warning": ("!", "yellow"),
        "critical": ("✗", "red"),
        "alert": ("⚠", "red bold"),
        "unknown": ("?", "dim"),
    }
    icon, style = status_map.get(status, ("?", "dim"))
    return Text(icon, style=style)


def format_coverage_report(report: CoverageReport, verbose: bool = False) -> str:
    """Format coverage report as a rich table.

    Args:
        report: CoverageReport to format
        verbose: Include per-kind details

    Returns:
        Formatted report string (for compatibility; use print_coverage_report for color)
    """
    console = Console(force_terminal=True, width=120)

    # Create the main table
    table = Table(
        title=f"Coverage Report - {report.timestamp[:10]}",
        show_header=True,
        header_style="bold cyan",
        border_style="dim",
        title_style="bold",
    )

    # Add columns
    table.add_column("", justify="center", width=3)  # Status icon
    table.add_column("Registry", style="bold", min_width=25)
    table.add_column("Claimed", justify="right", min_width=10)
    table.add_column("Detected", justify="right", min_width=14)
    table.add_column("Collected", justify="right", min_width=14)
    table.add_column("Verified", justify="right", min_width=14)
    table.add_column("Refined", justify="right", min_width=14)

    # Add rows for each registry
    for registry, cov in sorted(report.registries.items()):
        # Status icon
        status = _status_text(cov.status)

        # Claimed column
        if cov.claimed_total is not None:
            claimed = Text(f"{cov.claimed_total:,}", style="cyan")
        else:
            claimed = Text("-", style="dim")

        # Detected column (detected/claimed %)
        detected = _format_tier_cell(cov.detected_total, cov.detected_pct)

        # Collected column (collected/detected %)
        collected = _format_tier_cell(cov.collected_total, cov.collected_pct)

        # Verified column (verified/collected %)
        verified = _format_tier_cell(cov.verified_total, cov.verified_pct)

        # Refined column (refined/verified %)
        refined = _format_tier_cell(cov.refined_total, cov.refined_pct)

        table.add_row(status, registry, claimed, detected, collected, verified, refined)

    # Add totals row
    table.add_section()
    total_detected_pct = (report.total_detected / report.total_claimed * 100) if report.total_claimed else None
    total_collected_pct = (report.total_collected / report.total_detected * 100) if report.total_detected else None
    total_verified_pct = (report.total_verified / report.total_collected * 100) if report.total_collected else None
    total_refined_pct = (report.total_refined / report.total_verified * 100) if report.total_verified else None

    table.add_row(
        Text("Σ", style="bold"),
        Text("TOTAL", style="bold"),
        Text(f"{report.total_claimed:,}", style="bold cyan"),
        _format_tier_cell(report.total_detected, total_detected_pct),
        _format_tier_cell(report.total_collected, total_collected_pct),
        _format_tier_cell(report.total_verified, total_verified_pct),
        _format_tier_cell(report.total_refined, total_refined_pct),
    )

    # Render to string
    with console.capture() as capture:
        console.print()
        console.print(table)

        # Print alerts if any
        if report.alerts:
            console.print()
            console.print("[bold red]ALERTS[/bold red]")
            for alert in report.alerts:
                console.print(f"  [red]⚠[/red] {alert}")

        console.print()

    return capture.get()


@dataclass
class RegistryKindMetrics:
    """Per-registry per-kind metrics for filtered tables."""

    registry: str
    kind: str
    claimed: int = 0
    detected: int = 0
    collected: int = 0
    verified: int = 0
    refined: int = 0

    @property
    def detected_pct(self) -> float | None:
        if not self.claimed:
            return None
        return (self.detected / self.claimed) * 100

    @property
    def collected_pct(self) -> float | None:
        if not self.detected:
            return None
        return (self.collected / self.detected) * 100

    @property
    def verified_pct(self) -> float | None:
        if not self.collected:
            return None
        return (self.verified / self.collected) * 100

    @property
    def refined_pct(self) -> float | None:
        if not self.verified:
            return None
        return (self.refined / self.verified) * 100

    @property
    def status(self) -> str:
        if not self.claimed:
            return "unknown"
        pct = self.detected_pct
        if pct and pct >= 90:
            return "good"
        if pct and pct >= 70:
            return "warning"
        return "critical"


def get_registry_kind_metrics(
    registry: str,
    kind: str,
    claims: dict[str, Any],
    stats: dict[str, RegistryStats],
) -> RegistryKindMetrics:
    """Get metrics for a specific registry+kind combination."""
    registry_claim = claims.get("registries", {}).get(registry, {})
    claimed_by_kind = registry_claim.get("claimed_by_kind") or {}
    registry_stats = stats.get(registry)

    metrics = RegistryKindMetrics(registry=registry, kind=kind)

    if kind in claimed_by_kind:
        metrics.claimed = claimed_by_kind[kind]

    if registry_stats:
        metrics.collected = registry_stats.by_kind.get(kind, 0)
        metrics.detected = metrics.collected  # For now, detected = collected
        metrics.verified = registry_stats.unique_by_kind.get(kind, 0)
        metrics.refined = registry_stats.non_empty_by_kind.get(kind, 0)

    return metrics


def print_kind_table(
    kind: str,
    report: CoverageReport,
    claims: dict[str, Any],
    stats: dict[str, RegistryStats],
    console: Console,
) -> None:
    """Print a registry table filtered to a specific component kind.

    Args:
        kind: Component kind to filter by
        report: CoverageReport with registry data
        claims: Registry claims data
        stats: Per-registry statistics
        console: Console instance
    """
    # Create table for this kind
    table = Table(
        title=f"Coverage: {kind}",
        show_header=True,
        header_style="bold magenta",
        border_style="dim",
        title_style="bold",
    )

    # Add columns
    table.add_column("", justify="center", width=3)  # Status icon
    table.add_column("Registry", style="bold", min_width=25)
    table.add_column("Claimed", justify="right", min_width=10)
    table.add_column("Detected", justify="right", min_width=14)
    table.add_column("Collected", justify="right", min_width=14)
    table.add_column("Verified", justify="right", min_width=14)
    table.add_column("Refined", justify="right", min_width=14)

    # Track totals
    total_claimed = 0
    total_detected = 0
    total_collected = 0
    total_verified = 0
    total_refined = 0
    has_data = False

    # Add rows for each registry that has this kind
    for registry in sorted(report.registries.keys()):
        metrics = get_registry_kind_metrics(registry, kind, claims, stats)

        # Skip registries with no data for this kind
        if metrics.collected == 0 and metrics.claimed == 0:
            continue

        has_data = True
        status = _status_text(metrics.status)
        claimed = Text(f"{metrics.claimed:,}", style="magenta") if metrics.claimed else Text("-", style="dim")
        detected = _format_tier_cell(metrics.detected, metrics.detected_pct)
        collected = _format_tier_cell(metrics.collected, metrics.collected_pct)
        verified = _format_tier_cell(metrics.verified, metrics.verified_pct)
        refined = _format_tier_cell(metrics.refined, metrics.refined_pct)

        table.add_row(status, registry, claimed, detected, collected, verified, refined)

        # Accumulate totals
        total_claimed += metrics.claimed
        total_detected += metrics.detected
        total_collected += metrics.collected
        total_verified += metrics.verified
        total_refined += metrics.refined

    if not has_data:
        return  # Skip kinds with no data

    # Add totals row
    table.add_section()
    total_detected_pct = (total_detected / total_claimed * 100) if total_claimed else None
    total_collected_pct = (total_collected / total_detected * 100) if total_detected else None
    total_verified_pct = (total_verified / total_collected * 100) if total_collected else None
    total_refined_pct = (total_refined / total_verified * 100) if total_verified else None

    table.add_row(
        Text("Σ", style="bold"),
        Text("TOTAL", style="bold"),
        Text(f"{total_claimed:,}", style="bold magenta"),
        _format_tier_cell(total_detected, total_detected_pct),
        _format_tier_cell(total_collected, total_collected_pct),
        _format_tier_cell(total_verified, total_verified_pct),
        _format_tier_cell(total_refined, total_refined_pct),
    )

    console.print()
    console.print(table)


def print_coverage_report(
    report: CoverageReport,
    verbose: bool = False,
    kinds_filter: set[str] | None = None,
    claims: dict[str, Any] | None = None,
    stats: dict[str, RegistryStats] | None = None,
) -> None:
    """Print coverage report directly to console with colors.

    Args:
        report: CoverageReport to print
        verbose: Include per-kind details
        kinds_filter: Optional set of kinds to filter per-kind tables (None = all)
        claims: Registry claims data (for per-kind tables)
        stats: Per-registry statistics (for per-kind tables)
    """
    console = Console()

    # Create the registry table (all kinds combined)
    table = Table(
        title=f"Coverage by Registry (All Kinds) - {report.timestamp[:10]}",
        show_header=True,
        header_style="bold cyan",
        border_style="dim",
        title_style="bold",
    )

    # Add columns
    table.add_column("", justify="center", width=3)  # Status icon
    table.add_column("Registry", style="bold", min_width=25)
    table.add_column("Claimed", justify="right", min_width=10)
    table.add_column("Detected", justify="right", min_width=14)
    table.add_column("Collected", justify="right", min_width=14)
    table.add_column("Verified", justify="right", min_width=14)
    table.add_column("Refined", justify="right", min_width=14)

    # Add rows for each registry
    for registry, cov in sorted(report.registries.items()):
        status = _status_text(cov.status)
        claimed = Text(f"{cov.claimed_total:,}", style="cyan") if cov.claimed_total else Text("-", style="dim")
        detected = _format_tier_cell(cov.detected_total, cov.detected_pct)
        collected = _format_tier_cell(cov.collected_total, cov.collected_pct)
        verified = _format_tier_cell(cov.verified_total, cov.verified_pct)
        refined = _format_tier_cell(cov.refined_total, cov.refined_pct)

        table.add_row(status, registry, claimed, detected, collected, verified, refined)

    # Add totals row
    table.add_section()
    total_detected_pct = (report.total_detected / report.total_claimed * 100) if report.total_claimed else None
    total_collected_pct = (report.total_collected / report.total_detected * 100) if report.total_detected else None
    total_verified_pct = (report.total_verified / report.total_collected * 100) if report.total_collected else None
    total_refined_pct = (report.total_refined / report.total_verified * 100) if report.total_verified else None

    table.add_row(
        Text("Σ", style="bold"),
        Text("TOTAL", style="bold"),
        Text(f"{report.total_claimed:,}", style="bold cyan"),
        _format_tier_cell(report.total_detected, total_detected_pct),
        _format_tier_cell(report.total_collected, total_collected_pct),
        _format_tier_cell(report.total_verified, total_verified_pct),
        _format_tier_cell(report.total_refined, total_refined_pct),
    )

    console.print()
    console.print(table)

    # Print per-kind tables if we have the data
    if report.by_kind and claims is not None and stats is not None:
        # Get all kinds from collected data
        all_kinds = set(report.by_kind.keys())

        # Apply filter if specified
        if kinds_filter:
            all_kinds = all_kinds & kinds_filter

        # Print a table for each kind
        for kind in sorted(all_kinds):
            print_kind_table(kind, report, claims, stats, console)

    # Print alerts
    if report.alerts:
        console.print()
        console.print("[bold red]ALERTS[/bold red]")
        for alert in report.alerts:
            console.print(f"  [red]⚠[/red] {alert}")

    console.print()


def save_coverage_report(report: CoverageReport, output_file: Path) -> None:
    """Save coverage report as JSON.

    Args:
        report: CoverageReport to save
        output_file: Path to output JSON file
    """
    # Convert dataclasses to dicts
    data = {
        "timestamp": report.timestamp,
        "totals": {
            "claimed": report.total_claimed,
            "detected": report.total_detected,
            "collected": report.total_collected,
            "verified": report.total_verified,
            "refined": report.total_refined,
        },
        "overall_coverage_pct": report.overall_coverage_pct,
        "alerts": report.alerts,
        "registries": {},
        "by_kind": {},
    }

    for registry, cov in report.registries.items():
        data["registries"][registry] = {
            "claimed_total": cov.claimed_total,
            "detected_total": cov.detected_total,
            "collected_total": cov.collected_total,
            "verified_total": cov.verified_total,
            "refined_total": cov.refined_total,
            "coverage_pct": cov.coverage_pct,
            "detected_pct": cov.detected_pct,
            "collected_pct": cov.collected_pct,
            "verified_pct": cov.verified_pct,
            "refined_pct": cov.refined_pct,
            "status": cov.status,
            "discrepancy_alert": cov.discrepancy_alert,
            "notes": cov.notes,
            "by_kind": {
                kind: {
                    "expected": kc.expected,
                    "actual": kc.actual,
                    "coverage_pct": kc.coverage_pct,
                    "tolerance": kc.tolerance,
                    "within_tolerance": kc.within_tolerance,
                    "min_acceptable": kc.min_acceptable,
                }
                for kind, kc in cov.by_kind.items()
            },
        }

    # Add aggregated by_kind summaries
    for kind, summary in report.by_kind.items():
        data["by_kind"][kind] = {
            "claimed_total": summary.claimed_total,
            "detected_total": summary.detected_total,
            "collected_total": summary.collected_total,
            "verified_total": summary.verified_total,
            "refined_total": summary.refined_total,
            "detected_pct": summary.detected_pct,
            "collected_pct": summary.collected_pct,
            "verified_pct": summary.verified_pct,
            "refined_pct": summary.refined_pct,
            "status": summary.status,
            "registries": summary.registries,
        }

    with open(output_file, "w") as f:
        json.dump(data, f, indent=2)

    logger.info(f"Coverage report saved to {output_file}")
