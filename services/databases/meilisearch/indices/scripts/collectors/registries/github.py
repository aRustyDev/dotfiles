"""
GitHub collector for Claude Code components via topic search.

Uses GitHub CLI (gh) for authenticated API access.
"""

from __future__ import annotations

import json
import logging
import subprocess
from typing import Any

from collectors.base import BaseCollector, CollectionMethod, CollectResult, RawComponent
from collectors.rate_limit import RateLimitConfig
from collectors.state import CrawlState

logger = logging.getLogger(__name__)


class GitHubCollector(BaseCollector):
    """GitHub topic search collector.

    Uses the gh CLI to search for repositories by topic.
    Maps topics to component kinds.
    """

    registry_name = "github"
    supported_kinds = {"skill", "agent", "hook", "mcp_server", "plugin"}
    method = CollectionMethod.API

    rate_limit = RateLimitConfig(delay=2.0, daily_limit=5000)

    # Topic to component kind mapping
    topics = [
        ("claude-skills", "skill"),
        ("claude-code-agents", "agent"),
        ("claude-code-hooks", "hook"),
        ("mcp-server", "mcp_server"),
        ("claude-code-plugin", "plugin"),
    ]

    # Search configuration
    results_per_topic = 100
    sort_by = "stars"

    async def fetch_page(self, page: int) -> dict | None:
        """GitHub uses topic-based fetching, not pages."""
        # This is handled specially in collect()
        return None

    def extract_components(self, raw: dict) -> list[RawComponent]:
        """Extract from gh search results."""
        return raw.get("repos", [])

    async def collect(
        self,
        kinds: set[str] | None = None,
        state: CrawlState | None = None,
        output_file=None,
        dry_run: bool = False,
    ) -> CollectResult:
        """Collect components from GitHub topics.

        Overrides base collect() because GitHub uses topic-based
        fetching rather than page-based.
        """
        # Filter topics by requested kinds
        topics_to_search = []
        for topic, kind in self.topics:
            if kinds is None or kind in kinds:
                topics_to_search.append((topic, kind))

        if not topics_to_search:
            return CollectResult(
                skipped=True,
                reason=f"no_matching_kinds: requested {kinds}",
            )

        # Get completed topics from state
        completed_topics: set[str] = set()
        if state:
            reg_state = state.get_registry_state(self.registry_name)
            completed_topics = set(reg_state.topics_completed)

        result = CollectResult()
        existing_ids: set[str] = set()

        # Load existing IDs for deduplication
        if output_file and output_file.exists():
            existing_ids = self._load_existing_ids(output_file)

        for topic, kind in topics_to_search:
            if topic in completed_topics:
                logger.info(f"Skipping {topic} (already completed)")
                continue

            if dry_run:
                logger.info(f"[DRY RUN] Would search: topic:{topic}")
                continue

            logger.info(f"Searching topic: {topic}")
            repos = self._search_topic(topic)

            for repo in repos:
                component = self._transform_repo(repo, kind)

                # Deduplicate
                if component["id"] in existing_ids:
                    result.duplicate_count += 1
                    continue

                existing_ids.add(component["id"])
                result.components.append(component)
                result.new_count += 1

            # Write to output
            if output_file and result.components:
                self._append_to_file(output_file, result.components)

            # Update state
            if state:
                reg_state = state.get_registry_state(self.registry_name)
                reg_state.topics_completed.append(topic)
                reg_state.total_fetched = len(result.components)
                state.save()

            logger.info(f"Topic {topic}: fetched {len(repos)} repos")

        # Mark completed if all topics done
        if state:
            reg_state = state.get_registry_state(self.registry_name)
            if len(reg_state.topics_completed) >= len(self.topics):
                state.mark_completed(self.registry_name, result.total)

        return result

    def _search_topic(self, topic: str) -> list[dict]:
        """Search GitHub for repositories with given topic."""
        cmd = [
            "gh", "search", "repos",
            f"topic:{topic}",
            "--sort", self.sort_by,
            "--limit", str(self.results_per_topic),
            "--json", "name,url,description,stargazersCount,owner",
        ]

        try:
            result = subprocess.run(cmd, capture_output=True, text=True, check=True)
            return json.loads(result.stdout)
        except subprocess.CalledProcessError as e:
            logger.error(f"gh search failed for {topic}: {e.stderr}")
            return []
        except json.JSONDecodeError as e:
            logger.error(f"Failed to parse gh output: {e}")
            return []

    def _transform_repo(self, repo: dict, kind: str) -> dict:
        """Transform GitHub repo to component format."""
        owner = repo.get("owner", {})
        owner_login = owner.get("login") if isinstance(owner, dict) else owner

        return {
            "id": self._sanitize_id(f"github_{owner_login}_{repo.get('name', 'unknown')}"),
            "name": repo.get("name", "unknown"),
            "type": kind,
            "description": repo.get("description"),
            "author": owner_login,
            "canonical_url": repo.get("url"),
            "github_url": repo.get("url"),
            "star_count": repo.get("stargazersCount", 0),
            "source_type": "github",
            "source_name": "github",
            "source_url": "https://github.com",
            "tags": [],  # Topics could be fetched separately
            "discovered_at": __import__("datetime").datetime.now(
                __import__("datetime").timezone.utc
            ).isoformat(),
            "quality_tier": "bronze",
        }

    def infer_kind(self, raw: RawComponent) -> str:
        """Kind is determined by topic during collection."""
        return raw.get("type", "plugin")
