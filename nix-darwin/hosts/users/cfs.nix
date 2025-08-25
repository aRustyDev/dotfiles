# User configuration for analyst (CFS)
{
  lib,
  pkgs,
  config,
  dotfilesPath,
  ...
}: {
  imports = [../base.nix];

  home = {
    username = "analyst";
    homeDirectory = "/Users/analyst";

    # User-specific PATH configuration
    sessionVariables = {
      # Set user-specific paths
      ZDOTDIR = "${config.home.homeDirectory}/.config/zsh";
      STARSHIP_CONFIG = "${config.home.homeDirectory}/.config/starship/config.toml";
      CARGO_HOME = "${config.home.homeDirectory}/.cargo";
      RUSTUP_HOME = "${config.home.homeDirectory}/.rustup";
      VOLTA_HOME = "${config.home.homeDirectory}/.volta";

      # Note: PATH is managed by .zshrc to ensure proper ordering
      # Any special PATH requirements should be added to .zshrc
    };

    # Additional CFS-specific packages
    packages = with pkgs; [
      # Add any CFS-specific tools here
    ];

    # CFS-specific dotfiles
    file = {
      ".config/zsh/.zshrc".source = "${dotfilesPath}/zsh/.zshrc";
      ".config/1Password/ssh/agent.toml".source = "${dotfilesPath}/1Password/agent.toml";
    };

    # Rust setup activation
    activation.setupRust = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [[ ! -d "$HOME/.rustup/toolchains" ]] || [[ -z "$(ls -A $HOME/.rustup/toolchains 2>/dev/null)" ]]; then
        echo "Setting up Rust toolchain for first time..."
        $DRY_RUN_CMD ${pkgs.rustup}/bin/rustup install stable
        $DRY_RUN_CMD ${pkgs.rustup}/bin/rustup default stable
        $DRY_RUN_CMD ${pkgs.rustup}/bin/rustup component add rustfmt clippy rust-analyzer
      fi
    '';

    # Volta setup activation
    activation.setupVolta = lib.hm.dag.entryAfter ["writeBoundary"] (
      let
        # Read tool configurations
        defaultTools = builtins.fromJSON (builtins.readFile ../npm-tools/default.json);
        machineToolsFile = ../npm-tools/cfs.json;
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
