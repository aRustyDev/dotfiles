"""
MCPServers.org collector for MCP server directory.

Uses browser-based collection for Next.js rendered content.
"""

from __future__ import annotations

import json
import re
from typing import Any

from collectors.base import RawComponent
from collectors.methods.browser import BrowserCollector
from collectors.rate_limit import RateLimitConfig


class MCPServersCollector(BrowserCollector):
    """Browser-based collector for mcpservers.org.

    mcpservers.org is a Next.js site requiring JavaScript rendering.
    Uses crawl4ai to render pages and extract server data.
    """

    registry_name = "mcpservers.org"
    supported_kinds = {"mcp_server"}

    base_url = "https://mcpservers.org"
    pagination_pattern = "/all?page={page}"

    rate_limit = RateLimitConfig(delay=2.0)

    # Wait for server cards to load
    wait_for_selector = "[class*='server'], [class*='card'], main"

    def extract_components(self, markdown: str) -> list[RawComponent]:
        """Extract server data from rendered markdown."""
        components = []
        seen = set()

        # Pattern 1: mcpservers.org server links with description in text
        # Format: [ Server Name Description text ](https://mcpservers.org/servers/owner/repo)
        server_pattern = re.compile(
            r'\[\s*([^\]]+?)\s*\]\((https://mcpservers\.org/servers/([^)]+))\)',
            re.IGNORECASE,
        )

        for match in server_pattern.finditer(markdown):
            text = match.group(1).strip()
            url = match.group(2)
            path = match.group(3)

            # Parse owner/repo from path
            parts = path.split("/")
            if len(parts) >= 2:
                owner = parts[0]
                repo = parts[1]
            else:
                owner = None
                repo = parts[0] if parts else path

            # Create unique key
            key = path
            if key in seen:
                continue
            seen.add(key)

            # Extract name and description from text
            # Often the format is "Name Description text"
            # Try to separate name from description
            words = text.split()
            if len(words) > 3:
                # Assume first 1-3 words are name, rest is description
                # Look for common patterns
                name = repo.replace("-", " ").replace("_", " ").title()
                description = text
            else:
                name = text
                description = None

            # Skip sponsor/ad entries
            if "sponsor" in text.lower():
                continue

            components.append({
                "name": name,
                "description": description,
                "url": url,
                "author": owner,
                "path": path,
            })

        # Pattern 2: Direct GitHub links (sponsors/external)
        github_pattern = re.compile(
            r'\[\s*([^\]]+?)\s*\]\((https://github\.com/([^/]+)/([^/)\s]+))\)',
            re.IGNORECASE,
        )

        for match in github_pattern.finditer(markdown):
            text = match.group(1).strip()
            url = match.group(2)
            owner = match.group(3)
            repo = match.group(4)

            # Create unique key
            key = f"github/{owner}/{repo}"
            if key in seen:
                continue

            # Skip sponsor links (already have description inline)
            if "sponsor" in text.lower():
                continue

            seen.add(key)

            # Extract name and description
            name = repo.replace("-", " ").replace("_", " ").title()

            components.append({
                "name": name,
                "description": text if len(text) > len(name) + 5 else None,
                "url": url,
                "author": owner,
                "github_url": url,
            })

        return components

    def infer_kind(self, raw: RawComponent) -> str:
        """MCPServers.org only has mcp_server."""
        return "mcp_server"
