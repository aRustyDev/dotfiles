# Example configuration for GitHub MCP Server
{
  programs.mcpServers = {
    enable = true;

    servers = {
      # Docker-based GitHub MCP server (recommended)
      github-docker = {
        enable = true;
        type = "docker";
        src = "ghcr.io/github/github-mcp-server";
        args = ["stdio"];
        env = {
          # Non-secret environment variables
          GITHUB_API_URL = "https://api.github.com";
        };
        secretEnv = {
          # This will be fetched via `op run`
          GITHUB_PERSONAL_ACCESS_TOKEN = "op://Personal/GitHub PAT/credential";
        };
      };

      # Building from source (Go-based)
      github-source = {
        enable = false; # Disabled by default, enable if you prefer source build
        type = "git";
        src = {
          url = "https://github.com/github/mcp-servers";
          rev = "main"; # Pin to specific commit for reproducibility
          sha256 = lib.fakeSha256; # Replace with actual sha256 after first build
        };
        runtime = "go";
        buildPhase = ''
          cd cmd/github-mcp-server
          go build -o github-mcp-server
        '';
        installPhase = ''
          mkdir -p $out/bin
          cp cmd/github-mcp-server/github-mcp-server $out/bin/
        '';
        args = ["stdio" "--toolsets=context"];
        secretEnv = {
          GITHUB_PERSONAL_ACCESS_TOKEN = "op://Personal/GitHub PAT/credential";
        };
      };

      # Binary distribution example
      github-binary = {
        enable = false;
        type = "binary";
        src = ./bin/github-mcp-server; # Pre-downloaded binary
        runtime = "binary";
        args = ["stdio" "--read-only"];
        secretEnv = {
          GITHUB_PERSONAL_ACCESS_TOKEN = "op://Personal/GitHub PAT/credential";
        };
      };
    };
  };
}
