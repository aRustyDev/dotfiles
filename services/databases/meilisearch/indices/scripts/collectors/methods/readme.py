"""
README-based collector for awesome lists.

Parses markdown README files from GitHub repositories
to extract component links and descriptions.
"""

from __future__ import annotations

import base64
import logging
import re
import subprocess
from typing import Any

from collectors.base import BaseCollector, CollectionMethod, RawComponent

logger = logging.getLogger(__name__)


class ReadmeCollector(BaseCollector):
    """Awesome list collector that parses GitHub README files.

    Designed for curated lists like awesome-mcp-servers that
    follow the standard markdown list format.

    Subclasses should override:
    - registry_name: Name (typically "awesome:{owner}/{repo}")
    - supported_kinds: Set of component kinds
    - repo: GitHub repository (owner/repo)
    - default_kind: Default component type
    """

    method = CollectionMethod.README

    # Override in subclasses
    repo: str = ""  # e.g., "punkpeye/awesome-mcp-servers"
    default_kind: str = "mcp_server"
    branch: str = "main"

    # Link pattern for markdown lists
    # Matches: - [Name](url) - Description
    # Also: * [Name](url): Description
    link_pattern = re.compile(
        r"[-*]\s*\[([^\]]+)\]\(([^)]+)\)\s*[-\u2013:]?\s*(.*)",
        re.MULTILINE,
    )

    def __init__(self):
        super().__init__()
        self._readme_content: str | None = None

    async def fetch_page(self, page: int) -> str | None:
        """Fetch README content from GitHub.

        README files don't have pages, so page=1 fetches content,
        page>1 returns None to signal completion.
        """
        if page > 1:
            return None  # README has no pagination

        if self._readme_content is not None:
            return self._readme_content

        content = self._fetch_readme_via_gh()
        if content:
            self._readme_content = content
            return content

        return None

    def _fetch_readme_via_gh(self) -> str | None:
        """Fetch README using GitHub CLI."""
        if not self.repo:
            logger.error("No repository specified for README collector")
            return None

        cmd = [
            "gh", "api",
            f"repos/{self.repo}/readme",
            "--jq", ".content",
        ]

        try:
            result = subprocess.run(cmd, capture_output=True, text=True, check=True)
            # GitHub API returns base64-encoded content
            content = base64.b64decode(result.stdout.strip()).decode("utf-8")
            return content
        except subprocess.CalledProcessError as e:
            logger.error(f"Failed to fetch {self.repo} README: {e.stderr}")
            return None
        except Exception as e:
            logger.error(f"Failed to decode {self.repo} README: {e}")
            return None

    def extract_components(self, readme: str) -> list[RawComponent]:
        """Extract component links from README markdown."""
        components = []

        for match in self.link_pattern.finditer(readme):
            name = match.group(1).strip()
            url = match.group(2).strip()
            description = match.group(3).strip() if match.group(3) else None

            # Skip non-component links
            if not self._is_valid_component_link(url):
                continue

            # Extract author from GitHub URL
            author = self._extract_author(url)

            # Infer component type
            kind = self._infer_kind_from_link(name, url, description)

            components.append({
                "name": name,
                "url": url,
                "description": description,
                "author": author,
                "githubUrl": url if "github.com" in url else None,
                "type": kind,
            })

        return components

    def _is_valid_component_link(self, url: str) -> bool:
        """Check if URL is a valid component link."""
        # Skip common non-component URLs
        skip_patterns = [
            r"^#",  # Anchor links
            r"shields\.io",  # Badges
            r"\.(png|jpg|gif|svg|ico)$",  # Images
            r"twitter\.com",  # Social
            r"discord\.com",  # Social
            r"x\.com",  # Social
        ]

        for pattern in skip_patterns:
            if re.search(pattern, url, re.IGNORECASE):
                return False

        # Must be HTTP(S) URL
        return url.startswith(("http://", "https://"))

    def _extract_author(self, url: str) -> str | None:
        """Extract author/owner from URL."""
        # GitHub pattern: github.com/owner/repo
        github_match = re.match(r"https://github\.com/([^/]+)/", url)
        if github_match:
            return github_match.group(1)

        # npm pattern: npmjs.com/package/@scope/name or /package/name
        npm_match = re.match(r"https://(?:www\.)?npmjs\.com/package/(?:@([^/]+)/)?", url)
        if npm_match and npm_match.group(1):
            return npm_match.group(1)

        return None

    def _infer_kind_from_link(
        self,
        name: str,
        url: str,
        description: str | None,
    ) -> str:
        """Infer component kind from link context."""
        text = f"{name} {url} {description or ''}".lower()

        # MCP server patterns
        if "mcp" in text or "server" in text or "protocol" in text:
            return "mcp_server"

        # Skill patterns
        if "skill" in text or "ability" in text or "capability" in text:
            return "skill"

        # Agent patterns
        if "agent" in text or "assistant" in text:
            return "agent"

        # Hook patterns
        if "hook" in text or "event" in text:
            return "hook"

        # Plugin patterns
        if "plugin" in text or "extension" in text:
            return "plugin"

        # Default to the collector's default kind
        return self.default_kind

    def infer_kind(self, raw: RawComponent) -> str:
        """Override to use pre-inferred kind if available."""
        if "type" in raw and raw["type"]:
            return raw["type"]
        return self.default_kind

    def transform(self, raw: RawComponent, kind: str | None = None) -> dict:
        """Transform with source name based on repo."""
        component = super().transform(raw, kind)
        # Override source_name and source_url for awesome lists
        component["source_name"] = f"awesome:{self.repo}"
        component["source_type"] = "awesome_list"
        component["source_url"] = f"https://github.com/{self.repo}"
        return component
