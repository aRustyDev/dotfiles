# Example configuration for Filesystem MCP Server (Node.js based)
{
  programs.mcpServers = {
    enable = true;

    servers = {
      # Node.js-based filesystem server from npm
      filesystem = {
        enable = true;
        type = "source";
        src = pkgs.fetchFromGitHub {
          owner = "modelcontextprotocol";
          repo = "servers";
          rev = "main";
          sha256 = lib.fakeSha256; # Replace with actual sha256
        };
        runtime = "node";
        buildPhase = ''
          cd src/filesystem
          npm ci --production
          npm run build
        '';
        installPhase = ''
          mkdir -p $out/lib/filesystem $out/bin
          cp -r dist package.json node_modules $out/lib/filesystem/
          cat > $out/bin/filesystem <<EOF
          #!/usr/bin/env bash
          exec ${pkgs.nodejs}/bin/node $out/lib/filesystem/dist/index.js "\$@"
          EOF
          chmod +x $out/bin/filesystem
        '';
        args = ["stdio"];
        env = {
          # Configure allowed directories
          ALLOWED_DIRECTORIES = "/Users/analyst/Documents,/Users/analyst/Projects";
        };
      };

      # Python-based custom server example
      python-analyzer = {
        enable = false;
        type = "source";
        src = ./src/python-analyzer;
        runtime = "python";
        buildInputs = with pkgs.python3Packages; [
          requests
          pydantic
          typing-extensions
        ];
        buildPhase = ''
          # Install dependencies
          pip install -r requirements.txt --target=.
        '';
        args = ["stdio"];
        env = {
          PYTHON_PATH = ".";
        };
      };
    };
  };
}
