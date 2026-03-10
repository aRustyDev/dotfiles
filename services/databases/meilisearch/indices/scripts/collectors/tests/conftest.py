"""Shared pytest fixtures for collectors tests."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any

import pytest

from collectors.base import BaseCollector, ClaimData, CollectionMethod, RawComponent


# Paths
FIXTURES_DIR = Path(__file__).parent / "fixtures"


# --- Mock Collectors ---


class MockAPICollector(BaseCollector):
    """Mock API collector for testing."""

    registry_name = "mock_api"
    supported_kinds = {"skill", "mcp_server"}
    method = CollectionMethod.API

    def __init__(self, pages: dict[int, list[dict]] | None = None):
        super().__init__()
        self._pages = pages or {}

    async def fetch_page(self, page: int) -> dict | None:
        if page in self._pages:
            return {"items": self._pages[page]}
        return None

    def extract_components(self, raw: dict) -> list[RawComponent]:
        return raw.get("items", [])


class MockBrowserCollector(BaseCollector):
    """Mock browser collector for testing."""

    registry_name = "mock_browser"
    supported_kinds = {"mcp_server"}
    method = CollectionMethod.BROWSER

    def __init__(self, pages: dict[int, str] | None = None):
        super().__init__()
        self._pages = pages or {}

    async def fetch_page(self, page: int) -> str | None:
        return self._pages.get(page)

    def extract_components(self, raw: str) -> list[RawComponent]:
        # Simple markdown link extraction for testing
        import re
        components = []
        for match in re.finditer(r'\[([^\]]+)\]\(([^)]+)\)', raw):
            components.append({
                "name": match.group(1),
                "url": match.group(2),
            })
        return components


# --- Fixtures ---


@pytest.fixture
def mock_api_collector():
    """Create a mock API collector."""
    return MockAPICollector()


@pytest.fixture
def mock_browser_collector():
    """Create a mock browser collector."""
    return MockBrowserCollector()


@pytest.fixture
def sample_raw_component() -> RawComponent:
    """Sample raw component data."""
    return {
        "name": "Test Component",
        "description": "A test component for testing",
        "url": "https://example.com/test",
        "author": "testuser",
        "githubUrl": "https://github.com/testuser/test-repo",
        "stars": 42,
        "tags": ["test", "example"],
    }


@pytest.fixture
def sample_raw_component_minimal() -> RawComponent:
    """Minimal raw component data."""
    return {
        "name": "Minimal",
        "url": "https://example.com/minimal",
    }


@pytest.fixture
def sample_claim_data() -> ClaimData:
    """Sample claim data."""
    return ClaimData(
        total=100,
        by_kind={"skill": 60, "mcp_server": 40},
        source="homepage",
        notes="Test claim",
    )


@pytest.fixture
def sample_github_urls() -> dict[str, str | None]:
    """Sample GitHub URLs with expected owner extraction results."""
    return {
        # Standard HTTPS URLs
        "https://github.com/owner/repo": "owner",
        "https://github.com/Owner-Name/Repo.Name": "Owner-Name",
        "https://www.github.com/my_user/my_repo": "my_user",
        "http://github.com/user123/repo456": "user123",
        # With paths/fragments
        "https://github.com/owner/repo/tree/main": "owner",
        "https://github.com/owner/repo#readme": "owner",
        "https://github.com/owner/repo/blob/main/README.md": "owner",
        # SSH URLs (if supported)
        "git@github.com:owner/repo.git": "owner",
        # Non-GitHub URLs
        "https://gitlab.com/owner/repo": None,
        "https://example.com/not-github": None,
        "": None,
    }


@pytest.fixture
def sample_ids_to_sanitize() -> dict[str, str]:
    """Sample IDs with expected sanitization results."""
    return {
        # Basic transformations
        "My Component Name": "my-component-name",
        "foo/bar/baz": "foo_bar_baz",
        "some.dotted.name": "some-dotted-name",
        "user:project": "user_project",
        # Special characters
        "test@v1.2.3": "testv1-2-3",
        "name (with) parens": "name-with-parens",
        "a--b__c": "a_b_c",  # Collapse multiple separators
        # Edge cases
        "": "",
        "___": "",
        "---": "",
        "-leading-and-trailing-": "leading-and-trailing",
        "UPPERCASE": "uppercase",
        # Real-world examples
        "smithery_ai_servers_neon-mcp": "smithery_ai_servers_neon-mcp",
        "github_anthropics_mcp-servers": "github_anthropics_mcp-servers",
    }


@pytest.fixture
def fixtures_dir() -> Path:
    """Path to test fixtures directory."""
    return FIXTURES_DIR


@pytest.fixture
def tmp_ndjson(tmp_path: Path) -> Path:
    """Create a temporary NDJSON file for testing."""
    ndjson_path = tmp_path / "test.ndjson"
    ndjson_path.touch()
    return ndjson_path


@pytest.fixture
def sample_ndjson_content() -> list[dict]:
    """Sample NDJSON content for testing."""
    return [
        {
            "id": "test_component_1",
            "name": "Test Component 1",
            "type": "skill",
            "source_name": "mock_registry",
            "description": "First test component",
        },
        {
            "id": "test_component_2",
            "name": "Test Component 2",
            "type": "mcp_server",
            "source_name": "mock_registry",
            "description": "Second test component",
        },
        {
            "id": "test_component_3",
            "name": "Test Component 3",
            "type": "skill",
            "source_name": "other_registry",
            "description": "",  # Empty description
        },
    ]


@pytest.fixture
def populated_ndjson(tmp_path: Path, sample_ndjson_content: list[dict]) -> Path:
    """Create a populated NDJSON file for testing."""
    ndjson_path = tmp_path / "populated.ndjson"
    with open(ndjson_path, "w") as f:
        for item in sample_ndjson_content:
            f.write(json.dumps(item) + "\n")
    return ndjson_path


# --- Helpers ---


def load_fixture(name: str) -> str:
    """Load a fixture file by name."""
    fixture_path = FIXTURES_DIR / name
    if not fixture_path.exists():
        raise FileNotFoundError(f"Fixture not found: {fixture_path}")
    return fixture_path.read_text()


def load_json_fixture(name: str) -> Any:
    """Load a JSON fixture file."""
    return json.loads(load_fixture(name))
