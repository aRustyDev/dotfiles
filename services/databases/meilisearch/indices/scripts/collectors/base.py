"""
Base collector abstract class and shared utilities.

Provides the foundation for all registry collectors with common
functionality for transformation, validation, and state management.
"""

from __future__ import annotations

import asyncio
import json
import logging
import re
import time
from abc import ABC, abstractmethod
from dataclasses import dataclass, field
from datetime import UTC, datetime
from enum import Enum
from pathlib import Path
from typing import TYPE_CHECKING, Any, TypeVar

import httpx

from collectors.rate_limit import BackoffConfig, DEFAULT_BACKOFF, RateLimitConfig, get_rate_limit
from collectors.state import CrawlState, RegistryState
from collectors.models import (
    ComponentModel,
    RawComponentModel,
    validate_raw_component,
    VALID_KINDS,
)

if TYPE_CHECKING:
    from collections.abc import AsyncIterator, Iterator

logger = logging.getLogger(__name__)

# Component kinds from schema
COMPONENT_KINDS = frozenset({
    "skill", "agent", "command", "rule", "prompt", "hook", "mcp_server", "plugin"
})


class CollectionMethod(str, Enum):
    """Annotated collection methods for registries."""

    API = "api"  # HTTP JSON APIs (httpx)
    SCRAPE = "scrape"  # HTML scraping (Scrapling)
    BROWSER = "browser"  # JS rendering (crawl4ai, Playwright)
    README = "readme"  # Awesome list parsing (BeautifulSoup)
    SEARCH = "search"  # SearXNG discovery


@dataclass
class ClaimData:
    """Data about a registry's advertised component count.

    Represents what the registry *claims* to have, extracted from
    homepage stats, pagination metadata, or API responses.
    """

    total: int
    by_kind: dict[str, int] | None = None
    source: str = "homepage"  # "homepage", "pagination", "api_meta", "search_count"
    extracted_at: str = field(default_factory=lambda: datetime.now(UTC).isoformat())
    notes: str | None = None

    def to_dict(self) -> dict:
        """Convert to dictionary for JSON serialization."""
        return {
            "total": self.total,
            "by_kind": self.by_kind,
            "source": self.source,
            "extracted_at": self.extracted_at,
            "notes": self.notes,
        }


@dataclass
class CollectResult:
    """Result from a collection operation."""

    components: list[dict] = field(default_factory=list)
    skipped: bool = False
    reason: str | None = None
    errors: list[str] = field(default_factory=list)
    pages_crawled: int = 0
    new_count: int = 0
    duplicate_count: int = 0

    @property
    def total(self) -> int:
        return len(self.components)

    @property
    def success(self) -> bool:
        return not self.skipped and not self.errors


# Type alias for raw component data
RawComponent = dict[str, Any]


class BaseCollector(ABC):
    """Abstract base for all registry collectors."""

    # Class attributes - override in subclasses
    registry_name: str = ""
    supported_kinds: set[str] = set()
    method: CollectionMethod = CollectionMethod.API

    # Configuration
    rate_limit: RateLimitConfig = RateLimitConfig()
    backoff: BackoffConfig = DEFAULT_BACKOFF

    def __init__(self):
        """Initialize collector with rate limit config."""
        if not self.rate_limit.delay:
            self.rate_limit = get_rate_limit(self.registry_name)

    async def close(self) -> None:
        """Close any resources. Override in subclasses."""
        pass

    async def __aenter__(self):
        """Async context manager entry."""
        return self

    async def __aexit__(self, exc_type, exc_val, exc_tb):
        """Async context manager exit."""
        await self.close()

    async def extract_claim(self) -> ClaimData | None:
        """Extract the registry's advertised component count.

        Fetches and parses the site's claimed total from homepage stats,
        pagination metadata, or API responses. This represents what the
        registry *says* it has, not what we actually collect.

        Returns:
            ClaimData with the advertised total, or None if:
            - The site doesn't display a count
            - Count extraction is not implemented for this registry
            - Extraction failed

        Note:
            Subclasses should override this to implement registry-specific
            claim extraction logic. The default returns None.
        """
        return None

    @abstractmethod
    async def fetch_page(self, page: int) -> Any | None:
        """Fetch a single page of data from the registry.

        Args:
            page: Page number to fetch (1-indexed)

        Returns:
            Raw page data (format depends on collector type), or None on failure
        """
        ...

    @abstractmethod
    def extract_components(self, raw: Any) -> list[RawComponent]:
        """Extract component data from raw page content.

        Args:
            raw: Raw page data from fetch_page

        Returns:
            List of raw component dictionaries
        """
        ...

    def validate_extracted(self, components: list[RawComponent]) -> list[RawComponent]:
        """Validate extracted components using Pydantic models.

        Filters out invalid components and logs warnings.
        Subclasses can override for custom validation logic.

        Args:
            components: List of raw component dictionaries

        Returns:
            List of validated component dictionaries
        """
        validated = []
        for i, comp in enumerate(components):
            model = validate_raw_component(comp)
            if model is None:
                name = comp.get("name", f"<index {i}>")
                logger.warning(f"{self.registry_name}: Invalid component data for '{name}'")
                continue
            validated.append(comp)
        return validated

    def infer_kind(self, raw: RawComponent) -> str:
        """Infer component kind from raw data.

        Override for registry-specific logic. Default uses URL patterns
        and field presence heuristics.

        Args:
            raw: Raw component data dictionary

        Returns:
            Inferred kind from COMPONENT_KINDS (defaults to 'plugin')

        Examples:
            >>> from collectors.base import BaseCollector
            >>> class TestCollector(BaseCollector):
            ...     registry_name = "test"
            ...     async def fetch_page(self, page): pass
            ...     def extract_components(self, raw): return []
            >>> c = TestCollector()
            >>> c.infer_kind({"type": "skill", "name": "Test"})
            'skill'

            >>> c.infer_kind({"kind": "mcp_server", "name": "Test"})
            'mcp_server'

            >>> c.infer_kind({"url": "/servers/test", "name": "Test"})
            'mcp_server'

            >>> c.infer_kind({"name": "unknown"})
            'plugin'
        """
        # Check explicit type field first
        if "type" in raw and raw["type"] in COMPONENT_KINDS:
            return raw["type"]
        if "kind" in raw and raw["kind"] in COMPONENT_KINDS:
            return raw["kind"]

        # URL-based heuristics
        url = raw.get("url", "") or raw.get("canonical_url", "") or ""
        if "/skills/" in url or raw.get("skillUrl"):
            return "skill"
        if "/servers/" in url or "/server/" in url:
            return "mcp_server"
        if "/agents/" in url:
            return "agent"

        # Field presence heuristics
        if raw.get("tools") or raw.get("capabilities"):
            return "mcp_server"
        if raw.get("hooks") or "-hook" in raw.get("name", ""):
            return "hook"

        # Name pattern heuristics
        name = raw.get("name", "").lower()
        if "mcp" in name or "server" in name:
            return "mcp_server"
        if "agent" in name:
            return "agent"
        if "hook" in name:
            return "hook"

        # Default to plugin as catch-all
        return "plugin"

    def transform(self, raw: RawComponent, kind: str | None = None) -> dict:
        """Transform raw data to schema-compliant component.

        Args:
            raw: Raw component data
            kind: Component kind, or None to infer

        Returns:
            Schema-compliant component dictionary

        Raises:
            ValueError: If the transformed component fails validation
        """
        inferred_kind = kind or self.infer_kind(raw)

        # Extract and normalize GitHub URL from any field (do this first for author fallback)
        github_url = self._extract_github_url(raw)

        # Extract author (with GitHub owner as fallback)
        author = raw.get("author")
        if not author and isinstance(raw.get("owner"), dict):
            author = raw.get("owner", {}).get("login")
        if not author:
            author = raw.get("owner")
        if not author and github_url:
            # Use GitHub repo owner as fallback
            author = self._extract_github_owner(github_url)

        # Build component ID
        name = raw.get("name", "unknown")
        component_id = self._sanitize_id(
            f"{self.registry_name}_{author or 'unknown'}_{name}"
        )

        # Extract canonical URL
        canonical_url = (
            raw.get("url")
            or raw.get("skillUrl")
            or raw.get("html_url")
            or raw.get("canonical_url")
        )

        component_data = {
            "id": component_id,
            "name": name,
            "type": inferred_kind,
            "description": raw.get("description"),
            "author": author,
            "canonical_url": canonical_url,
            "github_url": github_url,
            "star_count": raw.get("stars") or raw.get("stargazers_count") or raw.get("star_count") or 0,
            "source_type": "registry" if self.registry_name != "github" else "github",
            "source_name": self.registry_name,
            "source_url": f"https://{self.registry_name}" if "." in self.registry_name else f"https://{self.registry_name}.com",
            "tags": raw.get("keywords") or raw.get("topics") or raw.get("tags") or [],
            "discovered_at": datetime.now(UTC).isoformat(),
            "quality_tier": "bronze",
        }

        # Validate output against schema
        try:
            validated = ComponentModel(**component_data)
            return validated.model_dump()
        except Exception as e:
            logger.warning(f"{self.registry_name}: Transform validation failed for '{name}': {e}")
            # Return unvalidated data for backward compatibility (logged warning above)
            return component_data

    @staticmethod
    def _sanitize_id(raw_id: str) -> str:
        """Sanitize ID to match schema pattern ^[a-z0-9_-]+$.

        Transforms input strings into valid component IDs by:
        - Converting to lowercase
        - Replacing slashes and colons with underscores
        - Replacing spaces and dots with dashes
        - Removing invalid characters
        - Collapsing multiple separators
        - Stripping leading/trailing separators

        Args:
            raw_id: Raw identifier string to sanitize

        Returns:
            Sanitized ID matching ^[a-z0-9_-]+$

        Examples:
            >>> BaseCollector._sanitize_id("My Component Name")
            'my-component-name'

            >>> BaseCollector._sanitize_id("foo/bar/baz")
            'foo_bar_baz'

            >>> BaseCollector._sanitize_id("test@v1.2.3")
            'testv1-2-3'

            >>> BaseCollector._sanitize_id("anthropics/mcp-servers")
            'anthropics_mcp-servers'

            >>> BaseCollector._sanitize_id("")
            ''

            >>> BaseCollector._sanitize_id("---")
            ''
        """
        # Lowercase and replace common separators
        clean = raw_id.lower()
        clean = clean.replace("/", "_").replace(" ", "-").replace(".", "-").replace(":", "_")
        # Remove any remaining invalid characters
        clean = re.sub(r"[^a-z0-9_-]", "", clean)
        # Collapse multiple separators
        clean = re.sub(r"[-_]{2,}", "_", clean)
        return clean.strip("-_")

    # GitHub URL patterns for extraction
    _GITHUB_URL_PATTERN = re.compile(
        r'https?://(?:www\.)?github\.com/([a-zA-Z0-9_.-]+)/([a-zA-Z0-9_.-]+)',
        re.IGNORECASE,
    )
    _GITHUB_SSH_PATTERN = re.compile(
        r'git@github\.com:([a-zA-Z0-9_.-]+)/([a-zA-Z0-9_.-]+?)(?:\.git)?(?:\s|$)',
        re.IGNORECASE,
    )
    _GITHUB_GIT_PATTERN = re.compile(
        r'git://github\.com/([a-zA-Z0-9_.-]+)/([a-zA-Z0-9_.-]+?)(?:\.git)?(?:\s|$)',
        re.IGNORECASE,
    )

    def _extract_github_url(self, raw: RawComponent) -> str | None:
        """Extract and normalize GitHub URL from any field in raw component data.

        Searches these fields in order:
        1. Explicit GitHub fields: github_url, githubUrl, repository
        2. General URL fields: html_url, url, canonical_url, homepage
        3. Text content: description (scans for GitHub links)

        Returns:
            Normalized GitHub URL (https://github.com/owner/repo) or None
        """
        # Priority 1: Explicit GitHub URL fields
        github_fields = ["github_url", "githubUrl", "repository", "repo", "source"]
        for field in github_fields:
            url = raw.get(field)
            if url and "github.com" in str(url):
                normalized = self._normalize_github_url(str(url))
                if normalized:
                    return normalized

        # Priority 2: General URL fields that might be GitHub
        url_fields = ["html_url", "url", "canonical_url", "homepage", "website", "link"]
        for field in url_fields:
            url = raw.get(field)
            if url and "github.com" in str(url):
                normalized = self._normalize_github_url(str(url))
                if normalized:
                    return normalized

        # Priority 3: Scan description and other text fields for GitHub links
        text_fields = ["description", "readme", "content", "body"]
        for field in text_fields:
            text = raw.get(field)
            if text and isinstance(text, str):
                # Try HTTPS pattern first
                match = self._GITHUB_URL_PATTERN.search(text)
                if match:
                    return f"https://github.com/{match.group(1)}/{match.group(2)}"

                # Try SSH pattern (git@github.com:owner/repo)
                match = self._GITHUB_SSH_PATTERN.search(text)
                if match:
                    return f"https://github.com/{match.group(1)}/{match.group(2)}"

                # Try git:// pattern
                match = self._GITHUB_GIT_PATTERN.search(text)
                if match:
                    return f"https://github.com/{match.group(1)}/{match.group(2)}"

        return None

    def _normalize_github_url(self, url: str) -> str | None:
        """Normalize GitHub URL to canonical https://github.com/owner/repo format.

        Handles various GitHub URL formats:
        - https://github.com/owner/repo
        - https://github.com/owner/repo.git
        - https://github.com/owner/repo/tree/main
        - https://github.com/owner/repo/blob/main/file.md
        - http://github.com/owner/repo (upgrades to https)
        - git://github.com/owner/repo.git
        - git@github.com:owner/repo.git

        Returns:
            Normalized URL or None if not a valid GitHub repo URL
        """
        if not url:
            return None

        # Handle git@ SSH format
        if url.startswith("git@github.com:"):
            path = url.replace("git@github.com:", "").replace(".git", "")
            parts = path.split("/")
            if len(parts) >= 2:
                return f"https://github.com/{parts[0]}/{parts[1]}"

        # Handle git:// protocol
        if url.startswith("git://github.com/"):
            url = url.replace("git://", "https://")

        # Extract owner/repo using regex
        match = self._GITHUB_URL_PATTERN.match(url)
        if match:
            owner = match.group(1)
            repo = match.group(2)

            # Remove .git suffix if present
            if repo.endswith(".git"):
                repo = repo[:-4]

            return f"https://github.com/{owner}/{repo}"

        return None

    def _extract_github_owner(self, github_url: str | None) -> str | None:
        """Extract owner from normalized GitHub URL.

        Parses a GitHub URL to extract the repository owner/organization name.

        Args:
            github_url: GitHub URL (https://github.com/owner/repo format)

        Returns:
            Owner/organization name, or None if URL is invalid

        Examples:
            >>> from collectors.base import BaseCollector
            >>> class TestCollector(BaseCollector):
            ...     registry_name = "test"
            ...     async def fetch_page(self, page): pass
            ...     def extract_components(self, raw): return []
            >>> c = TestCollector()
            >>> c._extract_github_owner("https://github.com/anthropics/mcp")
            'anthropics'

            >>> c._extract_github_owner("https://github.com/owner/repo/tree/main")
            'owner'

            >>> c._extract_github_owner(None) is None
            True

            >>> c._extract_github_owner("https://gitlab.com/owner/repo") is None
            True
        """
        if not github_url:
            return None

        match = self._GITHUB_URL_PATTERN.match(github_url)
        if match:
            return match.group(1)
        return None

    async def collect(
        self,
        kinds: set[str] | None = None,
        state: CrawlState | None = None,
        output_file: Path | None = None,
        dry_run: bool = False,
    ) -> CollectResult:
        """Collect components, filtered by kinds.

        Args:
            kinds: Component kinds to collect (None = all supported kinds)
            state: Crawl state for checkpoint/resume
            output_file: File to append NDJSON output
            dry_run: If True, don't actually fetch

        Returns:
            CollectResult with collected components
        """
        # Check if registry supports requested kinds
        if kinds and not (kinds & self.supported_kinds):
            return CollectResult(
                skipped=True,
                reason=f"no_matching_kinds: {self.registry_name} supports {self.supported_kinds}, requested {kinds}",
            )

        # Get resume point from state
        start_page = 1
        if state:
            if state.is_completed(self.registry_name):
                logger.info(f"{self.registry_name}: already completed, skipping")
                return CollectResult(skipped=True, reason="already_completed")
            start_page = state.get_resume_page(self.registry_name)
            if start_page > 1:
                logger.info(f"{self.registry_name}: resuming from page {start_page}")

        result = CollectResult()
        existing_ids: set[str] = set()

        # Load existing IDs for deduplication
        if output_file and output_file.exists():
            existing_ids = self._load_existing_ids(output_file)

        # Collect pages
        page = start_page
        consecutive_empty = 0
        max_empty = 2  # Stop after 2 consecutive empty pages

        while consecutive_empty < max_empty:
            if dry_run:
                logger.info(f"[DRY RUN] {self.registry_name} page {page}")
                page += 1
                if page > start_page + 2:
                    break
                continue

            logger.debug(f"{self.registry_name}: fetching page {page}")
            raw_page = await self.fetch_page(page)

            if raw_page is None:
                result.errors.append(f"Failed to fetch page {page}")
                consecutive_empty += 1
                page += 1
                continue

            raw_components = self.extract_components(raw_page)
            components = self.validate_extracted(raw_components)
            if not components:
                consecutive_empty += 1
                page += 1
                continue

            consecutive_empty = 0
            result.pages_crawled += 1

            # Transform and filter
            for raw in components:
                component = self.transform(raw)

                # Filter by kind if specified
                if kinds and component["type"] not in kinds:
                    continue

                # Deduplicate
                if component["id"] in existing_ids:
                    result.duplicate_count += 1
                    continue

                existing_ids.add(component["id"])
                result.components.append(component)
                result.new_count += 1

            # Write to output file
            if output_file and result.components:
                self._append_to_file(output_file, result.components[-len(components):])

            # Update state
            if state:
                state.update_progress(
                    self.registry_name,
                    page=page,
                    fetched=len(result.components),
                )

            logger.info(
                f"{self.registry_name} page {page}: "
                f"found {len(components)}, new: {result.new_count}"
            )

            page += 1
            await asyncio.sleep(self.rate_limit.delay)

        # Mark completed
        if state and consecutive_empty >= max_empty:
            state.mark_completed(self.registry_name, result.total)

        return result

    def _load_existing_ids(self, path: Path) -> set[str]:
        """Load IDs from existing NDJSON file for deduplication."""
        ids = set()
        if path.exists():
            with open(path) as f:
                for line in f:
                    if line.strip():
                        try:
                            comp = json.loads(line)
                            ids.add(comp.get("id"))
                        except json.JSONDecodeError:
                            pass
        return ids

    def _append_to_file(self, path: Path, components: list[dict]) -> None:
        """Append components to NDJSON file."""
        with open(path, "a") as f:
            for comp in components:
                f.write(json.dumps(comp) + "\n")


async def fetch_with_backoff(
    url: str,
    client: httpx.AsyncClient,
    backoff: BackoffConfig = DEFAULT_BACKOFF,
) -> httpx.Response | None:
    """Fetch URL with exponential backoff on failures.

    Args:
        url: URL to fetch
        client: httpx async client
        backoff: Backoff configuration

    Returns:
        Response on success, None on failure after retries
    """
    delay = backoff.initial_delay

    for attempt in range(backoff.max_retries):
        try:
            response = await client.get(url, timeout=30)

            if response.status_code == 429:  # Rate limited
                retry_after = int(response.headers.get("Retry-After", delay))
                logger.warning(
                    f"Rate limited, waiting {retry_after}s (attempt {attempt + 1})"
                )
                await asyncio.sleep(retry_after)
                continue

            if response.status_code >= 500:  # Server error
                logger.warning(
                    f"Server error {response.status_code}, backoff {delay}s"
                )
                await asyncio.sleep(delay)
                delay = min(delay * backoff.multiplier, backoff.max_delay)
                continue

            if response.status_code >= 400:
                logger.error(f"Client error {response.status_code}: {url}")
                return None

            return response

        except httpx.TimeoutException:
            logger.warning(f"Timeout, backoff {delay}s (attempt {attempt + 1})")
            await asyncio.sleep(delay)
            delay = min(delay * backoff.multiplier, backoff.max_delay)

        except httpx.ConnectError as e:
            logger.warning(f"Connection error: {e}, backoff {delay}s")
            await asyncio.sleep(delay)
            delay = min(delay * backoff.multiplier, backoff.max_delay)

    logger.error(f"FAILED after {backoff.max_retries} attempts: {url}")
    return None
