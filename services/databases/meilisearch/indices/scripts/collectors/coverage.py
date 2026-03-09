"""
Coverage tracking and comparison utilities.

Provides functionality to:
- Load registry claims and coverage baselines
- Compare collected counts against claims
- Generate coverage reports
"""

from __future__ import annotations

import json
import logging
from dataclasses import dataclass, field
from datetime import UTC, datetime
from pathlib import Path
from typing import Any

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
    """Coverage metrics for a single registry."""

    registry: str
    claimed_total: int | None
    collected_total: int
    coverage_pct: float | None
    by_kind: dict[str, KindCoverage] = field(default_factory=dict)
    discrepancy_alert: bool = False
    notes: str | None = None

    @property
    def has_claims(self) -> bool:
        """Whether the registry has claimed totals."""
        return self.claimed_total is not None

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
class CoverageReport:
    """Full coverage report across all registries."""

    timestamp: str
    registries: dict[str, RegistryCoverage] = field(default_factory=dict)
    total_expected: int = 0
    total_collected: int = 0
    alerts: list[str] = field(default_factory=list)

    @property
    def overall_coverage_pct(self) -> float | None:
        """Overall coverage percentage."""
        if self.total_expected == 0:
            return None
        return (self.total_collected / self.total_expected) * 100

    def add_registry(self, coverage: RegistryCoverage) -> None:
        """Add registry coverage to report."""
        self.registries[coverage.registry] = coverage
        self.total_collected += coverage.collected_total

        if coverage.claimed_total is not None:
            self.total_expected += coverage.claimed_total

        if coverage.discrepancy_alert:
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


def verify_registry_coverage(
    registry: str,
    collected_counts: dict[str, int],
    claims: dict[str, Any] | None = None,
    baselines: dict[str, Any] | None = None,
) -> RegistryCoverage:
    """Verify coverage for a single registry.

    Args:
        registry: Registry name
        collected_counts: Dict of {kind: count} for collected components
        claims: Pre-loaded claims data
        baselines: Pre-loaded baseline data

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

    # Calculate coverage percentage
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
        collected_total=collected_total,
        coverage_pct=coverage_pct,
        by_kind=by_kind,
        discrepancy_alert=discrepancy_alert,
        notes=registry_claim.get("notes"),
    )


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

    # Count collected components
    collected = count_components_by_registry(output_file)

    # Create report
    report = CoverageReport(
        timestamp=datetime.now(UTC).isoformat(),
    )

    # Get all registries from both collected and baseline
    all_registries = set(collected.keys()) | set(baselines.get("baselines", {}).keys())

    for registry in sorted(all_registries):
        registry_counts = collected.get(registry, {})
        coverage = verify_registry_coverage(
            registry=registry,
            collected_counts=registry_counts,
            claims=claims,
            baselines=baselines,
        )
        report.add_registry(coverage)

    return report


def format_coverage_report(report: CoverageReport, verbose: bool = False) -> str:
    """Format coverage report as human-readable text.

    Args:
        report: CoverageReport to format
        verbose: Include per-kind details

    Returns:
        Formatted report string
    """
    lines = [
        "=" * 60,
        "COVERAGE REPORT",
        f"Generated: {report.timestamp}",
        "=" * 60,
        "",
    ]

    # Summary
    lines.append("SUMMARY")
    lines.append("-" * 40)
    lines.append(f"Total Collected: {report.total_collected:,}")
    lines.append(f"Total Expected:  {report.total_expected:,}")
    if report.overall_coverage_pct is not None:
        lines.append(f"Overall Coverage: {report.overall_coverage_pct:.1f}%")
    lines.append(f"Alerts: {len(report.alerts)}")
    lines.append("")

    # Alerts
    if report.alerts:
        lines.append("ALERTS")
        lines.append("-" * 40)
        for alert in report.alerts:
            lines.append(f"  [!] {alert}")
        lines.append("")

    # Per-registry details
    lines.append("REGISTRIES")
    lines.append("-" * 40)

    for registry, coverage in sorted(report.registries.items()):
        status_icon = {
            "good": "[ok]",
            "warning": "[!]",
            "critical": "[!!]",
            "alert": "[!!]",
            "unknown": "[?]",
        }.get(coverage.status, "[?]")

        if coverage.has_claims:
            lines.append(
                f"{status_icon} {registry}: {coverage.collected_total:,}/{coverage.claimed_total:,} "
                f"({coverage.coverage_pct:.1f}%)"
            )
        else:
            lines.append(f"{status_icon} {registry}: {coverage.collected_total:,} (no claims)")

        if verbose and coverage.by_kind:
            for kind, kind_cov in sorted(coverage.by_kind.items()):
                tol_status = "ok" if kind_cov.within_tolerance else "FAIL"
                lines.append(
                    f"       {kind}: {kind_cov.actual:,}/{kind_cov.expected:,} "
                    f"({kind_cov.coverage_pct:.1f}%) [{tol_status}]"
                )

    lines.append("")
    lines.append("=" * 60)

    return "\n".join(lines)


def save_coverage_report(report: CoverageReport, output_file: Path) -> None:
    """Save coverage report as JSON.

    Args:
        report: CoverageReport to save
        output_file: Path to output JSON file
    """
    # Convert dataclasses to dicts
    data = {
        "timestamp": report.timestamp,
        "total_expected": report.total_expected,
        "total_collected": report.total_collected,
        "overall_coverage_pct": report.overall_coverage_pct,
        "alerts": report.alerts,
        "registries": {},
    }

    for registry, coverage in report.registries.items():
        data["registries"][registry] = {
            "claimed_total": coverage.claimed_total,
            "collected_total": coverage.collected_total,
            "coverage_pct": coverage.coverage_pct,
            "status": coverage.status,
            "discrepancy_alert": coverage.discrepancy_alert,
            "notes": coverage.notes,
            "by_kind": {
                kind: {
                    "expected": kc.expected,
                    "actual": kc.actual,
                    "coverage_pct": kc.coverage_pct,
                    "tolerance": kc.tolerance,
                    "within_tolerance": kc.within_tolerance,
                    "min_acceptable": kc.min_acceptable,
                }
                for kind, kc in coverage.by_kind.items()
            },
        }

    with open(output_file, "w") as f:
        json.dump(data, f, indent=2)

    logger.info(f"Coverage report saved to {output_file}")
