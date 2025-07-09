# MCP Server Management for Nix-Darwin

This module provides a unified way to manage MCP (Model Context Protocol) servers in your dotfiles configuration. It supports multiple installation methods and includes automatic secret management via 1Password.

## Features

- **Multiple Installation Methods**: Binary, Docker, source code, and Git repositories
- **Automatic Building**: Source-based servers are built automatically with caching
- **Secret Management**: Seamless integration with 1Password via `op run`
- **VS Code Integration**: Automatic configuration generation for VS Code
- **Smart Caching**: Only rebuilds when source code changes

## Installation

1. Add the MCP module to your nix-darwin configuration:

```nix
# In your configuration.nix or personal.nix
imports = [
  ../modules/mcp-servers.nix
];
```

2. Enable and configure MCP servers:

```nix
programs.mcpServers = {
  enable = true;
  servers = {
    # Your server configurations here
  };
};
```

## Server Types

### Docker-based Servers

The easiest way to run MCP servers, no building required:

```nix
github = {
  enable = true;
  type = "docker";
  src = "ghcr.io/github/github-mcp-server";
  args = [ "stdio" ];
  secretEnv = {
    GITHUB_PERSONAL_ACCESS_TOKEN = "op://Personal/GitHub PAT/credential";
  };
};
```

### Source-based Servers

Build from local source code:

```nix
custom = {
  enable = true;
  type = "source";
  src = ./my-mcp-server;
  runtime = "node"; # or "go", "python"
  args = [ "stdio" ];
};
```

### Git Repository Servers

Clone and build from Git:

```nix
slack = {
  enable = true;
  type = "git";
  src = {
    url = "https://github.com/example/slack-mcp";
    rev = "v1.0.0"; # Pin to specific version
    sha256 = "..."; # Use lib.fakeSha256 initially
  };
  runtime = "node";
};
```

### Binary Servers

Pre-built binaries:

```nix
fileserver = {
  enable = true;
  type = "binary";
  src = ./bin/fileserver; # or fetchurl
  runtime = "binary";
};
```

## Secret Management

The module integrates with 1Password for secret management:

1. Regular environment variables use the `env` attribute
2. Secrets use the `secretEnv` attribute with 1Password references
3. The wrapper script automatically uses `op run` when secrets are present

Example:

```nix
servers.myserver = {
  env = {
    API_URL = "https://api.example.com"; # Public config
  };
  secretEnv = {
    API_KEY = "op://Vault/Item/field"; # Secret from 1Password
  };
};
```

## Runtime Support

The module supports multiple runtime environments:

- **Node.js**: Default for most MCP servers
- **Go**: For Go-based servers like GitHub's
- **Python**: For Python-based servers
- **Binary**: For pre-compiled executables

Each runtime has sensible defaults for building and installation.

## VS Code Integration

The module automatically generates VS Code configuration for your MCP servers. After running `darwin-rebuild switch`, your servers will be available in VS Code's MCP settings.

To use a server in VS Code:
1. Open VS Code settings
2. Search for "mcp"
3. Your servers will be listed under `mcpServers`
4. Enable the ones you want to use

## Caching and Rebuilding

The module implements smart caching:
- Source-based servers are only rebuilt when the source changes
- Git-based servers are cached by commit hash
- Docker images are pulled as needed
- Binary servers are cached by content hash

To force a rebuild, change the source or update the Git revision.

## Installation Location

All MCP servers are installed to `~/.mcp/servers/` with the following structure:

```
~/.mcp/
└── servers/
    ├── github/
    │   ├── bin/github         # Binary executable
    │   ├── lib/               # Supporting libraries (if needed)
    │   └── info.json          # Server metadata
    ├── slack/
    │   ├── export-image.sh    # Docker export script
    │   ├── image.tar          # Exported Docker image (optional)
    │   └── info.json          # Server metadata
    └── ...
```

## Command Line Usage

Each server gets a wrapper script named `mcp-<name>`:

```bash
# Run a server manually
mcp-github stdio

# Test server connectivity
echo '{"method": "ping"}' | mcp-github stdio

# Use with other tools
cat request.json | mcp-slack stdio
```

## Server Management

Use the management script to work with installed servers:

```bash
# List all installed servers
./mcp/manage-servers.sh list

# Show details for a specific server
./mcp/manage-servers.sh show github

# Export Docker image for offline use
./mcp/manage-servers.sh export-docker github

# Export all Docker images
./mcp/manage-servers.sh export-all

# Clean up exported Docker images
./mcp/manage-servers.sh cleanup

# Test a server
./mcp/manage-servers.sh test github
```

## Examples

See the `examples/` directory for complete configurations:
- `github-server.nix`: GitHub MCP server with multiple installation methods
- `filesystem-server.nix`: Node.js-based filesystem server
- `multi-server-setup.nix`: Complete multi-server setup

## Troubleshooting

### Build Failures

If a build fails with `lib.fakeSha256`:
1. Let it fail once
2. Copy the correct sha256 from the error message
3. Replace `lib.fakeSha256` with the actual hash

### Secret Access

Ensure you're logged into 1Password:
```bash
op signin
```

### VS Code Not Detecting Servers

1. Check that VS Code MCP support is enabled
2. Ensure the settings file exists at the configured path
3. Restart VS Code after configuration changes

## Directory Structure

```
mcp/
├── README.md           # This file
├── examples/          # Example configurations
│   ├── github-server.nix
│   ├── filesystem-server.nix
│   └── multi-server-setup.nix
├── servers/           # Local server source code
│   └── custom/       # Your custom servers
└── bin/              # Pre-built binaries
```

## Adding New Servers

1. Create a new configuration in your nix file
2. Set the appropriate type and source
3. Configure environment variables and secrets
4. Run `darwin-rebuild switch`
5. The server will be available as `mcp-<name>`

## Security Considerations

- Secrets are never stored in the Nix store
- 1Password CLI handles secret injection at runtime
- Docker containers run with minimal privileges
- Use `--read-only` flag for read-only access

## Contributing

To add support for new runtime environments or improve the module:
1. Edit `modules/mcp-servers.nix`
2. Add new runtime support in `defaultBuildPhase` and `defaultInstallPhase`
3. Test with example configurations
4. Submit a pull request
