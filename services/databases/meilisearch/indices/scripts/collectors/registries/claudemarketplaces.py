"""
ClaudeMarketplaces.com collector for plugin directory.

Uses API-based collection with no authentication required.
"""

from __future__ import annotations

from typing import Any

from collectors.base import RawComponent
from collectors.methods.api import APICollector
from collectors.rate_limit import RateLimitConfig


class ClaudeMarketplacesCollector(APICollector):
    """API-based collector for claudemarketplaces.com.

    claudemarketplaces.com provides a simple JSON API for listing
    available marketplaces/plugins. No authentication required.
    """

    registry_name = "claudemarketplaces.com"
    supported_kinds = {"plugin"}

    base_url = "https://claudemarketplaces.com/api"

    rate_limit = RateLimitConfig(delay=0.5)

    # Single endpoint, no pagination
    _has_pagination = False

    def build_url(self, page: int) -> str:
        """API has a single endpoint."""
        return f"{self.base_url}/marketplaces"

    async def fetch_page(self, page: int) -> dict | list | None:
        """Fetch marketplace data (single request, no pagination)."""
        if page > 1:
            return None  # No pagination

        return await super().fetch_page(page)

    def extract_components(self, data: dict | list) -> list[RawComponent]:
        """Extract marketplaces from API response.

        Response can be either:
        - Direct array: [{"name": ..., ...}, ...]
        - Object with key: {"marketplaces": [...]}
        """
        if isinstance(data, list):
            marketplaces = data
        else:
            marketplaces = data.get("marketplaces", [])

        components = []
        for item in marketplaces:
            components.append({
                "name": item.get("name"),
                "description": item.get("description"),
                "url": item.get("url") or item.get("website"),
                "author": item.get("author") or item.get("creator"),
                "githubUrl": item.get("github") or item.get("repository"),
                "tags": item.get("tags", []) or item.get("categories", []),
            })

        return components

    def infer_kind(self, raw: RawComponent) -> str:
        """ClaudeMarketplaces only has plugins."""
        return "plugin"
