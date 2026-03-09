"""Registry-specific collector implementations."""

from collectors.registries.smithery import SmitheryCollector
from collectors.registries.mcpservers import MCPServersCollector
from collectors.registries.skillsmp import SkillsmpCollector
from collectors.registries.github import GitHubCollector
from collectors.registries.awesome import (
    AwesomePunkpeyeCollector,
    AwesomeWong2Collector,
    AwesomeAnthropicCollector,
    AwesomeMCPOfficialCollector,
    AWESOME_COLLECTORS,
    create_awesome_collector,
)
from collectors.registries.buildwithclaude import BuildWithClaudeCollector
from collectors.registries.claudemarketplaces import ClaudeMarketplacesCollector
from collectors.registries.mcp_so import MCPSoCollector

__all__ = [
    "SmitheryCollector",
    "MCPServersCollector",
    "SkillsmpCollector",
    "GitHubCollector",
    "AwesomePunkpeyeCollector",
    "AwesomeWong2Collector",
    "AwesomeAnthropicCollector",
    "AwesomeMCPOfficialCollector",
    "AWESOME_COLLECTORS",
    "create_awesome_collector",
    "BuildWithClaudeCollector",
    "ClaudeMarketplacesCollector",
    "MCPSoCollector",
]

# Registry name to collector class mapping
REGISTRY_COLLECTORS = {
    "smithery.ai": SmitheryCollector,
    "mcpservers.org": MCPServersCollector,
    "skillsmp.com": SkillsmpCollector,
    "github": GitHubCollector,
    "buildwithclaude.com": BuildWithClaudeCollector,
    "claudemarketplaces.com": ClaudeMarketplacesCollector,
    "mcp.so": MCPSoCollector,
    # Awesome lists handled via AwesomeListCollector with repo param
}

# Kinds supported by each registry
REGISTRY_KINDS = {
    "smithery.ai": {"mcp_server", "skill"},
    "mcpservers.org": {"mcp_server"},
    "skillsmp.com": {"skill"},
    "github": {"skill", "agent", "hook", "mcp_server", "plugin"},
    "buildwithclaude.com": {"skill", "agent", "plugin", "mcp_server"},
    "claudemarketplaces.com": {"plugin"},
    "mcp.so": {"mcp_server"},
    "awesome:punkpeye/awesome-mcp-servers": {"mcp_server"},
    "awesome:wong2/awesome-mcp-servers": {"mcp_server"},
    "awesome:anthropics/anthropic-cookbook": {"skill"},
    "awesome:modelcontextprotocol/servers": {"mcp_server"},
}
