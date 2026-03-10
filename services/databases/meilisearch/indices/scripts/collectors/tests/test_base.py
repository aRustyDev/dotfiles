"""Unit tests for collectors.base module."""

from __future__ import annotations

import pytest

from collectors.base import (
    BaseCollector,
    ClaimData,
    CollectResult,
    CollectionMethod,
    COMPONENT_KINDS,
)


class TestComponentKinds:
    """Tests for COMPONENT_KINDS constant."""

    def test_component_kinds_is_frozenset(self):
        """COMPONENT_KINDS should be immutable."""
        assert isinstance(COMPONENT_KINDS, frozenset)

    def test_component_kinds_contains_expected_values(self):
        """COMPONENT_KINDS should contain all expected kinds."""
        expected = {"skill", "agent", "command", "rule", "prompt", "hook", "mcp_server", "plugin"}
        assert COMPONENT_KINDS == expected


class TestCollectionMethod:
    """Tests for CollectionMethod enum."""

    def test_collection_method_values(self):
        """CollectionMethod should have expected string values."""
        assert CollectionMethod.API.value == "api"
        assert CollectionMethod.SCRAPE.value == "scrape"
        assert CollectionMethod.BROWSER.value == "browser"
        assert CollectionMethod.README.value == "readme"
        assert CollectionMethod.SEARCH.value == "search"

    def test_collection_method_is_string(self):
        """CollectionMethod should be usable as string via .value."""
        assert CollectionMethod.API.value == "api"
        assert CollectionMethod.BROWSER.value == "browser"
        # Also works as str subclass for comparison
        assert CollectionMethod.API == "api"


class TestClaimData:
    """Tests for ClaimData dataclass."""

    def test_claim_data_minimal(self):
        """ClaimData with only required fields."""
        claim = ClaimData(total=100)
        assert claim.total == 100
        assert claim.by_kind is None
        assert claim.source == "homepage"
        assert claim.notes is None
        assert claim.extracted_at is not None

    def test_claim_data_full(self, sample_claim_data):
        """ClaimData with all fields."""
        assert sample_claim_data.total == 100
        assert sample_claim_data.by_kind == {"skill": 60, "mcp_server": 40}
        assert sample_claim_data.source == "homepage"
        assert sample_claim_data.notes == "Test claim"

    def test_claim_data_to_dict(self, sample_claim_data):
        """ClaimData serialization to dict."""
        d = sample_claim_data.to_dict()
        assert d["total"] == 100
        assert d["by_kind"] == {"skill": 60, "mcp_server": 40}
        assert d["source"] == "homepage"
        assert "extracted_at" in d


class TestCollectResult:
    """Tests for CollectResult dataclass."""

    def test_collect_result_empty(self):
        """Empty CollectResult."""
        result = CollectResult()
        assert result.total == 0
        assert result.success is True
        assert result.skipped is False
        assert result.new_count == 0

    def test_collect_result_with_components(self):
        """CollectResult with components."""
        result = CollectResult(
            components=[{"name": "test"}],
            new_count=1,
            pages_crawled=5,
        )
        assert result.total == 1
        assert result.success is True
        assert result.pages_crawled == 5

    def test_collect_result_skipped(self):
        """Skipped CollectResult."""
        result = CollectResult(skipped=True, reason="Already completed")
        assert result.success is False
        assert result.reason == "Already completed"

    def test_collect_result_with_errors(self):
        """CollectResult with errors."""
        result = CollectResult(errors=["Connection failed"])
        assert result.success is False
        assert len(result.errors) == 1


class TestSanitizeId:
    """Tests for BaseCollector._sanitize_id()."""

    def test_sanitize_lowercase(self):
        """Should lowercase the input."""
        assert BaseCollector._sanitize_id("UPPERCASE") == "uppercase"
        assert BaseCollector._sanitize_id("MixedCase") == "mixedcase"

    def test_sanitize_spaces_to_dashes(self):
        """Should convert spaces to dashes."""
        assert BaseCollector._sanitize_id("hello world") == "hello-world"
        assert BaseCollector._sanitize_id("multi word input") == "multi-word-input"

    def test_sanitize_slashes_to_underscores(self):
        """Should convert slashes to underscores."""
        assert BaseCollector._sanitize_id("foo/bar/baz") == "foo_bar_baz"

    def test_sanitize_dots_to_dashes(self):
        """Should convert dots to dashes."""
        assert BaseCollector._sanitize_id("some.dotted.name") == "some-dotted-name"

    def test_sanitize_colons_to_underscores(self):
        """Should convert colons to underscores."""
        assert BaseCollector._sanitize_id("user:project") == "user_project"

    def test_sanitize_removes_invalid_chars(self):
        """Should remove characters not matching [a-z0-9_-]."""
        assert BaseCollector._sanitize_id("test@v1.2.3") == "testv1-2-3"
        assert BaseCollector._sanitize_id("name(with)parens") == "namewithparens"
        assert BaseCollector._sanitize_id("a#b$c%d") == "abcd"

    def test_sanitize_collapses_separators(self):
        """Should collapse multiple consecutive separators to underscore."""
        # Implementation collapses to underscore
        assert BaseCollector._sanitize_id("a--b") == "a_b"
        assert BaseCollector._sanitize_id("a__b") == "a_b"
        assert BaseCollector._sanitize_id("a--b__c") == "a_b_c"

    def test_sanitize_strips_leading_trailing(self):
        """Should strip leading/trailing dashes and underscores."""
        assert BaseCollector._sanitize_id("-leading") == "leading"
        assert BaseCollector._sanitize_id("trailing-") == "trailing"
        assert BaseCollector._sanitize_id("_both_") == "both"
        assert BaseCollector._sanitize_id("-_mixed_-") == "mixed"

    def test_sanitize_empty_string(self):
        """Should handle empty string."""
        assert BaseCollector._sanitize_id("") == ""

    def test_sanitize_only_invalid_chars(self):
        """Should return empty for strings with only invalid chars."""
        assert BaseCollector._sanitize_id("@#$%") == ""
        assert BaseCollector._sanitize_id("___") == ""
        assert BaseCollector._sanitize_id("---") == ""

    def test_sanitize_real_world_examples(self):
        """Should handle real-world component IDs."""
        # GitHub-style IDs
        assert BaseCollector._sanitize_id("anthropics/mcp-servers") == "anthropics_mcp-servers"

        # Smithery-style IDs
        result = BaseCollector._sanitize_id("smithery.ai/servers/neon-mcp")
        assert result == "smithery-ai_servers_neon-mcp"

        # Complex paths
        assert BaseCollector._sanitize_id("@owner/package-name") == "owner_package-name"

    @pytest.mark.parametrize("input_id,expected", [
        ("simple", "simple"),
        ("with-dash", "with-dash"),
        ("with_underscore", "with_underscore"),
        ("123numeric", "123numeric"),
        ("MixedCase123", "mixedcase123"),
    ])
    def test_sanitize_valid_ids_unchanged(self, input_id, expected):
        """Valid IDs should remain mostly unchanged."""
        assert BaseCollector._sanitize_id(input_id) == expected


class TestExtractGithubOwner:
    """Tests for BaseCollector._extract_github_owner()."""

    @pytest.fixture
    def collector(self, mock_api_collector):
        """Get a collector instance for testing."""
        return mock_api_collector

    def test_extract_owner_standard_https(self, collector):
        """Should extract owner from standard HTTPS URLs."""
        assert collector._extract_github_owner("https://github.com/owner/repo") == "owner"
        assert collector._extract_github_owner("https://github.com/anthropics/mcp") == "anthropics"

    def test_extract_owner_with_www(self, collector):
        """Should handle www prefix."""
        assert collector._extract_github_owner("https://www.github.com/owner/repo") == "owner"

    def test_extract_owner_http(self, collector):
        """Should handle HTTP URLs."""
        assert collector._extract_github_owner("http://github.com/owner/repo") == "owner"

    def test_extract_owner_with_path(self, collector):
        """Should handle URLs with additional path segments."""
        assert collector._extract_github_owner("https://github.com/owner/repo/tree/main") == "owner"
        assert collector._extract_github_owner("https://github.com/owner/repo/blob/main/README.md") == "owner"

    def test_extract_owner_with_fragment(self, collector):
        """Should handle URLs with fragments."""
        assert collector._extract_github_owner("https://github.com/owner/repo#readme") == "owner"

    def test_extract_owner_special_chars_in_name(self, collector):
        """Should handle special characters in owner/repo names."""
        assert collector._extract_github_owner("https://github.com/Owner-Name/Repo.Name") == "Owner-Name"
        assert collector._extract_github_owner("https://github.com/user_123/repo-456") == "user_123"

    def test_extract_owner_none_input(self, collector):
        """Should return None for None input."""
        assert collector._extract_github_owner(None) is None

    def test_extract_owner_empty_string(self, collector):
        """Should return None for empty string."""
        assert collector._extract_github_owner("") is None

    def test_extract_owner_non_github_url(self, collector):
        """Should return None for non-GitHub URLs."""
        assert collector._extract_github_owner("https://gitlab.com/owner/repo") is None
        assert collector._extract_github_owner("https://example.com/something") is None

    def test_extract_owner_invalid_url(self, collector):
        """Should return None for invalid URLs."""
        assert collector._extract_github_owner("not-a-url") is None
        assert collector._extract_github_owner("github.com/owner/repo") is None  # Missing scheme


class TestTransform:
    """Tests for BaseCollector.transform()."""

    @pytest.fixture
    def collector(self, mock_api_collector):
        """Get a collector instance for testing."""
        return mock_api_collector

    def test_transform_basic(self, collector, sample_raw_component):
        """Should transform basic component data."""
        result = collector.transform(sample_raw_component)

        assert result["name"] == "Test Component"
        assert result["description"] == "A test component for testing"
        assert result["source_name"] == "mock_api"
        assert "id" in result
        assert "type" in result

    def test_transform_generates_id(self, collector, sample_raw_component):
        """Should generate sanitized ID."""
        result = collector.transform(sample_raw_component)

        # ID should be sanitized
        assert result["id"]
        assert result["id"] == result["id"].lower()
        assert all(c in "abcdefghijklmnopqrstuvwxyz0123456789_-" for c in result["id"])

    def test_transform_extracts_github_owner(self, collector, sample_raw_component):
        """Should extract GitHub owner as author fallback."""
        result = collector.transform(sample_raw_component)

        # Should have author from either explicit field or GitHub URL
        assert result.get("author") is not None

    def test_transform_minimal_component(self, collector, sample_raw_component_minimal):
        """Should handle minimal component data."""
        result = collector.transform(sample_raw_component_minimal)

        assert result["name"] == "Minimal"
        assert result["source_name"] == "mock_api"
        assert "id" in result

    def test_transform_preserves_stars(self, collector, sample_raw_component):
        """Should preserve stars count as star_count."""
        result = collector.transform(sample_raw_component)
        # Stars are stored as star_count in the schema
        assert result.get("star_count") == 42

    def test_transform_preserves_tags(self, collector, sample_raw_component):
        """Should preserve tags/keywords."""
        result = collector.transform(sample_raw_component)
        # Tags might be under "tags" or "keywords"
        tags = result.get("tags") or result.get("keywords")
        assert tags == ["test", "example"]


class TestInferKind:
    """Tests for BaseCollector.infer_kind()."""

    @pytest.fixture
    def collector(self, mock_api_collector):
        """Get a collector instance for testing."""
        return mock_api_collector

    def test_infer_kind_explicit_type(self, collector):
        """Should use explicit type field if present."""
        raw = {"type": "skill", "name": "Test"}
        assert collector.infer_kind(raw) == "skill"

    def test_infer_kind_from_kind_field(self, collector):
        """Should use kind field if present."""
        raw = {"kind": "mcp_server", "name": "Test"}
        assert collector.infer_kind(raw) == "mcp_server"

    def test_infer_kind_from_category(self, collector):
        """Should map category to kind."""
        raw = {"category": "tools", "name": "Test"}
        # Default might infer from category
        result = collector.infer_kind(raw)
        assert result in COMPONENT_KINDS or result == "skill"  # Default fallback

    def test_infer_kind_default_fallback(self, collector):
        """Should return a valid kind when can't infer from data."""
        raw = {"name": "Test"}
        result = collector.infer_kind(raw)
        # Should return some valid kind (either from supported_kinds or COMPONENT_KINDS)
        assert result in COMPONENT_KINDS


class TestAsyncContextManager:
    """Tests for async context manager protocol."""

    @pytest.mark.asyncio
    async def test_async_context_manager(self, mock_api_collector):
        """Should support async with syntax."""
        async with mock_api_collector as collector:
            assert collector is not None
            assert collector.registry_name == "mock_api"

    @pytest.mark.asyncio
    async def test_close_called_on_exit(self, mock_api_collector):
        """Should call close on context exit."""
        close_called = False
        original_close = mock_api_collector.close

        async def tracking_close():
            nonlocal close_called
            close_called = True
            await original_close()

        mock_api_collector.close = tracking_close

        async with mock_api_collector:
            pass

        assert close_called


class TestValidateExtracted:
    """Tests for BaseCollector.validate_extracted()."""

    @pytest.fixture
    def collector(self, mock_api_collector):
        """Get a collector instance for testing."""
        return mock_api_collector

    def test_valid_components_pass(self, collector):
        """Should pass valid components through."""
        components = [
            {"name": "Test 1", "url": "https://example.com"},
            {"name": "Test 2", "description": "A test"},
        ]
        result = collector.validate_extracted(components)
        assert len(result) == 2

    def test_invalid_components_filtered(self, collector):
        """Should filter out components missing required name field."""
        components = [
            {"name": "Valid"},
            {},  # Missing name - invalid
            {"url": "https://example.com"},  # Missing name - invalid
        ]
        result = collector.validate_extracted(components)
        assert len(result) == 1
        assert result[0]["name"] == "Valid"

    def test_empty_name_filtered(self, collector):
        """Should filter out components with empty name."""
        components = [
            {"name": "Valid"},
            {"name": ""},  # Empty name - invalid
        ]
        result = collector.validate_extracted(components)
        assert len(result) == 1

    def test_preserves_extra_fields(self, collector):
        """Should preserve extra fields from registries."""
        components = [
            {"name": "Test", "custom_field": "value", "another": 123},
        ]
        result = collector.validate_extracted(components)
        assert len(result) == 1
        assert result[0]["custom_field"] == "value"

    def test_empty_list_returns_empty(self, collector):
        """Should return empty list for empty input."""
        result = collector.validate_extracted([])
        assert result == []
