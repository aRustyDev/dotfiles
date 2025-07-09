# Example of multiple MCP servers with different configurations
{
  programs.mcpServers = {
    enable = true;

    servers = {
      # GitHub server for repository management
      github = {
        enable = true;
        type = "docker";
        src = "ghcr.io/github/github-mcp-server";
        args = ["stdio" "--toolsets=issues,pull_requests,repos"];
        secretEnv = {
          GITHUB_PERSONAL_ACCESS_TOKEN = "op://Development/GitHub Work/token";
        };
      };

      # Slack server for team communication
      slack = {
        enable = true;
        type = "git";
        src = {
          url = "https://github.com/modelcontextprotocol/slack-server";
          rev = "v1.0.0";
          sha256 = lib.fakeSha256;
        };
        runtime = "node";
        args = ["stdio"];
        secretEnv = {
          SLACK_BOT_TOKEN = "op://Work/Slack Bot/token";
          SLACK_APP_TOKEN = "op://Work/Slack Bot/app_token";
        };
      };

      # Database query server
      postgres = {
        enable = true;
        type = "docker";
        src = "mcphub/postgres-mcp:latest";
        args = ["stdio" "--read-only"];
        env = {
          DB_HOST = "localhost";
          DB_PORT = "5432";
          DB_NAME = "myapp";
        };
        secretEnv = {
          DB_USER = "op://Infrastructure/PostgreSQL/username";
          DB_PASSWORD = "op://Infrastructure/PostgreSQL/password";
        };
      };

      # Local file server with restricted access
      files = {
        enable = true;
        type = "binary";
        src = pkgs.fetchurl {
          url = "https://github.com/example/file-mcp/releases/download/v1.0/file-mcp-darwin-arm64";
          sha256 = lib.fakeSha256;
        };
        runtime = "binary";
        args = [
          "stdio"
          "--allowed-paths=/Users/analyst/Projects,/Users/analyst/Documents"
          "--read-only"
        ];
      };

      # Development server built from local source
      custom = {
        enable = false; # Enable when developing
        type = "source";
        src = "${dotfilesPath}/mcp/custom-server";
        runtime = "node";
        buildPhase = ''
          npm install
          npm run build
        '';
        args = ["stdio" "--debug"];
        env = {
          LOG_LEVEL = "debug";
          NODE_ENV = "development";
        };
      };
    };

    # Custom VS Code settings path for work profile
    vscodeConfigPath = "$HOME/.config/Code/User/settings.json";
  };
}
