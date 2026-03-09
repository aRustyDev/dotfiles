"""
MCP.so collector for MCP server directory.

Uses browser-based collection due to Next.js rendering.
Falls back to API endpoints if available.
"""

from __future__ import annotations

import json
import logging
import re
from typing import Any

import httpx

from collectors.base import RawComponent
from collectors.methods.browser import BrowserCollector
from collectors.methods.scrape import ScrapeCollector
from collectors.rate_limit import RateLimitConfig

logger = logging.getLogger(__name__)


class MCPSoCollector(BrowserCollector):
    """Browser-based collector for mcp.so.

    mcp.so is a Next.js site with a large directory of MCP servers.
    Requires JavaScript rendering but may have API endpoints.
    """

    registry_name = "mcp.so"
    supported_kinds = {"mcp_server"}

    base_url = "https://mcp.so/servers"
    pagination_pattern = "?page={page}"

    rate_limit = RateLimitConfig(delay=3.0)

    # Site stats
    total_pages = 294
    servers_per_page = 50

    # Known API endpoints to try first
    api_endpoints = [
        "https://mcp.so/api/servers",
        "https://mcp.so/api/v1/servers",
        "https://mcp.so/servers.json",
    ]

    def __init__(self):
        super().__init__()
        self._api_url: str | None = None
        self._use_api = False

    async def _try_api_endpoints(self) -> list[RawComponent] | None:
        """Try known API endpoints before browser crawling."""
        async with httpx.AsyncClient(timeout=10) as client:
            for api_url in self.api_endpoints:
                try:
                    response = await client.get(api_url)
                    if response.status_code == 200:
                        data = response.json()
                        servers = data if isinstance(data, list) else data.get("servers", [])

                        if servers:
                            logger.info(f"Found API at {api_url} with {len(servers)} servers")
                            self._api_url = api_url
                            self._use_api = True
                            return [self._transform_api_server(s) for s in servers]

                except (httpx.HTTPError, json.JSONDecodeError):
                    continue

        logger.info("No API endpoints available, falling back to browser crawling")
        return None

    def _transform_api_server(self, server: dict) -> RawComponent:
        """Transform API response server to component format."""
        return {
            "name": server.get("name"),
            "description": server.get("description"),
            "url": server.get("url") or server.get("homepage"),
            "author": server.get("author") or server.get("owner"),
            "stars": server.get("stars") or server.get("stargazers_count"),
            "githubUrl": server.get("github") or server.get("repository"),
            "tags": server.get("tags", []) or server.get("keywords", []),
        }

    def extract_components(self, content: str) -> list[RawComponent]:
        """Extract server data from content.

        Handles both API JSON and browser markdown.
        """
        # If we got JSON from API
        if content.startswith("{") or content.startswith("["):
            try:
                data = json.loads(content)
                servers = data if isinstance(data, list) else data.get("servers", [])
                return [self._transform_api_server(s) for s in servers]
            except json.JSONDecodeError:
                pass

        # Otherwise, parse markdown from browser crawl
        return self._extract_from_markdown(content)

    def _extract_from_markdown(self, markdown: str) -> list[RawComponent]:
        """Extract servers from crawl4ai markdown output."""
        components = []

        # Pattern for server links in markdown
        # Matches: [Server Name](https://mcp.so/server/path)
        server_pattern = re.compile(
            r'\[([^\]]+)\]\((https://mcp\.so/server/[^)]+)\)',
            re.IGNORECASE,
        )

        seen_urls = set()

        for match in server_pattern.finditer(markdown):
            name = match.group(1).strip()
            url = match.group(2).strip()

            if url in seen_urls:
                continue
            seen_urls.add(url)

            # Extract author/path from URL
            path_match = re.match(r"https://mcp\.so/server/([^/]+)/([^/\s]+)", url)
            author = path_match.group(1) if path_match else None

            components.append({
                "name": name,
                "url": url,
                "author": author,
            })

        # Also try __NEXT_DATA__ extraction
        next_components = self._extract_next_data(markdown)
        if next_components:
            # Merge, preferring Next.js data for richer info
            url_to_next = {c.get("url"): c for c in next_components if c.get("url")}
            for comp in components:
                if comp.get("url") in url_to_next:
                    comp.update(url_to_next[comp["url"]])

            # Add any components only found in Next.js data
            for nc in next_components:
                if nc.get("url") not in seen_urls:
                    components.append(nc)

        return components

    def _extract_next_data(self, content: str) -> list[RawComponent]:
        """Extract from Next.js __NEXT_DATA__ if present."""
        components = []

        next_pattern = r'<script[^>]*id="__NEXT_DATA__"[^>]*>([^<]+)</script>'
        match = re.search(next_pattern, content, re.IGNORECASE)

        if match:
            try:
                data = json.loads(match.group(1))
                props = data.get("props", {}).get("pageProps", {})

                for key in ["servers", "items", "data", "results"]:
                    if key in props and isinstance(props[key], list):
                        for item in props[key]:
                            if isinstance(item, dict) and item.get("name"):
                                components.append({
                                    "name": item.get("name"),
                                    "description": item.get("description"),
                                    "url": item.get("url") or item.get("homepage"),
                                    "author": item.get("author") or item.get("owner"),
                                    "stars": item.get("stars"),
                                    "githubUrl": item.get("github") or item.get("repository"),
                                })
            except json.JSONDecodeError:
                pass

        return components

    def infer_kind(self, raw: RawComponent) -> str:
        """MCP.so only has mcp_server."""
        return "mcp_server"
