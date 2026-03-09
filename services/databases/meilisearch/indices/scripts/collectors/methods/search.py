"""
Search-based collector using SearXNG.

Enables discovery of components via meta-search across
multiple search engines.
"""

from __future__ import annotations

import logging
import re
from typing import Any

import httpx

from collectors.base import BaseCollector, CollectionMethod, RawComponent

logger = logging.getLogger(__name__)


class SearchCollector(BaseCollector):
    """SearXNG-based search collector for discovery.

    Unlike other collectors that crawl known registries,
    SearchCollector discovers new components via search queries.

    Usage:
        collector = SearchCollector()
        result = await collector.search("claude mcp server filesystem")
    """

    method = CollectionMethod.SEARCH
    registry_name = "searxng"
    supported_kinds = {"skill", "agent", "command", "rule", "prompt", "hook", "mcp_server", "plugin"}

    # SearXNG configuration
    searxng_url: str = "http://localhost:8888/search"
    default_engines: list[str] = ["google", "github", "duckduckgo"]
    results_per_page: int = 20

    def __init__(self, searxng_url: str | None = None):
        super().__init__()
        if searxng_url:
            self.searxng_url = searxng_url
        self._client: httpx.AsyncClient | None = None
        self._current_query: str = ""
        self._search_results: list[dict] = []
        self._result_offset: int = 0

    async def _get_client(self) -> httpx.AsyncClient:
        """Get or create HTTP client."""
        if self._client is None:
            self._client = httpx.AsyncClient(timeout=30)
        return self._client

    async def close(self) -> None:
        """Close HTTP client."""
        if self._client:
            await self._client.aclose()
            self._client = None

    async def search(
        self,
        query: str,
        engines: list[str] | None = None,
        max_results: int = 50,
    ) -> list[RawComponent]:
        """Search for components via SearXNG.

        Args:
            query: Search query
            engines: Search engines to use
            max_results: Maximum results to return

        Returns:
            List of discovered components
        """
        client = await self._get_client()
        results = []
        page = 1

        while len(results) < max_results:
            params = {
                "q": query,
                "format": "json",
                "engines": ",".join(engines or self.default_engines),
                "pageno": page,
            }

            try:
                response = await client.get(self.searxng_url, params=params)
                if response.status_code != 200:
                    logger.warning(f"SearXNG returned {response.status_code}")
                    break

                data = response.json()
                search_results = data.get("results", [])

                if not search_results:
                    break

                for item in search_results:
                    component = self._parse_search_result(item)
                    if component:
                        results.append(component)

                page += 1

            except httpx.HTTPError as e:
                logger.error(f"SearXNG request failed: {e}")
                break
            except Exception as e:
                logger.error(f"Error processing search results: {e}")
                break

        # Deduplicate by URL
        seen_urls = set()
        unique_results = []
        for comp in results[:max_results]:
            url = comp.get("url")
            if url and url not in seen_urls:
                seen_urls.add(url)
                unique_results.append(comp)

        return unique_results

    def _parse_search_result(self, result: dict) -> RawComponent | None:
        """Parse a SearXNG search result into component data."""
        url = result.get("url", "")
        title = result.get("title", "")
        content = result.get("content", "")

        # Filter out non-component results
        if not self._looks_like_component(url, title, content):
            return None

        # Extract author from URL
        author = self._extract_author(url)

        return {
            "name": self._clean_title(title),
            "url": url,
            "description": content[:500] if content else None,
            "author": author,
            "githubUrl": url if "github.com" in url else None,
            "search_engine": result.get("engine"),
            "search_score": result.get("score"),
        }

    def _looks_like_component(self, url: str, title: str, content: str) -> bool:
        """Check if search result looks like a Claude component."""
        text = f"{url} {title} {content}".lower()

        # Must contain relevant keywords
        component_keywords = [
            "claude", "mcp", "anthropic",
            "skill", "agent", "plugin", "server",
            "hook", "command", "prompt",
        ]

        has_keyword = any(kw in text for kw in component_keywords)
        if not has_keyword:
            return False

        # Must be from a relevant source
        relevant_domains = [
            "github.com",
            "npmjs.com",
            "pypi.org",
            "smithery.ai",
            "skillsmp.com",
            "mcp.so",
            "mcpservers.org",
        ]

        is_relevant_source = any(domain in url for domain in relevant_domains)

        return is_relevant_source

    def _extract_author(self, url: str) -> str | None:
        """Extract author from URL."""
        # GitHub pattern
        match = re.match(r"https://github\.com/([^/]+)/", url)
        if match:
            return match.group(1)

        # npm scoped package
        match = re.match(r"https://(?:www\.)?npmjs\.com/package/@([^/]+)/", url)
        if match:
            return match.group(1)

        # Generic author extraction
        match = re.match(r"https://([^/]+)/([^/]+)/", url)
        if match:
            author = match.group(2)
            if author not in ("package", "project", "repo", "servers", "skills"):
                return author

        return None

    def _clean_title(self, title: str) -> str:
        """Clean up search result title."""
        # Remove common suffixes
        suffixes = [
            " - GitHub",
            " | GitHub",
            " - npm",
            " - PyPI",
            "· GitHub",
        ]

        for suffix in suffixes:
            if title.endswith(suffix):
                title = title[: -len(suffix)]

        return title.strip()

    # BaseCollector interface for compatibility

    async def fetch_page(self, page: int) -> list[dict] | None:
        """Fetch search results (not typically used directly)."""
        if not self._current_query:
            return None

        # Use cached results
        start = (page - 1) * self.results_per_page
        end = start + self.results_per_page

        if start >= len(self._search_results):
            return None

        return self._search_results[start:end]

    def extract_components(self, raw: list[dict]) -> list[RawComponent]:
        """Extract components from search results."""
        return raw  # Already parsed in search()

    async def __aenter__(self):
        await self._get_client()
        return self

    async def __aexit__(self, exc_type, exc_val, exc_tb):
        await self.close()
