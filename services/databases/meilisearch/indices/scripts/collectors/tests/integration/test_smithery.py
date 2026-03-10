"""Integration tests for SmitheryCollector.

Uses fixtures with sample markdown content to test extraction
without network access.
"""

from __future__ import annotations

import json
from pathlib import Path

import pytest

from collectors.registries.smithery import SmitheryCollector, SmitherySkillsCollector


FIXTURES_DIR = Path(__file__).parent / "fixtures"


@pytest.fixture
def smithery_page1() -> str:
    """Load sample Smithery page 1 fixture."""
    return (FIXTURES_DIR / "smithery_page1.md").read_text()


@pytest.fixture
def collector() -> SmitheryCollector:
    """Create a SmitheryCollector instance."""
    return SmitheryCollector()


@pytest.fixture
def skills_collector() -> SmitherySkillsCollector:
    """Create a SmitherySkillsCollector instance."""
    return SmitherySkillsCollector()


class TestSmitheryExtractComponents:
    """Tests for SmitheryCollector.extract_components()."""

    def test_extracts_servers(self, collector, smithery_page1):
        """Should extract MCP server components."""
        components = collector.extract_components(smithery_page1)

        # Should find all unique servers
        servers = [c for c in components if c.get("type") == "mcp_server"]
        assert len(servers) >= 5

        # Check a specific server
        filesystem = next(
            (c for c in servers if "filesystem" in c.get("name", "").lower()),
            None,
        )
        assert filesystem is not None
        assert filesystem["author"] == "anthropics"
        assert "smithery.ai/servers" in filesystem["url"]

    def test_extracts_skills(self, collector, smithery_page1):
        """Should extract skill components."""
        components = collector.extract_components(smithery_page1)

        skills = [c for c in components if c.get("type") == "skill"]
        assert len(skills) >= 2

    def test_extracts_author(self, collector, smithery_page1):
        """Should extract author from path."""
        components = collector.extract_components(smithery_page1)

        for comp in components:
            # All should have authors from the path
            assert comp.get("author") is not None

    def test_deduplicates_urls(self, collector):
        """Should not extract duplicate URLs."""
        markdown = """
        - [Server A](https://smithery.ai/servers/owner/server-a)
        - [Server A Again](https://smithery.ai/servers/owner/server-a)
        - [Server B](https://smithery.ai/servers/owner/server-b)
        """
        components = collector.extract_components(markdown)
        paths = [c.get("path") for c in components]
        assert len(paths) == len(set(paths))

    def test_skips_pagination_urls(self, collector):
        """Should skip pagination URLs."""
        markdown = """
        - [Server](https://smithery.ai/servers/owner/real-server)
        - [Page 2](https://smithery.ai/servers?page=2)
        """
        components = collector.extract_components(markdown)
        assert len(components) == 1
        assert "real-server" in components[0]["path"]


class TestSmitheryTransform:
    """Tests for SmitheryCollector.transform()."""

    def test_generates_unique_id(self, collector):
        """Should generate unique ID from path."""
        raw = {
            "name": "My Server",
            "url": "https://smithery.ai/servers/owner/my-server",
            "author": "owner",
            "type": "mcp_server",
            "path": "owner/my-server",
        }
        result = collector.transform(raw)

        assert result["id"] == "smithery_ai_owner_my_server"
        assert result["type"] == "mcp_server"
        assert result["source_name"] == "smithery.ai"

    def test_preserves_author(self, collector):
        """Should preserve author from raw data."""
        raw = {
            "name": "Test",
            "author": "testuser",
            "type": "skill",
            "path": "testuser/test",
        }
        result = collector.transform(raw)
        assert result["author"] == "testuser"


class TestSmitheryClaimExtraction:
    """Tests for SmitheryCollector.extract_claim() patterns."""

    def test_extracts_from_homepage_text(self, collector, smithery_page1):
        """Should extract count from '4,000+ MCP servers' pattern."""
        # This tests the regex pattern, not the actual fetch
        import re

        count_pattern = re.compile(
            r'(\d[\d,]*)\+?\s*(?:MCP\s+)?(?:servers?|tools?|skills?)',
            re.IGNORECASE,
        )
        match = count_pattern.search(smithery_page1)

        assert match is not None
        count_str = match.group(1).replace(",", "")
        assert int(count_str) == 4000

    def test_extracts_from_pagination(self, collector, smithery_page1):
        """Should extract page count from 'Page 1 of 182' pattern."""
        import re

        page_pattern = re.compile(
            r'(?:page\s+)?(\d+)\s*(?:of|/)\s*(\d+)',
            re.IGNORECASE,
        )
        match = page_pattern.search(smithery_page1)

        assert match is not None
        assert int(match.group(2)) == 182


class TestSmitherySkillsCollector:
    """Tests for SmitherySkillsCollector."""

    def test_infers_skill_kind(self, skills_collector):
        """Should always infer kind as skill."""
        raw = {"name": "Test", "url": "https://smithery.ai/skills/test"}
        assert skills_collector.infer_kind(raw) == "skill"

    def test_has_correct_base_url(self, skills_collector):
        """Should target skills endpoint."""
        assert "/skills" in skills_collector.base_url

    def test_only_supports_skills(self, skills_collector):
        """Should only support skill kind."""
        assert skills_collector.supported_kinds == {"skill"}


@pytest.mark.regression
class TestSmitheryRegression:
    """Regression tests to catch extraction pattern changes."""

    def test_extraction_golden_output(self, collector, smithery_page1):
        """Ensure extraction produces expected components.

        This test will fail if the extraction pattern changes,
        alerting us to review the change.
        """
        components = collector.extract_components(smithery_page1)

        # Convert to sorted list for consistent comparison
        names = sorted(c["name"] for c in components)

        # Golden output - update if extraction pattern intentionally changes
        # Names are derived from the last path segment with dashes replaced by spaces
        expected_names = [
            "code review",
            "database tools",
            "documentation",
            "filesystem mcp",
            "mcp github",
            "mcp slack",
            "web crawler",
        ]

        assert names == expected_names
