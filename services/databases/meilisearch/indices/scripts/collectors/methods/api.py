"""
API-based collector for HTTP JSON APIs.

Uses httpx for async HTTP requests with authentication support.
"""

from __future__ import annotations

import logging
from typing import Any

import httpx

from collectors.auth import AuthConfig, AuthType, CredentialResolver, build_auth_headers
from collectors.base import BaseCollector, CollectionMethod, fetch_with_backoff

logger = logging.getLogger(__name__)


class APICollector(BaseCollector):
    """HTTP API collector with authentication support.

    Subclasses should override:
    - registry_name: Name of the registry
    - supported_kinds: Set of component kinds this registry provides
    - base_url: API base URL
    - auth_config: Optional authentication configuration
    - fetch_page(): To customize API endpoints and pagination
    - extract_components(): To parse API response format
    """

    method = CollectionMethod.API

    # Override in subclasses
    base_url: str = ""
    auth_config: AuthConfig = AuthConfig()

    def __init__(self):
        super().__init__()
        self._client: httpx.AsyncClient | None = None
        self._credential: str | None = None

    async def _get_client(self) -> httpx.AsyncClient:
        """Get or create HTTP client with auth headers."""
        if self._client is None:
            # Resolve credentials
            if self.auth_config.type != AuthType.NONE:
                self._credential = CredentialResolver.resolve(self.auth_config)

            # Build headers
            headers = {"User-Agent": "ComponentCollector/1.0"}
            headers.update(build_auth_headers(self.auth_config, self._credential))

            self._client = httpx.AsyncClient(headers=headers, timeout=30)

        return self._client

    async def close(self) -> None:
        """Close HTTP client."""
        if self._client:
            await self._client.aclose()
            self._client = None

    async def fetch_page(self, page: int) -> dict | None:
        """Fetch a page from the API.

        Default implementation expects subclasses to override
        or provide build_url() method.

        Args:
            page: Page number (1-indexed)

        Returns:
            JSON response dict or None on failure
        """
        client = await self._get_client()
        url = self.build_url(page)

        response = await fetch_with_backoff(url, client, self.backoff)
        if response is None:
            return None

        return response.json()

    def build_url(self, page: int) -> str:
        """Build URL for a specific page. Override in subclasses."""
        # Default: simple page query param
        return f"{self.base_url}?page={page}"

    def extract_components(self, raw: dict) -> list[dict]:
        """Extract components from API response.

        Override in subclasses to handle specific response formats.
        Default looks for common patterns.
        """
        # Try common response patterns
        if isinstance(raw, list):
            return raw

        for key in ["data", "items", "results", "components", "servers", "skills"]:
            if key in raw:
                data = raw[key]
                if isinstance(data, list):
                    return data
                if isinstance(data, dict):
                    # Nested structure like {data: {skills: [...]}}
                    for subkey in ["items", "results", "skills", "servers"]:
                        if subkey in data and isinstance(data[subkey], list):
                            return data[subkey]

        logger.warning(f"{self.registry_name}: Could not find components in response")
        return []

    async def __aenter__(self):
        await self._get_client()
        return self

    async def __aexit__(self, exc_type, exc_val, exc_tb):
        await self.close()
