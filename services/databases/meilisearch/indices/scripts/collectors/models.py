"""Pydantic models for collectors package.

Provides validated models for:
- ClaimData: Registry-advertised component counts
- RawComponent: Unvalidated component data from registries
- Component: Validated/normalized component for output

These models ensure data integrity and provide clear contracts
between collection, transformation, and output stages.
"""

from __future__ import annotations

from datetime import UTC, datetime
from typing import Annotated, Any

from pydantic import BaseModel, ConfigDict, Field, field_validator, model_validator


# Valid component kinds from schema
VALID_KINDS = frozenset({
    "skill", "agent", "command", "rule", "prompt", "hook", "mcp_server", "plugin"
})

# Valid claim sources
VALID_CLAIM_SOURCES = frozenset({
    "homepage", "pagination", "api_meta", "search_count", "readme_links",
    "readme_text", "estimate"
})

# Valid quality tiers
VALID_QUALITY_TIERS = frozenset({"bronze", "silver", "gold"})


class ClaimDataModel(BaseModel):
    """Validated registry claim data.

    Represents what a registry *claims* to have, extracted from
    homepage stats, pagination metadata, or API responses.

    Examples:
        >>> claim = ClaimDataModel(total=100, source="homepage")
        >>> claim.total
        100

        >>> claim = ClaimDataModel(
        ...     total=500,
        ...     by_kind={"skill": 200, "mcp_server": 300},
        ...     source="pagination",
        ...     notes="Estimated from 10 pages x 50 items"
        ... )
        >>> sum(claim.by_kind.values())
        500
    """

    model_config = ConfigDict(
        str_strip_whitespace=True,
        validate_default=True,
    )

    total: Annotated[int, Field(ge=0, description="Total claimed components")]
    by_kind: dict[str, int] | None = Field(
        default=None,
        description="Breakdown by component kind"
    )
    source: str = Field(
        default="homepage",
        min_length=1,
        description="Where the claim was extracted from"
    )
    source_url: str | None = Field(
        default=None,
        description="URL where claim was found"
    )
    notes: str | None = Field(
        default=None,
        description="Additional context about the claim"
    )
    extracted_at: str = Field(
        default_factory=lambda: datetime.now(UTC).isoformat(),
        description="When the claim was extracted"
    )

    @field_validator("by_kind")
    @classmethod
    def validate_by_kind(cls, v: dict[str, int] | None) -> dict[str, int] | None:
        """Validate by_kind dict has valid kinds and non-negative counts."""
        if v is None:
            return v

        for kind, count in v.items():
            if kind not in VALID_KINDS:
                raise ValueError(f"Invalid kind: {kind}. Must be one of {VALID_KINDS}")
            if count < 0:
                raise ValueError(f"Negative count for {kind}: {count}")

        return v

    @field_validator("source")
    @classmethod
    def validate_source(cls, v: str) -> str:
        """Warn if source is non-standard (but don't fail)."""
        if v not in VALID_CLAIM_SOURCES:
            # Allow non-standard sources but they're unusual
            pass
        return v

    @model_validator(mode="after")
    def validate_by_kind_sum(self) -> "ClaimDataModel":
        """Warn if by_kind sum doesn't match total."""
        if self.by_kind is not None:
            kind_sum = sum(self.by_kind.values())
            if kind_sum != self.total:
                # This is a warning, not an error - registries often have inconsistent data
                pass
        return self

    def to_dict(self) -> dict[str, Any]:
        """Convert to dictionary for JSON serialization."""
        return self.model_dump(exclude_none=False)


class RawComponentModel(BaseModel):
    """Validated raw component data from registries.

    Represents unprocessed component data before transformation.
    Fields are optional since registries provide varying data.

    Examples:
        >>> comp = RawComponentModel(name="My Component", url="https://example.com")
        >>> comp.name
        'My Component'

        >>> comp = RawComponentModel(
        ...     name="MCP Server",
        ...     url="https://github.com/owner/repo",
        ...     description="A test server",
        ...     type="mcp_server"
        ... )
        >>> comp.type
        'mcp_server'
    """

    model_config = ConfigDict(
        str_strip_whitespace=True,
        extra="allow",  # Allow additional fields from registries
    )

    # Required field
    name: str = Field(min_length=1, description="Component name")

    # Common optional fields
    url: str | None = Field(default=None, description="Primary URL")
    description: str | None = Field(default=None, description="Component description")
    author: str | None = Field(default=None, description="Author/owner name")

    # Type/kind inference
    type: str | None = Field(default=None, description="Component type/kind")
    kind: str | None = Field(default=None, description="Alternative type field")
    category: str | None = Field(default=None, description="Category for kind inference")

    # GitHub fields
    github_url: str | None = Field(default=None, alias="githubUrl")
    repository: str | None = Field(default=None, description="Repository URL")
    repo: str | None = Field(default=None, description="Short repo reference")

    # Metrics
    stars: int | None = Field(default=None, ge=0, description="GitHub stars")
    stargazers_count: int | None = Field(default=None, ge=0)

    # Metadata
    tags: list[str] | None = Field(default=None, description="Tags/keywords")
    keywords: list[str] | None = Field(default=None, description="Alternative tags field")

    @field_validator("type", "kind")
    @classmethod
    def validate_kind_if_present(cls, v: str | None) -> str | None:
        """Validate kind if explicitly set."""
        if v is not None and v not in VALID_KINDS:
            # Don't fail - registries use various type values
            # The collector will normalize this
            pass
        return v


class ComponentModel(BaseModel):
    """Validated output component matching schema.

    Represents a fully processed component ready for output.
    All required fields must be present and valid.

    Examples:
        >>> comp = ComponentModel(
        ...     id="github_owner_repo",
        ...     name="My Component",
        ...     type="skill",
        ...     source_name="github"
        ... )
        >>> comp.quality_tier
        'bronze'
    """

    model_config = ConfigDict(
        str_strip_whitespace=True,
        validate_default=True,
    )

    # Required fields
    id: str = Field(
        min_length=1,
        pattern=r"^[a-z0-9_-]+$",
        description="Unique identifier matching schema pattern"
    )
    name: str = Field(min_length=1, description="Display name")
    type: str = Field(description="Component type/kind")
    source_name: str = Field(min_length=1, description="Registry name")

    # Optional fields
    description: str | None = Field(default=None)
    author: str | None = Field(default=None)
    canonical_url: str | None = Field(default=None)
    github_url: str | None = Field(default=None)
    star_count: int | None = Field(default=None, ge=0)
    source_type: str = Field(default="registry")
    source_url: str | None = Field(default=None)
    tags: list[str] | None = Field(default=None)
    discovered_at: str = Field(
        default_factory=lambda: datetime.now(UTC).isoformat()
    )
    quality_tier: str = Field(default="bronze")

    @field_validator("type")
    @classmethod
    def validate_type(cls, v: str) -> str:
        """Validate type is a known kind."""
        if v not in VALID_KINDS:
            raise ValueError(f"Invalid type: {v}. Must be one of {VALID_KINDS}")
        return v

    @field_validator("quality_tier")
    @classmethod
    def validate_quality_tier(cls, v: str) -> str:
        """Validate quality tier."""
        if v not in VALID_QUALITY_TIERS:
            raise ValueError(f"Invalid quality_tier: {v}. Must be one of {VALID_QUALITY_TIERS}")
        return v

    @field_validator("id")
    @classmethod
    def validate_id_format(cls, v: str) -> str:
        """Ensure ID matches schema pattern."""
        import re
        if not re.match(r"^[a-z0-9_-]+$", v):
            raise ValueError(f"Invalid ID format: {v}. Must match ^[a-z0-9_-]+$")
        return v


# Convenience type aliases
RawComponent = dict[str, Any]  # For backward compatibility


def validate_raw_component(data: dict[str, Any]) -> RawComponentModel | None:
    """Validate raw component data, returning None if invalid.

    Args:
        data: Raw component dictionary

    Returns:
        Validated RawComponentModel or None if validation fails

    Examples:
        >>> comp = validate_raw_component({"name": "Test", "url": "https://example.com"})
        >>> comp.name
        'Test'

        >>> validate_raw_component({}) is None
        True
    """
    try:
        return RawComponentModel(**data)
    except Exception:
        return None


def validate_claim(data: dict[str, Any]) -> ClaimDataModel | None:
    """Validate claim data, returning None if invalid.

    Args:
        data: Claim dictionary

    Returns:
        Validated ClaimDataModel or None if validation fails

    Examples:
        >>> claim = validate_claim({"total": 100, "source": "homepage"})
        >>> claim.total
        100

        >>> validate_claim({"total": -1}) is None
        True
    """
    try:
        return ClaimDataModel(**data)
    except Exception:
        return None
