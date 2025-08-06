# User configuration for analyst (CFS)
# Volta npm package management module
{
  lib,
  pkgs,
  config,
  userConfig,     # Passed from flake.nix
  dot,           # Structured paths configuration
  ...
}: {
  home = {
    # User-specific PATH configuration
    sessionVariables = {
      VOLTA_HOME = dot.paths.volta.home;
      # PATH is managed by .zshrc
    };

    # Ensure jq is available for the script
    packages = [ pkgs.jq ];

    # Volta setup activation
    activation.setupVolta = lib.hm.dag.entryAfter ["writeBoundary"] (
      let
        # Read tool configurations
        defaultTools = builtins.fromJSON (builtins.readFile ../../pkg-mgr/npm/default.json);
        machineToolsFile = ../../pkg-mgr/npm/cfs.json;
        machineTools =
          if builtins.pathExists machineToolsFile
          then builtins.fromJSON (builtins.readFile machineToolsFile)
          else {tools = [];};

        # Combine tools
        allTools = defaultTools.tools ++ machineTools.tools;
        enabledTools = builtins.filter (tool: tool.enabled or true) allTools;

        # Generate install commands
        installCommands =
          map (tool: let
            packageSpec =
              if tool.version == "latest"
              then tool.name
              else "${tool.name}@${tool.version}";
          in ''
            echo "Installing ${tool.name} (${tool.description or "npm package"})..."
            escapedName=$(echo "${tool.name}" | sed 's/[[\.*^$()+?{|]/\\&/g')
            volta install node
            if ! ${pkgs.volta}/bin/volta list --format plain 2>/dev/null | grep -q "^$escapedName@"; then
              $DRY_RUN_CMD ${pkgs.volta}/bin/volta install ${packageSpec} || echo "Warning: Failed to install ${tool.name}"
            else
              echo "${tool.name} is already installed"
            fi
          '')
          enabledTools;
      in ''
        echo "Setting up Volta for Node.js management..."
        if [[ ! -d "$HOME/.volta/bin/node" ]]; then
          echo "Installing Node.js via Volta..."
          $DRY_RUN_CMD ${pkgs.volta}/bin/volta install node@lts
        fi
        if [[ ! -L "$HOME/.volta/bin/volta" ]]; then
          echo "Creating volta symlink..."
          $DRY_RUN_CMD ln -sf ${pkgs.volta}/bin/volta "$HOME/.volta/bin/volta"
        fi
        echo "Checking npm tools for CFS..."
        ${lib.concatStringsSep "\n" installCommands}
        echo "Volta setup complete!"
      ''
    );
  };
}
