# Example of integrating MCP servers into your personal.nix or machine configuration
{
  config,
  lib,
  dotfilesPath,
  ...
}: {
  # Import the MCP module
  imports = [
    ./modules/mcp-servers.nix
  ];

  # Configure your MCP servers
  programs.mcpServers = {
    enable = true;

    servers = {
      # GitHub server for development work
      github = {
        enable = true;
        type = "docker";
        src = "ghcr.io/github/github-mcp-server";
        args = ["stdio"];
        env = {
          # Use specific GitHub Enterprise instance if needed
          # GITHUB_API_URL = "https://github.enterprise.com/api/v3";
        };
        secretEnv = {
          # Reference your 1Password item
          # Format: op://vault/item/field
          GITHUB_PERSONAL_ACCESS_TOKEN = "op://Personal/GitHub PAT/token";
        };
      };

      # Local development server
      dev-tools = {
        enable = false; # Enable when needed
        type = "source";
        src = "${dotfilesPath}/mcp/servers/dev-tools";
        runtime = "node";
        args = ["stdio" "--verbose"];
        env = {
          NODE_ENV = "development";
          LOG_LEVEL = "debug";
        };
      };

      # Filesystem access server with restrictions
      files = {
        enable = true;
        type = "git";
        src = {
          url = "https://github.com/modelcontextprotocol/servers";
          rev = "main";
          sha256 = lib.fakeSha256; # Replace after first build
        };
        runtime = "node";
        buildPhase = ''
          cd src/filesystem
          npm ci
          npm run build
        '';
        args = [
          "stdio"
          "--allowed-directories=${config.home.homeDirectory}/Projects,${config.home.homeDirectory}/Documents"
        ];
      };
    };

    # Use custom VS Code path if needed
    # vscodeConfigPath = "${config.home.homeDirectory}/.config/Code/User/settings.json";
  };

  # Optional: Add shell aliases for common operations
  home.shellAliases = {
    # MCP server management
    mcp-manage = "${dotfilesPath}/mcp/manage-servers.sh";
    mcp-test = "${dotfilesPath}/mcp/test-server.sh";

    # Quick commands
    mcp-list = "${dotfilesPath}/mcp/manage-servers.sh list";
    mcp-export = "${dotfilesPath}/mcp/manage-servers.sh export-all";
  };

  # Optional: Create a launch script for development
  home.file.".local/bin/mcp-dev" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Launch MCP server in development mode with logging

      SERVER="''${1:-github}"
      shift

      echo "Starting MCP server: $SERVER"
      echo "Logs will be written to ~/.cache/mcp/$SERVER.log"

      mkdir -p ~/.cache/mcp
      exec mcp-$SERVER "$@" 2>&1 | tee ~/.cache/mcp/$SERVER.log
    '';
  };
}
