"""
MCPServers.org collector for MCP server directory.

Uses scraping for static HTML pages.
"""

from __future__ import annotations

import json
import re
from typing import Any

from collectors.base import RawComponent
from collectors.methods.scrape import ScrapeCollector
from collectors.rate_limit import RateLimitConfig


class MCPServersCollector(ScrapeCollector):
    """Scrape-based collector for mcpservers.org.

    mcpservers.org is a static HTML directory of MCP servers
    with pagination and card-based layout.
    """

    registry_name = "mcpservers.org"
    supported_kinds = {"mcp_server"}

    base_url = "https://mcpservers.org"
    pagination_pattern = "?page={page}"

    rate_limit = RateLimitConfig(delay=1.0)

    # CSS-like patterns for extraction
    selectors = {
        "container": ".server-card",
        "name": "h3, .title",
        "url": "a[href*='/server/']",
        "description": ".description, p",
    }

    def extract_components(self, html: str) -> list[RawComponent]:
        """Extract server data from HTML."""
        components = []

        # Try JSON-LD first (preferred structured data)
        json_ld_components = self._extract_json_ld(html)
        if json_ld_components:
            return json_ld_components

        # Try Next.js data
        next_components = self._extract_next_data(html)
        if next_components:
            return next_components

        # Fall back to regex-based extraction
        components.extend(self._extract_server_links(html))

        return components

    def _extract_server_links(self, html: str) -> list[RawComponent]:
        """Extract server links from HTML using patterns."""
        components = []
        seen = set()

        # Pattern for server links
        # Matches: /server/owner/name or /servers/owner/name
        link_pattern = re.compile(
            r'href="(/servers?/([^"]+))"[^>]*>([^<]*)</a>',
            re.IGNORECASE,
        )

        for match in link_pattern.finditer(html):
            path = match.group(1)
            slug = match.group(2)
            text = match.group(3).strip()

            if slug in seen:
                continue
            seen.add(slug)

            # Parse owner/name from slug
            parts = slug.split("/")
            author = parts[0] if len(parts) > 1 else None
            name = text or (parts[-1] if parts else slug)
            name = name.replace("-", " ").replace("_", " ")

            components.append({
                "name": name,
                "url": f"https://mcpservers.org{path}",
                "author": author,
                "path": slug,
            })

        # Also try to find descriptions near links
        components = self._enrich_with_descriptions(html, components)

        return components

    def _enrich_with_descriptions(
        self,
        html: str,
        components: list[RawComponent],
    ) -> list[RawComponent]:
        """Try to find descriptions for extracted components."""
        # Pattern to find card-like structures with descriptions
        card_pattern = re.compile(
            r'<(?:div|article)[^>]*class="[^"]*(?:card|item|server)[^"]*"[^>]*>'
            r'([\s\S]*?)'
            r'</(?:div|article)>',
            re.IGNORECASE,
        )

        desc_pattern = re.compile(
            r'<p[^>]*>([^<]{20,500})</p>',
            re.IGNORECASE,
        )

        # Build lookup by path
        by_path = {c.get("path"): c for c in components if c.get("path")}

        for card_match in card_pattern.finditer(html):
            card_html = card_match.group(1)

            # Find which component this card is for
            for path, comp in by_path.items():
                if path in card_html:
                    # Find description
                    desc_match = desc_pattern.search(card_html)
                    if desc_match and not comp.get("description"):
                        comp["description"] = desc_match.group(1).strip()
                    break

        return components

    def infer_kind(self, raw: RawComponent) -> str:
        """MCPServers.org only has mcp_server."""
        return "mcp_server"
