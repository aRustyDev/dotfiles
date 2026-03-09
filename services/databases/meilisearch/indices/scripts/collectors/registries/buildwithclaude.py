"""
BuildWithClaude.com collector for showcase projects.

Uses scraping for static HTML pages with embedded project data.
"""

from __future__ import annotations

import json
import re
from typing import Any

from collectors.base import RawComponent
from collectors.methods.scrape import ScrapeCollector
from collectors.rate_limit import RateLimitConfig


class BuildWithClaudeCollector(ScrapeCollector):
    """Scrape-based collector for buildwithclaude.com.

    buildwithclaude.com showcases projects built with Claude.
    Contains mixed component types that need to be inferred.
    """

    registry_name = "buildwithclaude.com"
    supported_kinds = {"skill", "agent", "plugin", "mcp_server"}

    base_url = "https://buildwithclaude.com/showcase"
    pagination_pattern = "?page={page}"

    rate_limit = RateLimitConfig(delay=1.0)

    def extract_components(self, html: str) -> list[RawComponent]:
        """Extract project data from showcase HTML."""
        components = []

        # Try embedded JSON first
        json_components = self._extract_embedded_json(html)
        if json_components:
            return json_components

        # Fall back to card pattern extraction
        components.extend(self._extract_project_cards(html))

        return components

    def _extract_embedded_json(self, html: str) -> list[RawComponent]:
        """Extract from application/json script tags."""
        components = []

        # Pattern for JSON data in script tags
        json_pattern = r'<script[^>]*type="application/json"[^>]*>([^<]+)</script>'

        for match in re.finditer(json_pattern, html, re.IGNORECASE):
            try:
                data = json.loads(match.group(1))
                if isinstance(data, dict) and "projects" in data:
                    for proj in data["projects"]:
                        components.append({
                            "name": proj.get("name") or proj.get("title"),
                            "description": proj.get("description"),
                            "url": proj.get("url") or proj.get("link"),
                            "author": proj.get("author") or proj.get("creator"),
                            "githubUrl": proj.get("github") or proj.get("githubUrl"),
                            "tags": proj.get("tags", []),
                        })
            except json.JSONDecodeError:
                continue

        return components

    def _extract_project_cards(self, html: str) -> list[RawComponent]:
        """Extract project data from HTML card structures."""
        components = []

        # Look for card-like structures
        card_pattern = re.compile(
            r'<(?:div|article)[^>]*class="[^"]*(?:card|project|showcase)[^"]*"[^>]*>'
            r'([\s\S]*?)'
            r'</(?:div|article)>',
            re.IGNORECASE,
        )

        title_pattern = re.compile(r"<h[23][^>]*>([^<]+)</h[23]>", re.IGNORECASE)
        desc_pattern = re.compile(r"<p[^>]*>([^<]{10,300})</p>", re.IGNORECASE)
        link_pattern = re.compile(r'<a[^>]*href="([^"]+)"[^>]*>', re.IGNORECASE)
        author_pattern = re.compile(
            r'(?:by|author|creator)[:\s]*([^<,\n]{2,50})',
            re.IGNORECASE,
        )

        for card_match in card_pattern.finditer(html):
            card_html = card_match.group(1)

            title_match = title_pattern.search(card_html)
            if not title_match:
                continue

            name = title_match.group(1).strip()
            desc_match = desc_pattern.search(card_html)
            link_match = link_pattern.search(card_html)
            author_match = author_pattern.search(card_html)

            components.append({
                "name": name,
                "description": desc_match.group(1).strip() if desc_match else None,
                "url": link_match.group(1) if link_match else None,
                "author": author_match.group(1).strip() if author_match else None,
            })

        return components

    def infer_kind(self, raw: RawComponent) -> str:
        """Infer component kind from project data."""
        name = (raw.get("name") or "").lower()
        desc = (raw.get("description") or "").lower()
        url = (raw.get("url") or "").lower()
        text = f"{name} {desc} {url}"

        # MCP server patterns
        if "mcp" in text or "server" in text or "protocol" in text:
            return "mcp_server"

        # Agent patterns
        if "agent" in text or "assistant" in text or "bot" in text:
            return "agent"

        # Skill patterns
        if "skill" in text or "ability" in text:
            return "skill"

        # Default to plugin for showcased projects
        return "plugin"
