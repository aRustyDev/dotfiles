"""
BuildWithClaude.com collector for Claude Code extensions.

Uses browser-based collection for Next.js rendered content.
Crawls multiple section pages: plugins, skills, subagents, commands, hooks, mcp-servers.
"""

from __future__ import annotations

import re
from typing import Any

from collectors.base import RawComponent
from collectors.methods.browser import BrowserCollector
from collectors.rate_limit import RateLimitConfig


# Section pages to crawl with their component type mapping
SECTIONS = [
    ("plugins", "plugin"),
    ("skills", "skill"),
    ("subagents", "agent"),
    ("commands", "command"),
    ("hooks", "hook"),
    ("mcp-servers", "mcp_server"),
]


class BuildWithClaudeCollector(BrowserCollector):
    """Browser-based collector for buildwithclaude.com.

    buildwithclaude.com is a Next.js site with multiple sections.
    Each page number maps to a different section.
    """

    registry_name = "buildwithclaude.com"
    supported_kinds = {"skill", "agent", "plugin", "mcp_server", "command", "hook"}

    base_url = "https://buildwithclaude.com"

    rate_limit = RateLimitConfig(delay=1.5)

    def build_url(self, page: int) -> str:
        """Build URL for a section page.

        Maps page numbers to sections:
        page 1 = /plugins
        page 2 = /skills
        page 3 = /subagents
        page 4 = /commands
        page 5 = /hooks
        page 6 = /mcp-servers
        """
        if page > len(SECTIONS):
            return ""  # Signal end of pagination

        section, _ = SECTIONS[page - 1]
        return f"{self.base_url}/{section}"

    def extract_components(self, markdown: str) -> list[RawComponent]:
        """Extract component data from rendered markdown."""
        components = []
        seen = set()

        # Determine section from URL context in the markdown
        section_type = self._detect_section_type(markdown)

        # Pattern for component links
        # Format: ### [component-name Description](https://buildwithclaude.com/type/slug)
        # or: [ component-name Description ](https://buildwithclaude.com/type/slug)
        component_pattern = re.compile(
            r'\[([^\]]+)\]\((https://buildwithclaude\.com/(plugin|skill|subagent|command|hook|mcp-server)/([^)]+))\)',
            re.IGNORECASE,
        )

        for match in component_pattern.finditer(markdown):
            text = match.group(1).strip()
            url = match.group(2)
            type_path = match.group(3)
            slug = match.group(4)

            # Skip if seen
            if slug in seen:
                continue
            seen.add(slug)

            # Parse name and description from text
            # Format: "name Description text"
            # Name is usually the slug converted to title case
            name = slug.replace("-", " ").replace("_", " ").title()

            # The text often has both name and description
            # Try to extract description as the latter part
            description = text if len(text) > len(name) + 5 else None

            # Map type_path to component kind
            kind = self._type_path_to_kind(type_path)

            components.append({
                "name": name,
                "description": description,
                "url": url,
                "slug": slug,
                "kind": kind,
            })

        # Also extract from homepage cards if on homepage
        if "Browse by type" in markdown or "Extend Claude" in markdown:
            components.extend(self._extract_homepage_cards(markdown, seen))

        return components

    def _detect_section_type(self, markdown: str) -> str | None:
        """Detect which section we're on from markdown content."""
        if "/plugins" in markdown[:500]:
            return "plugin"
        if "/skills" in markdown[:500]:
            return "skill"
        if "/subagents" in markdown[:500]:
            return "agent"
        if "/commands" in markdown[:500]:
            return "command"
        if "/hooks" in markdown[:500]:
            return "hook"
        if "/mcp-servers" in markdown[:500]:
            return "mcp_server"
        return None

    def _type_path_to_kind(self, type_path: str) -> str:
        """Convert URL type path to component kind."""
        mapping = {
            "plugin": "plugin",
            "skill": "skill",
            "subagent": "agent",
            "command": "command",
            "hook": "hook",
            "mcp-server": "mcp_server",
        }
        return mapping.get(type_path, "plugin")

    def _extract_homepage_cards(self, markdown: str, seen: set) -> list[RawComponent]:
        """Extract component cards from homepage."""
        components = []

        # Pattern for homepage cards:
        # ### [name Description](url)
        card_pattern = re.compile(
            r'###\s*\[([^\]]+)\]\((https://buildwithclaude\.com/([^/]+)/([^)]+))\)',
            re.IGNORECASE,
        )

        for match in card_pattern.finditer(markdown):
            text = match.group(1).strip()
            url = match.group(2)
            type_path = match.group(3)
            slug = match.group(4)

            if slug in seen:
                continue
            seen.add(slug)

            # Parse name and description
            name = slug.replace("-", " ").replace("_", " ").title()
            description = text if len(text) > len(name) + 5 else None

            kind = self._type_path_to_kind(type_path)

            components.append({
                "name": name,
                "description": description,
                "url": url,
                "slug": slug,
                "kind": kind,
            })

        return components

    def infer_kind(self, raw: RawComponent) -> str:
        """Use the kind from extraction if available."""
        if "kind" in raw and raw["kind"] in self.supported_kinds:
            return raw["kind"]

        # Fall back to URL-based inference
        url = (raw.get("url") or "").lower()
        if "/mcp-server" in url:
            return "mcp_server"
        if "/subagent" in url:
            return "agent"
        if "/skill" in url:
            return "skill"
        if "/command" in url:
            return "command"
        if "/hook" in url:
            return "hook"

        return "plugin"
