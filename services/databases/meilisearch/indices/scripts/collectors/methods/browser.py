"""
Browser-based collector for JavaScript-rendered pages.

Uses crawl4ai for async crawling with JS rendering.
Falls back to Playwright for complex interactions.
"""

from __future__ import annotations

import logging
import re
from typing import Any

from collectors.base import BaseCollector, CollectionMethod, RawComponent

logger = logging.getLogger(__name__)


class BrowserCollector(BaseCollector):
    """JavaScript rendering collector using crawl4ai.

    For sites that require JavaScript execution to render content.
    Slower than scrape/API methods but handles modern SPAs.

    Subclasses should override:
    - registry_name: Name of the registry
    - supported_kinds: Set of component kinds
    - base_url: Website base URL
    - extract_pattern: Regex pattern for extracting URLs from markdown
    - extract_components(): To parse crawl4ai output
    """

    method = CollectionMethod.BROWSER

    # Override in subclasses
    base_url: str = ""
    pagination_pattern: str = "?page={page}"
    extract_pattern: re.Pattern | None = None

    # crawl4ai configuration
    verbose: bool = False
    wait_for_selector: str | None = None  # CSS selector to wait for
    execute_js: str | None = None  # JavaScript to execute before extraction

    def __init__(self):
        super().__init__()
        self._crawler = None

    async def _get_crawler(self):
        """Get or create crawl4ai crawler."""
        if self._crawler is None:
            try:
                from crawl4ai import AsyncWebCrawler
                self._crawler = AsyncWebCrawler(verbose=self.verbose)
                await self._crawler.__aenter__()
            except ImportError:
                logger.error("crawl4ai not installed. Run: pip install crawl4ai && crawl4ai-setup")
                raise

        return self._crawler

    async def close(self) -> None:
        """Close crawler."""
        if self._crawler:
            await self._crawler.__aexit__(None, None, None)
            self._crawler = None

    async def fetch_page(self, page: int) -> str | None:
        """Fetch page using crawl4ai and return markdown.

        Args:
            page: Page number (1-indexed)

        Returns:
            Markdown content or None on failure
        """
        crawler = await self._get_crawler()
        url = self.build_url(page)

        try:
            result = await crawler.arun(url=url)
            if result.success:
                return result.markdown
            else:
                logger.warning(f"crawl4ai failed for {url}")
                return None
        except Exception as e:
            logger.error(f"Error crawling {url}: {e}")
            return None

    def build_url(self, page: int) -> str:
        """Build URL for a specific page."""
        return f"{self.base_url}{self.pagination_pattern.format(page=page)}"

    def extract_components(self, markdown: str) -> list[RawComponent]:
        """Extract components from markdown content.

        Default implementation uses extract_pattern regex.
        Override for more complex extraction logic.
        """
        components = []

        if self.extract_pattern:
            for match in self.extract_pattern.finditer(markdown):
                component = self._parse_match(match)
                if component:
                    components.append(component)
        else:
            # Fall back to generic link extraction
            components.extend(self._extract_links(markdown))

        return components

    def _parse_match(self, match: re.Match) -> RawComponent | None:
        """Parse a regex match into component data.

        Override in subclasses for registry-specific parsing.
        """
        # Default: assume full URL is in group(0)
        url = match.group(0)
        path = match.group(1) if match.lastindex >= 1 else url

        # Extract name from path
        name = path.split("/")[-1] if "/" in path else path
        name = name.replace("-", " ").replace("_", " ").strip()

        # Extract author from path
        author = path.split("/")[0] if "/" in path else None

        return {
            "name": name,
            "url": url,
            "author": author,
        }

    def _extract_links(self, markdown: str) -> list[RawComponent]:
        """Extract component links from markdown."""
        components = []

        # Match markdown links: [text](url)
        link_pattern = r'\[([^\]]+)\]\(([^)]+)\)'

        for match in re.finditer(link_pattern, markdown):
            text = match.group(1).strip()
            url = match.group(2).strip()

            # Filter out navigation/utility links
            if self._is_component_link(url):
                components.append({
                    "name": text,
                    "url": url,
                    "author": self._extract_author_from_url(url),
                })

        return components

    def _is_component_link(self, url: str) -> bool:
        """Check if URL looks like a component link."""
        # Skip common non-component URLs
        skip_patterns = [
            r"#",  # Anchor links
            r"\?page=",  # Pagination
            r"shields\.io",  # Badges
            r"\.(png|jpg|gif|svg)$",  # Images
            r"/(login|signup|about|contact|terms|privacy)",  # Utility pages
        ]

        for pattern in skip_patterns:
            if re.search(pattern, url, re.IGNORECASE):
                return False

        # Must be a full URL or valid path
        if url.startswith(("http://", "https://", "/")):
            return True

        return False

    def _extract_author_from_url(self, url: str) -> str | None:
        """Extract author/owner from URL."""
        # GitHub pattern
        github_match = re.match(r"https://github\.com/([^/]+)/", url)
        if github_match:
            return github_match.group(1)

        # General path pattern (author/repo)
        path_match = re.match(r"https?://[^/]+/([^/]+)/", url)
        if path_match:
            author = path_match.group(1)
            # Skip common non-author path segments
            if author not in ("servers", "skills", "plugins", "api", "docs"):
                return author

        return None

    async def __aenter__(self):
        await self._get_crawler()
        return self

    async def __aexit__(self, exc_type, exc_val, exc_tb):
        await self.close()
