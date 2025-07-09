# MCP Server Configuration Context

## Overview
The dotfiles repository includes a comprehensive MCP (Model Context Protocol) server management system implemented as a Nix-Darwin module. This system allows declarative configuration of MCP servers with support for multiple installation methods.

## Key Features
- **Multiple Installation Types**: Binary, Docker, source code, and Git repositories
- **Automatic Building**: Source-based servers are built with smart caching
- **Secret Management**: Integrated with 1Password via `op run`
- **VS Code Integration**: Automatic configuration generation
- **Local Installation**: All servers installed to `~/.mcp/servers/`
- **Docker Export**: Container images can be exported as tar files

## Module Location
- Main module: `nix-darwin/modules/mcp-servers.nix`
- Examples: `mcp/examples/`
- Documentation: `mcp/README.md`

## Configuration Pattern
```nix
programs.mcpServers = {
  enable = true;
  servers = {
    server-name = {
      enable = true;
      type = "docker|source|git|binary";
      src = "source-location";
      runtime = "node|go|python|binary";
      args = [ "stdio" ];
      env = { /* public env vars */ };
      secretEnv = { /* 1Password references */ };
    };
  };
};
```

## Secret Management
- Uses 1Password CLI (`op`) for runtime secret injection
- Secrets are never stored in the Nix store
- Format: `"op://vault/item/field"`

## Installation Structure
```
~/.mcp/servers/
├── <server-name>/
│   ├── bin/<server-name>    # Binary executable
│   ├── lib/                 # Libraries (for source builds)
│   ├── info.json           # Server metadata
│   ├── export-image.sh     # Docker export script (Docker only)
│   └── image.tar           # Exported Docker image (optional)
```

## Usage
- Each server creates a command: `mcp-<server-name>`
- Management utility: `mcp/manage-servers.sh`
- Test utility: `mcp/test-server.sh`
- Servers are automatically configured in VS Code

## Development Workflow
1. Add server configuration to your nix file
2. Run `darwin-rebuild switch`
3. Test with `mcp-test test <server-name>`
4. Use in VS Code or command line

## Caching Strategy
- Source builds are cached by content hash
- Git builds are cached by commit SHA
- Only rebuilds when source changes
- Docker images pulled on demand
