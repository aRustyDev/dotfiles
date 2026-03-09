"""
Modular component collector framework.

This package provides a unified interface for collecting Claude Code components
from various registries, supporting multiple collection methods:

- API: HTTP JSON APIs (httpx)
- Scrape: HTML parsing (Scrapling)
- Browser: JS rendering (crawl4ai, Playwright)
- Readme: Awesome list parsing (BeautifulSoup)
- Search: SearXNG discovery

Example usage:
    from collectors import SmitheryCollector, collect_all
    from collectors.state import CrawlState

    state = CrawlState.load()
    collector = SmitheryCollector()
    result = await collector.collect(kinds={"mcp_server"}, state=state)
"""

from collectors.base import BaseCollector, CollectionMethod, CollectResult
from collectors.state import CrawlState
from collectors.rate_limit import RateLimiter, DailyRateLimiter
from collectors.coverage import (
    CoverageReport,
    RegistryCoverage,
    KindCoverage,
    generate_coverage_report,
    format_coverage_report,
    load_registry_claims,
    load_coverage_baseline,
)
from collectors.detection import (
    DetectionResult,
    NewComponentReport,
    detect_new_by_registry,
    detect_new_components,
    format_detection_report,
    generate_detection_report,
    backup_current_collection,
)

__all__ = [
    "BaseCollector",
    "CollectionMethod",
    "CollectResult",
    "CrawlState",
    "RateLimiter",
    "DailyRateLimiter",
    # Coverage
    "CoverageReport",
    "RegistryCoverage",
    "KindCoverage",
    "generate_coverage_report",
    "format_coverage_report",
    "load_registry_claims",
    "load_coverage_baseline",
    # Detection
    "DetectionResult",
    "NewComponentReport",
    "detect_new_by_registry",
    "detect_new_components",
    "format_detection_report",
    "generate_detection_report",
    "backup_current_collection",
]
