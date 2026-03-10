"""Unit tests for collectors.models module (Pydantic models)."""

from __future__ import annotations

import pytest
from pydantic import ValidationError

from collectors.models import (
    ClaimDataModel,
    ComponentModel,
    RawComponentModel,
    VALID_KINDS,
    VALID_QUALITY_TIERS,
    validate_claim,
    validate_raw_component,
)


class TestClaimDataModel:
    """Tests for ClaimDataModel Pydantic model."""

    def test_minimal_claim(self):
        """Should create claim with only required fields."""
        claim = ClaimDataModel(total=100)
        assert claim.total == 100
        assert claim.by_kind is None
        assert claim.source == "homepage"
        assert claim.extracted_at is not None

    def test_full_claim(self):
        """Should create claim with all fields."""
        claim = ClaimDataModel(
            total=500,
            by_kind={"skill": 200, "mcp_server": 300},
            source="pagination",
            source_url="https://example.com",
            notes="Test notes",
        )
        assert claim.total == 500
        assert claim.by_kind == {"skill": 200, "mcp_server": 300}
        assert claim.source == "pagination"

    def test_negative_total_fails(self):
        """Should reject negative total."""
        with pytest.raises(ValidationError) as exc_info:
            ClaimDataModel(total=-1)
        assert "total" in str(exc_info.value)

    def test_negative_by_kind_count_fails(self):
        """Should reject negative counts in by_kind."""
        with pytest.raises(ValidationError) as exc_info:
            ClaimDataModel(total=100, by_kind={"skill": -5})
        assert "Negative count" in str(exc_info.value)

    def test_invalid_kind_in_by_kind_fails(self):
        """Should reject invalid kinds in by_kind."""
        with pytest.raises(ValidationError) as exc_info:
            ClaimDataModel(total=100, by_kind={"invalid_kind": 50})
        assert "Invalid kind" in str(exc_info.value)

    def test_empty_source_fails(self):
        """Should reject empty source string."""
        with pytest.raises(ValidationError):
            ClaimDataModel(total=100, source="")

    def test_to_dict(self):
        """Should serialize to dict."""
        claim = ClaimDataModel(total=100, source="homepage")
        d = claim.to_dict()
        assert d["total"] == 100
        assert "extracted_at" in d

    def test_strips_whitespace(self):
        """Should strip whitespace from strings."""
        claim = ClaimDataModel(total=100, source="  homepage  ", notes="  note  ")
        assert claim.source == "homepage"
        assert claim.notes == "note"


class TestRawComponentModel:
    """Tests for RawComponentModel Pydantic model."""

    def test_minimal_component(self):
        """Should create component with only name."""
        comp = RawComponentModel(name="Test Component")
        assert comp.name == "Test Component"
        assert comp.url is None

    def test_full_component(self):
        """Should create component with all fields."""
        comp = RawComponentModel(
            name="Test Server",
            url="https://example.com",
            description="A test server",
            author="testuser",
            type="mcp_server",
            github_url="https://github.com/test/repo",
            stars=42,
            tags=["test", "example"],
        )
        assert comp.name == "Test Server"
        assert comp.type == "mcp_server"
        assert comp.stars == 42

    def test_empty_name_fails(self):
        """Should reject empty name."""
        with pytest.raises(ValidationError):
            RawComponentModel(name="")

    def test_negative_stars_fails(self):
        """Should reject negative stars."""
        with pytest.raises(ValidationError):
            RawComponentModel(name="Test", stars=-1)

    def test_extra_fields_allowed(self):
        """Should allow extra fields from registries."""
        comp = RawComponentModel(
            name="Test",
            custom_field="custom_value",
            another_field=123,
        )
        assert comp.name == "Test"
        # Extra fields accessible via model_extra
        assert comp.model_extra.get("custom_field") == "custom_value"

    def test_github_url_alias(self):
        """Should accept githubUrl as alias."""
        comp = RawComponentModel(
            name="Test",
            githubUrl="https://github.com/test/repo",
        )
        assert comp.github_url == "https://github.com/test/repo"


class TestComponentModel:
    """Tests for ComponentModel Pydantic model."""

    def test_minimal_component(self):
        """Should create component with required fields."""
        comp = ComponentModel(
            id="test_component",
            name="Test Component",
            type="skill",
            source_name="test_registry",
        )
        assert comp.id == "test_component"
        assert comp.quality_tier == "bronze"

    def test_full_component(self):
        """Should create component with all fields."""
        comp = ComponentModel(
            id="github_owner_repo",
            name="Test Server",
            type="mcp_server",
            source_name="github",
            description="A test server",
            author="testuser",
            canonical_url="https://example.com",
            github_url="https://github.com/owner/repo",
            star_count=100,
            tags=["test"],
            quality_tier="gold",
        )
        assert comp.type == "mcp_server"
        assert comp.quality_tier == "gold"

    def test_invalid_id_format_fails(self):
        """Should reject IDs not matching pattern."""
        with pytest.raises(ValidationError) as exc_info:
            ComponentModel(
                id="Invalid ID With Spaces",
                name="Test",
                type="skill",
                source_name="test",
            )
        assert "id" in str(exc_info.value).lower()

    def test_invalid_type_fails(self):
        """Should reject invalid types."""
        with pytest.raises(ValidationError) as exc_info:
            ComponentModel(
                id="test",
                name="Test",
                type="invalid_type",
                source_name="test",
            )
        assert "type" in str(exc_info.value).lower()

    def test_invalid_quality_tier_fails(self):
        """Should reject invalid quality tier."""
        with pytest.raises(ValidationError) as exc_info:
            ComponentModel(
                id="test",
                name="Test",
                type="skill",
                source_name="test",
                quality_tier="platinum",
            )
        assert "quality_tier" in str(exc_info.value).lower()

    def test_negative_star_count_fails(self):
        """Should reject negative star count."""
        with pytest.raises(ValidationError):
            ComponentModel(
                id="test",
                name="Test",
                type="skill",
                source_name="test",
                star_count=-1,
            )

    @pytest.mark.parametrize("valid_type", list(VALID_KINDS))
    def test_all_valid_types(self, valid_type):
        """Should accept all valid types."""
        comp = ComponentModel(
            id="test",
            name="Test",
            type=valid_type,
            source_name="test",
        )
        assert comp.type == valid_type

    @pytest.mark.parametrize("valid_tier", list(VALID_QUALITY_TIERS))
    def test_all_valid_quality_tiers(self, valid_tier):
        """Should accept all valid quality tiers."""
        comp = ComponentModel(
            id="test",
            name="Test",
            type="skill",
            source_name="test",
            quality_tier=valid_tier,
        )
        assert comp.quality_tier == valid_tier


class TestValidateFunctions:
    """Tests for validation helper functions."""

    def test_validate_raw_component_valid(self):
        """Should return model for valid data."""
        result = validate_raw_component({"name": "Test", "url": "https://example.com"})
        assert result is not None
        assert result.name == "Test"

    def test_validate_raw_component_invalid(self):
        """Should return None for invalid data."""
        result = validate_raw_component({})  # Missing required 'name'
        assert result is None

    def test_validate_raw_component_extra_fields(self):
        """Should accept extra fields."""
        result = validate_raw_component({
            "name": "Test",
            "custom": "value",
        })
        assert result is not None

    def test_validate_claim_valid(self):
        """Should return model for valid claim."""
        result = validate_claim({"total": 100, "source": "homepage"})
        assert result is not None
        assert result.total == 100

    def test_validate_claim_invalid(self):
        """Should return None for invalid claim."""
        result = validate_claim({"total": -1})  # Negative total
        assert result is None

    def test_validate_claim_missing_total(self):
        """Should return None when total is missing."""
        result = validate_claim({"source": "homepage"})
        assert result is None
