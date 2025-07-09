{
  config,
  lib,
  pkgs,
  ...
}: let
  # Helper to build MCP servers from source
  buildMCPServer = {
    name,
    src,
    type ? "source", # source, git, binary, docker
    buildInputs ? [],
    buildPhase ? null,
    installPhase ? null,
    runtime ? "node", # node, go, python, etc.
    env ? {},
    ...
  }: let
    # Generate a hash of the source for caching
    sourceHash = builtins.hashString "sha256" (
      if type == "git"
      then "${src.url}-${src.rev or "HEAD"}"
      else if type == "source"
      then src.path
      else name
    );

    # Default build phases based on runtime
    defaultBuildPhase =
      {
        node = ''
          npm ci --production
          npm run build || true
        '';
        go = ''
          go build -o ${name}
        '';
        python = ''
          python -m pip install -r requirements.txt
        '';
      }.${
        runtime
      } or "";

    defaultInstallPhase =
      {
        node = ''
          mkdir -p $out/bin $out/lib
          cp -r . $out/lib/${name}
          cat > $out/bin/${name} <<EOF
          #!/usr/bin/env bash
          exec ${pkgs.nodejs}/bin/node $out/lib/${name}/index.js "\$@"
          EOF
          chmod +x $out/bin/${name}
        '';
        go = ''
          mkdir -p $out/bin
          cp ${name} $out/bin/
        '';
        python = ''
          mkdir -p $out/bin $out/lib
          cp -r . $out/lib/${name}
          cat > $out/bin/${name} <<EOF
          #!/usr/bin/env bash
          exec ${pkgs.python3}/bin/python $out/lib/${name}/main.py "\$@"
          EOF
          chmod +x $out/bin/${name}
        '';
      }.${
        runtime
      } or "";
  in
    if type == "binary"
    then
      # For pre-built binaries, just copy them
      pkgs.stdenv.mkDerivation {
        inherit name src;
        installPhase = ''
          mkdir -p $out/bin
          cp ${src} $out/bin/${name}
          chmod +x $out/bin/${name}
        '';
      }
    else if type == "docker"
    then
      # For Docker-based servers, create a wrapper script
      pkgs.writeScriptBin name ''
        #!/usr/bin/env bash
        exec ${pkgs.docker}/bin/docker run -i --rm \
          ${lib.concatStringsSep " " (lib.mapAttrsToList (k: _: "-e ${k}") env)} \
          ${src} "$@"
      ''
    else
      # Build from source or git
      pkgs.stdenv.mkDerivation {
        inherit name;

        src =
          if type == "git"
          then
            pkgs.fetchgit {
              inherit (src) url;
              rev = src.rev or "HEAD";
              sha256 = src.sha256 or lib.fakeSha256;
            }
          else src;

        buildInputs =
          buildInputs
          ++ ({
              node = with pkgs; [nodejs npm];
              go = with pkgs; [go];
              python = with pkgs; [python3 python3Packages.pip];
            }.${
              runtime
            } or [
            ]);

        buildPhase = buildPhase or defaultBuildPhase;
        installPhase = installPhase or defaultInstallPhase;

        # Cache based on source hash
        outputHashMode = "recursive";
        outputHashAlgo = "sha256";
        outputHash = sourceHash;
      };
in {
  options.programs.mcpServers = {
    enable = lib.mkEnableOption "MCP server management";

    servers = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether to enable this MCP server";
          };

          type = lib.mkOption {
            type = lib.types.enum ["binary" "docker" "source" "git"];
            description = "Type of MCP server installation";
          };

          src = lib.mkOption {
            type = lib.types.either lib.types.str lib.types.attrs;
            description = "Source of the MCP server (path, URL, or docker image)";
          };

          runtime = lib.mkOption {
            type = lib.types.enum ["node" "go" "python" "binary"];
            default = "node";
            description = "Runtime environment for the server";
          };

          buildInputs = lib.mkOption {
            type = lib.types.listOf lib.types.package;
            default = [];
            description = "Additional build dependencies";
          };

          env = lib.mkOption {
            type = lib.types.attrsOf lib.types.str;
            default = {};
            description = "Environment variables for the server";
          };

          secretEnv = lib.mkOption {
            type = lib.types.attrsOf lib.types.str;
            default = {};
            description = "Secret environment variables (will use op run)";
          };

          args = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = ["stdio"];
            description = "Default arguments for the server";
          };

          vscodeConfig = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether to generate VS Code configuration";
          };
        };
      });
      default = {};
      description = "MCP servers to manage";
    };

    vscodeConfigPath = lib.mkOption {
      type = lib.types.str;
      default = "$HOME/.vscode/settings.json";
      description = "Path to VS Code settings.json";
    };
  };

  config = lib.mkIf config.programs.mcpServers.enable {
    home = {
      # Create wrapper scripts that reference the installed servers
      packages = lib.flatten (
        lib.mapAttrsToList (
          name: cfg:
            lib.optional cfg.enable (
              # Create wrapper script that uses the installed server
              pkgs.writeScriptBin "mcp-${name}" ''
                #!/usr/bin/env bash
                # Wrapper for ${name} MCP server

                # Set up regular environment variables
                ${lib.concatStringsSep "\n" (
                  lib.mapAttrsToList (k: v: "export ${k}=${lib.escapeShellArg v}") cfg.env
                )}

                # Determine the server binary location
                SERVER_BIN="$HOME/.mcp/servers/${name}/bin/${name}"

                ${
                  if cfg.type == "docker"
                  then ''
                    # For Docker-based servers, use the exported image
                    IMAGE_TAR="$HOME/.mcp/servers/${name}/image.tar"

                    # Load the image if not already loaded
                    if [[ -f "$IMAGE_TAR" ]]; then
                      # Check if image is already loaded
                      IMAGE_NAME="${cfg.src}"
                      if ! ${pkgs.docker}/bin/docker images --format "{{.Repository}}:{{.Tag}}" | grep -q "^$IMAGE_NAME$"; then
                        echo "Loading Docker image from $IMAGE_TAR..."
                        ${pkgs.docker}/bin/docker load -i "$IMAGE_TAR"
                      fi
                    fi

                    # Run with op for secret environment variables
                    ${
                      if cfg.secretEnv != {}
                      then ''
                        exec ${pkgs._1password-cli}/bin/op run \
                          ${lib.concatStringsSep " " (
                          lib.mapAttrsToList (k: v: "--env=${k}=${v}") cfg.secretEnv
                        )} \
                          -- ${pkgs.docker}/bin/docker run -i --rm \
                          ${lib.concatStringsSep " " (
                          lib.mapAttrsToList (k: _: "-e ${k}") (cfg.env // cfg.secretEnv)
                        )} \
                          ${cfg.src} ${lib.concatStringsSep " " cfg.args} "$@"
                      ''
                      else ''
                        exec ${pkgs.docker}/bin/docker run -i --rm \
                          ${lib.concatStringsSep " " (
                          lib.mapAttrsToList (k: _: "-e ${k}") cfg.env
                        )} \
                          ${cfg.src} ${lib.concatStringsSep " " cfg.args} "$@"
                      ''
                    }
                  ''
                  else ''
                    # For binary/source servers, run the installed binary
                    if [[ ! -x "$SERVER_BIN" ]]; then
                      echo "Error: MCP server binary not found at $SERVER_BIN"
                      echo "Please run 'darwin-rebuild switch' to install the server."
                      exit 1
                    fi

                    # Run with op for secret environment variables
                    ${
                      if cfg.secretEnv != {}
                      then ''
                        exec ${pkgs._1password-cli}/bin/op run \
                          ${lib.concatStringsSep " " (
                          lib.mapAttrsToList (k: v: "--env=${k}=${v}") cfg.secretEnv
                        )} \
                          -- "$SERVER_BIN" ${lib.concatStringsSep " " cfg.args} "$@"
                      ''
                      else ''
                        exec "$SERVER_BIN" ${lib.concatStringsSep " " cfg.args} "$@"
                      ''
                    }
                  ''
                }
              ''
            )
        )
        config.programs.mcpServers.servers
      );

      # Generate VS Code configuration
      activation.mcpVSCodeConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
        if [ -f ${config.programs.mcpServers.vscodeConfigPath} ]; then
          echo "Updating VS Code MCP server configuration..."

          # Create a Python script to merge the configuration
          cat > /tmp/update-vscode-mcp.py << 'EOF'
        import json
        import os
        import sys

        settings_path = sys.argv[1]

        # Read existing settings
        with open(settings_path, 'r') as f:
            settings = json.load(f)

        # Ensure mcpServers exists
        if 'mcpServers' not in settings:
            settings['mcpServers'] = {}

        # Update MCP server configurations
        mcp_configs = {
        ${lib.concatStringsSep "\n      " (
          lib.mapAttrsToList (
            name: cfg:
              lib.optionalString (cfg.enable && cfg.vscodeConfig) ''
                "${name}": {
                    "command": "mcp-${name}",
                    "args": [],
                    "env": {}
                },
              ''
          )
          config.programs.mcpServers.servers
        )}
        }

        # Merge configurations
        settings['mcpServers'].update(mcp_configs)

        # Write back
        with open(settings_path, 'w') as f:
            json.dump(settings, f, indent=2)
        EOF

          ${pkgs.python3}/bin/python /tmp/update-vscode-mcp.py "${config.programs.mcpServers.vscodeConfigPath}"
          rm -f /tmp/update-vscode-mcp.py
        fi
      '';

      # Install MCP servers to ~/.mcp/
      file = lib.mkMerge ([
          {
            # Create base directory structure
            ".mcp/.keep".text = "";
            ".mcp/servers/.keep".text = "";
            ".config/mcp/.keep".text = "";
            ".cache/mcp/.keep".text = "";
          }
        ]
        ++ lib.flatten (
          lib.mapAttrsToList (
            name: cfg:
              lib.optional cfg.enable (
                if cfg.type == "docker"
                then
                  # For Docker servers, create a script to export the image
                  {
                    ".mcp/servers/${name}/export-image.sh" = {
                      executable = true;
                      text = ''
                        #!/usr/bin/env bash
                        # Export Docker image for ${name} MCP server

                        IMAGE="${cfg.src}"
                        OUTPUT="$HOME/.mcp/servers/${name}/image.tar"

                        echo "Pulling Docker image: $IMAGE"
                        ${pkgs.docker}/bin/docker pull "$IMAGE"

                        echo "Exporting image to: $OUTPUT"
                        ${pkgs.docker}/bin/docker save -o "$OUTPUT" "$IMAGE"

                        echo "Image exported successfully!"
                        echo "Size: $(du -h "$OUTPUT" | cut -f1)"
                      '';
                    };

                    ".mcp/servers/${name}/info.json" = {
                      text = builtins.toJSON {
                        type = "docker";
                        image = cfg.src;
                        inherit (cfg) args env;
                        runtime = "docker";
                      };
                    };
                  }
                else let
                  server = buildMCPServer {
                    inherit name;
                    inherit (cfg) type src runtime buildInputs;
                  };
                in {
                  # Install the binary
                  ".mcp/servers/${name}/bin/${name}".source = "${server}/bin/${name}";

                  # Create metadata file
                  ".mcp/servers/${name}/info.json" = {
                    text = builtins.toJSON {
                      inherit (cfg) type runtime args env;
                      buildDate = builtins.currentTime;
                      nixDerivation = server.drvPath or null;
                    };
                  };

                  # If it's a complex installation, copy the whole directory
                  ".mcp/servers/${name}/lib" = lib.mkIf (cfg.runtime != "binary") {
                    source = "${server}/lib/${name}";
                    recursive = true;
                  };
                }
              )
          )
          config.programs.mcpServers.servers
        ));
    };
  };
}
