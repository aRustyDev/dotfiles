#!/usr/bin/env python3
"""
Modular component collector for Claude Code registries.

Collects components (skills, agents, MCP servers, plugins) from various
registries using different collection methods (API, scrape, browser, search).

Usage:
    # Collect all types from all registries
    ./collect.py --kinds all

    # Collect specific types
    ./collect.py --kinds mcp_server,skill

    # Collect from specific registry
    ./collect.py --registry smithery.ai --kinds mcp_server

    # Resume interrupted crawl
    ./collect.py --registry smithery.ai --resume

    # Search-based discovery
    ./collect.py --search "mcp server filesystem" --kinds mcp_server

    # Dry run
    ./collect.py --registry smithery.ai --dry-run

    # Show progress
    ./collect.py --stats
"""

from __future__ import annotations

import argparse
import asyncio
import json
import logging
import sys
from datetime import UTC, datetime
from pathlib import Path
from typing import TYPE_CHECKING

# Add parent directory to path for imports
SCRIPT_DIR = Path(__file__).parent
sys.path.insert(0, str(SCRIPT_DIR))

from collectors.base import COMPONENT_KINDS, BaseCollector, CollectResult
from collectors.coverage import (
    generate_coverage_report,
    format_coverage_report,
    save_coverage_report,
    DEFAULT_CLAIMS_FILE,
    DEFAULT_BASELINE_FILE,
)
from collectors.detection import (
    detect_new_by_registry,
    format_detection_report,
    generate_detection_report,
    backup_current_collection,
)
from collectors.state import CrawlState
from collectors.registries import (
    REGISTRY_COLLECTORS,
    REGISTRY_KINDS,
    AWESOME_COLLECTORS,
    BuildWithClaudeCollector,
    ClaudeMarketplacesCollector,
    GitHubCollector,
    MCPServersCollector,
    MCPSoCollector,
    SkillsmpCollector,
    SmitheryCollector,
)

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
logger = logging.getLogger(__name__)

# Default paths
DEFAULT_OUTPUT_DIR = SCRIPT_DIR.parent / "raw"
STATE_FILE = DEFAULT_OUTPUT_DIR / ".collector-state.json"


def get_output_file(registry_name: str, output_dir: Path) -> Path:
    """Get bronze output file path for a registry."""
    # Sanitize registry name for filename
    safe_name = registry_name.replace(":", "-").replace("/", "-").replace(".", "-")
    return output_dir / f"{safe_name}-bronze.ndjson"


def get_all_collectors() -> list[type[BaseCollector]]:
    """Get list of all available collector classes."""
    collectors = [
        SmitheryCollector,
        MCPServersCollector,
        SkillsmpCollector,
        GitHubCollector,
        BuildWithClaudeCollector,
        ClaudeMarketplacesCollector,
        MCPSoCollector,
    ]
    collectors.extend(AWESOME_COLLECTORS)
    return collectors


def filter_collectors_by_kinds(
    collectors: list[type[BaseCollector]],
    kinds: set[str],
) -> list[type[BaseCollector]]:
    """Filter collectors to those supporting requested kinds."""
    return [c for c in collectors if c.supported_kinds & kinds]


def filter_collectors_by_registry(
    collectors: list[type[BaseCollector]],
    registry: str,
) -> list[type[BaseCollector]]:
    """Filter to specific registry."""
    return [c for c in collectors if c.registry_name == registry]


async def collect_registry(
    collector_class: type[BaseCollector],
    kinds: set[str] | None,
    state: CrawlState,
    output_dir: Path,
    dry_run: bool = False,
) -> CollectResult:
    """Run collection for a single registry."""
    collector = collector_class()
    output_file = get_output_file(collector.registry_name, output_dir)

    logger.info(f"=== {collector.registry_name} ===")

    try:
        async with collector:
            result = await collector.collect(
                kinds=kinds,
                state=state,
                output_file=output_file,
                dry_run=dry_run,
            )
    except Exception as e:
        logger.error(f"{collector.registry_name}: {e}")
        state.mark_failed(collector.registry_name, str(e))
        return CollectResult(errors=[str(e)])

    if result.skipped:
        logger.info(f"{collector.registry_name}: skipped ({result.reason})")
    else:
        logger.info(
            f"{collector.registry_name}: collected {result.total} components "
            f"(new: {result.new_count}, dup: {result.duplicate_count})"
        )

    return result


async def collect_all(
    collectors: list[type[BaseCollector]],
    kinds: set[str] | None,
    state: CrawlState,
    output_dir: Path,
    dry_run: bool = False,
    parallel: int = 3,
) -> dict[str, CollectResult]:
    """Run collection for multiple registries.

    Args:
        collectors: List of collector classes to run
        kinds: Component kinds to collect
        state: Crawl state for checkpointing
        output_dir: Output directory for bronze files
        dry_run: If True, don't actually fetch
        parallel: Max concurrent collectors

    Returns:
        Dict mapping registry name to result
    """
    semaphore = asyncio.Semaphore(parallel)

    async def bounded_collect(collector_class):
        async with semaphore:
            return await collect_registry(
                collector_class, kinds, state, output_dir, dry_run
            )

    tasks = [bounded_collect(c) for c in collectors]
    results = await asyncio.gather(*tasks, return_exceptions=True)

    return {
        collectors[i].registry_name: (
            results[i] if isinstance(results[i], CollectResult)
            else CollectResult(errors=[str(results[i])])
        )
        for i in range(len(collectors))
    }


async def search_components(
    query: str,
    kinds: set[str] | None,
    output_dir: Path,
    searxng_url: str = "http://localhost:8888/search",
) -> CollectResult:
    """Search for components via SearXNG."""
    from collectors.methods.search import SearchCollector

    collector = SearchCollector(searxng_url=searxng_url)
    output_file = output_dir / "search-bronze.ndjson"

    logger.info(f"Searching: {query}")

    async with collector:
        components = await collector.search(query, max_results=50)

        # Filter by kinds
        if kinds:
            components = [c for c in components if collector.infer_kind(c) in kinds]

        # Transform and write
        result = CollectResult(components=components, new_count=len(components))

        if components:
            with open(output_file, "a") as f:
                for comp in components:
                    transformed = collector.transform(comp)
                    f.write(json.dumps(transformed) + "\n")

    logger.info(f"Found {len(components)} components via search")
    return result


def print_stats(state: CrawlState) -> None:
    """Print crawl statistics."""
    print("\n=== Collection Statistics ===\n")
    print(f"Started: {state.started_at}")
    print(f"Updated: {state.last_updated}")

    total = 0
    completed = 0
    in_progress = 0
    failed = 0

    print("\n--- Registries ---")
    for name, reg_state in sorted(state.registries.items()):
        status = reg_state.status
        fetched = reg_state.total_fetched
        total += fetched

        status_icon = {
            "completed": "[+]",
            "in_progress": "[~]",
            "failed": "[x]",
            "pending": "[ ]",
        }.get(status, "[ ]")

        print(f"  {status_icon} {name}: {fetched} fetched ({status})")

        if status == "completed":
            completed += 1
        elif status == "in_progress":
            in_progress += 1
        elif status == "failed":
            failed += 1

    print("\n--- Summary ---")
    print(f"Total components: {total}")
    print(f"Registries: {completed} completed, {in_progress} in progress, {failed} failed")
    print(f"Failures logged: {len(state.failures)}")

    if state.failures:
        print("\n--- Recent Failures ---")
        for f in state.failures[-5:]:
            url = f.get("url", "unknown")[:60]
            error = f.get("error", "unknown")
            print(f"  {url}... ({error})")


def validate_kinds(kinds_str: str) -> set[str]:
    """Parse and validate --kinds argument."""
    if kinds_str.lower() == "all":
        return COMPONENT_KINDS.copy()

    kinds = {k.strip() for k in kinds_str.split(",")}
    invalid = kinds - COMPONENT_KINDS

    if invalid:
        logger.error(f"Invalid kinds: {invalid}")
        logger.error(f"Valid kinds: {sorted(COMPONENT_KINDS)}")
        sys.exit(1)

    return kinds


def main():
    parser = argparse.ArgumentParser(
        description="Collect Claude Code components from registries",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  collect.py --kinds all                    Collect all types from all registries
  collect.py --kinds mcp_server,skill       Collect specific types
  collect.py --registry smithery.ai         Collect from specific registry
  collect.py --registry github --resume     Resume interrupted crawl
  collect.py --search "mcp filesystem"      Search for components
  collect.py --stats                        Show collection progress
        """,
    )

    parser.add_argument(
        "--kinds",
        type=str,
        default="all",
        help="Component kinds to collect (comma-separated or 'all')",
    )
    parser.add_argument(
        "--registry",
        type=str,
        help="Specific registry to collect from",
    )
    parser.add_argument(
        "--search",
        type=str,
        help="Search query for SearXNG discovery",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=DEFAULT_OUTPUT_DIR,
        help="Output directory for bronze files",
    )
    parser.add_argument(
        "--resume",
        action="store_true",
        help="Resume from last checkpoint",
    )
    parser.add_argument(
        "--stats",
        action="store_true",
        help="Show collection statistics",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be collected without fetching",
    )
    parser.add_argument(
        "--parallel",
        type=int,
        default=3,
        help="Max parallel registry collections",
    )
    parser.add_argument(
        "--searxng-url",
        type=str,
        default="http://localhost:8888/search",
        help="SearXNG instance URL",
    )
    parser.add_argument(
        "--list-registries",
        action="store_true",
        help="List available registries and exit",
    )
    parser.add_argument(
        "-v", "--verbose",
        action="store_true",
        help="Enable debug logging",
    )
    parser.add_argument(
        "--coverage-report",
        action="store_true",
        help="Generate coverage comparison report",
    )
    parser.add_argument(
        "--coverage-report-json",
        type=Path,
        help="Save coverage report as JSON to file",
    )
    parser.add_argument(
        "--detect-new",
        action="store_true",
        help="Detect new components since last collection",
    )
    parser.add_argument(
        "--backup-collection",
        action="store_true",
        help="Backup current collection for future comparison",
    )
    parser.add_argument(
        "--previous-dir",
        type=Path,
        help="Directory containing previous collection for comparison",
    )

    args = parser.parse_args()

    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)

    # List registries
    if args.list_registries:
        print("Available registries:")
        for collector in get_all_collectors():
            kinds = ", ".join(sorted(collector.supported_kinds))
            print(f"  {collector.registry_name}: {kinds}")
        return

    # Ensure output directory exists
    args.output.mkdir(parents=True, exist_ok=True)

    # Load state
    state_file = args.output / ".collector-state.json"
    state = CrawlState.load(state_file)

    # Show stats
    if args.stats:
        print_stats(state)
        return

    # Coverage report
    if args.coverage_report or args.coverage_report_json:
        # Find all bronze files for coverage calculation
        bronze_files = list(args.output.glob("*-bronze.ndjson"))
        if not bronze_files:
            logger.error(f"No bronze files found in {args.output}")
            sys.exit(1)

        # Create combined file for analysis (temporary)
        combined_file = args.output / ".coverage-combined.ndjson"
        with open(combined_file, "w") as out:
            for bronze_file in bronze_files:
                with open(bronze_file) as f:
                    out.write(f.read())

        # Generate report
        report = generate_coverage_report(combined_file)

        # Output text report
        print(format_coverage_report(report, verbose=args.verbose))

        # Save JSON if requested
        if args.coverage_report_json:
            save_coverage_report(report, args.coverage_report_json)
            logger.info(f"Coverage report saved to {args.coverage_report_json}")

        # Cleanup temp file
        combined_file.unlink()
        return

    # Detect new components
    if args.detect_new:
        previous_dir = args.previous_dir or args.output / ".previous"
        result = detect_new_by_registry(args.output, previous_dir)

        # Print report
        print(format_detection_report(result, verbose=args.verbose))

        # Generate JSON report
        if result.total_new > 0:
            report_file = generate_detection_report(result, args.output)
            logger.info(f"Detection report saved to {report_file}")

        return

    # Backup collection for future comparison
    if args.backup_collection:
        backup_dir = backup_current_collection(args.output)
        logger.info(f"Collection backed up to {backup_dir}")
        return

    # Parse kinds
    kinds = validate_kinds(args.kinds)
    logger.info(f"Collecting kinds: {sorted(kinds)}")

    # Search mode
    if args.search:
        asyncio.run(search_components(
            args.search,
            kinds,
            args.output,
            args.searxng_url,
        ))
        return

    # Get collectors
    collectors = get_all_collectors()

    # Filter by registry if specified
    if args.registry:
        collectors = filter_collectors_by_registry(collectors, args.registry)
        if not collectors:
            logger.error(f"Unknown registry: {args.registry}")
            logger.error("Use --list-registries to see available registries")
            sys.exit(1)

    # Filter by kinds
    collectors = filter_collectors_by_kinds(collectors, kinds)

    if not collectors:
        logger.error("No registries support the requested kinds")
        sys.exit(1)

    logger.info(f"Running {len(collectors)} collector(s)")

    # Run collection
    results = asyncio.run(collect_all(
        collectors,
        kinds,
        state,
        args.output,
        dry_run=args.dry_run,
        parallel=args.parallel,
    ))

    # Summary
    total_new = sum(r.new_count for r in results.values() if r.success)
    total_errors = sum(len(r.errors) for r in results.values())

    print("\n=== Collection Complete ===")
    print(f"New components: {total_new}")
    print(f"Errors: {total_errors}")

    # Save state
    state.save()


if __name__ == "__main__":
    main()
