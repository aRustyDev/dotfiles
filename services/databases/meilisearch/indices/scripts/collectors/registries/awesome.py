"""
Awesome list collectors for curated component lists.

Parses README files from popular awesome-* repositories.
"""

from __future__ import annotations

from collectors.methods.readme import ReadmeCollector


class AwesomePunkpeyeCollector(ReadmeCollector):
    """Collector for punkpeye/awesome-mcp-servers."""

    registry_name = "awesome:punkpeye/awesome-mcp-servers"
    supported_kinds = {"mcp_server"}

    repo = "punkpeye/awesome-mcp-servers"
    default_kind = "mcp_server"


class AwesomeWong2Collector(ReadmeCollector):
    """Collector for wong2/awesome-mcp-servers."""

    registry_name = "awesome:wong2/awesome-mcp-servers"
    supported_kinds = {"mcp_server"}

    repo = "wong2/awesome-mcp-servers"
    default_kind = "mcp_server"


class AwesomeAnthropicCollector(ReadmeCollector):
    """Collector for anthropics/anthropic-cookbook."""

    registry_name = "awesome:anthropics/anthropic-cookbook"
    supported_kinds = {"skill"}

    repo = "anthropics/anthropic-cookbook"
    default_kind = "skill"


class AwesomeMCPOfficialCollector(ReadmeCollector):
    """Collector for modelcontextprotocol/servers (official)."""

    registry_name = "awesome:modelcontextprotocol/servers"
    supported_kinds = {"mcp_server"}

    repo = "modelcontextprotocol/servers"
    default_kind = "mcp_server"


# Convenience alias for creating collectors dynamically
def create_awesome_collector(repo: str, default_kind: str = "mcp_server") -> ReadmeCollector:
    """Create an awesome list collector for any repository.

    Args:
        repo: GitHub repository (owner/repo)
        default_kind: Default component type for items

    Returns:
        Configured ReadmeCollector instance
    """

    class DynamicAwesomeCollector(ReadmeCollector):
        pass

    DynamicAwesomeCollector.registry_name = f"awesome:{repo}"
    DynamicAwesomeCollector.supported_kinds = {default_kind}
    DynamicAwesomeCollector.repo = repo
    DynamicAwesomeCollector.default_kind = default_kind

    return DynamicAwesomeCollector()


# List of all awesome collectors
AWESOME_COLLECTORS = [
    AwesomePunkpeyeCollector,
    AwesomeWong2Collector,
    AwesomeAnthropicCollector,
    AwesomeMCPOfficialCollector,
]

# Mapping for easy lookup
AWESOME_REPOS = {
    "punkpeye/awesome-mcp-servers": AwesomePunkpeyeCollector,
    "wong2/awesome-mcp-servers": AwesomeWong2Collector,
    "anthropics/anthropic-cookbook": AwesomeAnthropicCollector,
    "modelcontextprotocol/servers": AwesomeMCPOfficialCollector,
}
