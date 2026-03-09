"""
Scrape-based collector for HTML parsing.

Uses httpx for fetching and BeautifulSoup/regex for parsing.
Can optionally use Scrapling for adaptive selectors.
"""

from __future__ import annotations

import json
import logging
import re
from typing import Any

import httpx

from collectors.base import BaseCollector, CollectionMethod, RawComponent, fetch_with_backoff

logger = logging.getLogger(__name__)


class ScrapeCollector(BaseCollector):
    """HTML scraping collector.

    Subclasses should override:
    - registry_name: Name of the registry
    - supported_kinds: Set of component kinds
    - base_url: Website base URL
    - selectors: CSS selectors for extraction (optional)
    - fetch_page(): To customize URL patterns
    - extract_components(): To parse HTML
    """

    method = CollectionMethod.SCRAPE

    # Override in subclasses
    base_url: str = ""
    pagination_pattern: str = "?page={page}"
    max_empty_pages: int = 2

    # CSS selectors (if using structured extraction)
    selectors: dict[str, str] = {}

    def __init__(self):
        super().__init__()
        self._client: httpx.AsyncClient | None = None

    async def _get_client(self) -> httpx.AsyncClient:
        """Get or create HTTP client."""
        if self._client is None:
            headers = {
                "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36",
                "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
            }
            self._client = httpx.AsyncClient(headers=headers, timeout=30, follow_redirects=True)
        return self._client

    async def close(self) -> None:
        """Close HTTP client."""
        if self._client:
            await self._client.aclose()
            self._client = None

    async def fetch_page(self, page: int) -> str | None:
        """Fetch HTML content for a page.

        Args:
            page: Page number (1-indexed)

        Returns:
            HTML content string or None on failure
        """
        client = await self._get_client()
        url = self.build_url(page)

        response = await fetch_with_backoff(url, client, self.backoff)
        if response is None:
            return None

        return response.text

    def build_url(self, page: int) -> str:
        """Build URL for a specific page."""
        return f"{self.base_url}{self.pagination_pattern.format(page=page)}"

    def extract_components(self, html: str) -> list[RawComponent]:
        """Extract components from HTML content.

        Override in subclasses for registry-specific parsing.
        Default implementation looks for common patterns.
        """
        components: list[RawComponent] = []

        # Try JSON-LD first
        components.extend(self._extract_json_ld(html))
        if components:
            return components

        # Try embedded JSON
        components.extend(self._extract_embedded_json(html))
        if components:
            return components

        # Try __NEXT_DATA__ for Next.js sites
        components.extend(self._extract_next_data(html))
        if components:
            return components

        # Fall back to card pattern matching
        components.extend(self._extract_card_patterns(html))

        return components

    def _extract_json_ld(self, html: str) -> list[RawComponent]:
        """Extract data from JSON-LD script tags."""
        components = []
        pattern = r'<script[^>]*type="application/ld\+json"[^>]*>([^<]+)</script>'

        for match in re.finditer(pattern, html, re.IGNORECASE):
            try:
                data = json.loads(match.group(1))
                if isinstance(data, dict):
                    if data.get("@type") == "SoftwareApplication":
                        components.append({
                            "name": data.get("name"),
                            "description": data.get("description"),
                            "url": data.get("url"),
                            "author": data.get("author", {}).get("name") if isinstance(data.get("author"), dict) else data.get("author"),
                        })
                    elif "@graph" in data:
                        for item in data["@graph"]:
                            if item.get("@type") in ("SoftwareApplication", "WebApplication"):
                                components.append({
                                    "name": item.get("name"),
                                    "description": item.get("description"),
                                    "url": item.get("url"),
                                    "author": item.get("author"),
                                })
            except json.JSONDecodeError:
                continue

        return components

    def _extract_embedded_json(self, html: str) -> list[RawComponent]:
        """Extract data from application/json script tags."""
        components = []
        pattern = r'<script[^>]*type="application/json"[^>]*>([^<]+)</script>'

        for match in re.finditer(pattern, html, re.IGNORECASE):
            try:
                data = json.loads(match.group(1))
                if isinstance(data, dict):
                    for key in ["projects", "items", "servers", "skills", "components"]:
                        if key in data and isinstance(data[key], list):
                            for item in data[key]:
                                components.append({
                                    "name": item.get("name") or item.get("title"),
                                    "description": item.get("description"),
                                    "url": item.get("url") or item.get("link"),
                                    "author": item.get("author") or item.get("creator"),
                                })
            except json.JSONDecodeError:
                continue

        return components

    def _extract_next_data(self, html: str) -> list[RawComponent]:
        """Extract data from Next.js __NEXT_DATA__."""
        components = []
        pattern = r'<script[^>]*id="__NEXT_DATA__"[^>]*>([^<]+)</script>'

        match = re.search(pattern, html, re.IGNORECASE)
        if match:
            try:
                data = json.loads(match.group(1))
                props = data.get("props", {}).get("pageProps", {})

                # Look for data in common locations
                for key in ["servers", "items", "data", "results", "skills", "components"]:
                    if key in props and isinstance(props[key], list):
                        for item in props[key]:
                            if isinstance(item, dict) and item.get("name"):
                                components.append({
                                    "name": item.get("name"),
                                    "description": item.get("description"),
                                    "url": item.get("url") or item.get("homepage"),
                                    "author": item.get("author") or item.get("owner"),
                                    "stars": item.get("stars") or item.get("stargazers_count"),
                                    "githubUrl": item.get("github") or item.get("repository"),
                                })
            except json.JSONDecodeError:
                pass

        return components

    def _extract_card_patterns(self, html: str) -> list[RawComponent]:
        """Extract data from HTML card structures."""
        components = []

        # Generic card pattern
        card_pattern = r'<div[^>]*class="[^"]*card[^"]*"[^>]*>([\s\S]*?)</div>'
        title_pattern = r"<h[23][^>]*>([^<]+)</h[23]>"
        desc_pattern = r"<p[^>]*>([^<]{10,200})</p>"
        link_pattern = r'<a[^>]*href="([^"]+)"[^>]*>'

        for card_match in re.finditer(card_pattern, html, re.IGNORECASE):
            card_html = card_match.group(1)
            title_match = re.search(title_pattern, card_html)
            desc_match = re.search(desc_pattern, card_html)
            link_match = re.search(link_pattern, card_html)

            if title_match:
                components.append({
                    "name": title_match.group(1).strip(),
                    "description": desc_match.group(1).strip() if desc_match else None,
                    "url": link_match.group(1) if link_match else None,
                    "author": None,
                })

        return components

    async def __aenter__(self):
        await self._get_client()
        return self

    async def __aexit__(self, exc_type, exc_val, exc_tb):
        await self.close()
