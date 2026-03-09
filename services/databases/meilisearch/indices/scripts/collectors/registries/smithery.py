"""
Smithery.ai collector for MCP servers and skills.

Uses browser-based collection (crawl4ai) for JavaScript-rendered content.
"""

from __future__ import annotations

import re
from typing import Any

from collectors.base import RawComponent
from collectors.methods.browser import BrowserCollector
from collectors.rate_limit import RateLimitConfig


class SmitheryCollector(BrowserCollector):
    """Browser-based collector for smithery.ai.

    smithery.ai is a Next.js site requiring JavaScript rendering.
    Contains both MCP servers (/servers) and skills (/skills).
    """

    registry_name = "smithery.ai"
    supported_kinds = {"mcp_server", "skill"}

    base_url = "https://smithery.ai/servers"
    pagination_pattern = "?page={page}"

    rate_limit = RateLimitConfig(delay=1.0, batch_delay=2.0)

    # Total pages (from site stats)
    total_pages = 182
    items_per_page = 21

    # Pattern to extract server/skill paths from markdown
    extract_pattern = re.compile(r"https://smithery\.ai/(servers|skills)/([^)\s]+)")

    def extract_components(self, markdown: str) -> list[RawComponent]:
        """Extract server/skill URLs from markdown content."""
        components = []
        seen_paths = set()

        for match in self.extract_pattern.finditer(markdown):
            kind_path = match.group(1)  # "servers" or "skills"
            path = match.group(2).strip()

            # Skip pagination and duplicates
            if not path or path in seen_paths or "?page=" in path:
                continue

            seen_paths.add(path)

            # Determine component type
            kind = "mcp_server" if kind_path == "servers" else "skill"

            # Extract author and name from path
            parts = path.split("/")
            author = parts[0] if len(parts) > 1 else None
            name_part = parts[-1] if parts else path
            name = name_part.replace("-", " ").replace("_", " ").strip()

            components.append({
                "name": name,
                "url": match.group(0),
                "author": author,
                "type": kind,
                "path": path,
            })

        return components

    def infer_kind(self, raw: RawComponent) -> str:
        """Use pre-determined kind from extraction."""
        return raw.get("type", "mcp_server")

    def transform(self, raw: RawComponent, kind: str | None = None) -> dict:
        """Transform with smithery-specific handling."""
        component = super().transform(raw, kind)

        # Use path-based ID for uniqueness
        if "path" in raw:
            path = raw["path"]
            clean_path = path.replace("/", "_").replace("-", "_")
            component["id"] = f"smithery_ai_{clean_path}"

        return component


class SmitherySkillsCollector(SmitheryCollector):
    """Collector specifically for smithery.ai/skills endpoint."""

    base_url = "https://smithery.ai/skills"
    supported_kinds = {"skill"}

    # Skills have fewer pages
    total_pages = 50

    def infer_kind(self, raw: RawComponent) -> str:
        """Skills endpoint only has skills."""
        return "skill"
