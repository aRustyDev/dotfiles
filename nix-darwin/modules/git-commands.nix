{
  config,
  lib,
  pkgs,
  dotfilesPath,
  ...
}: {
  options.programs.customGitCommands = {
    enable = lib.mkEnableOption "custom git commands";

    commands = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "git-setup-wrapper"
        "git-setup-v2"
        "git-setup-advanced"
      ];
      description = "List of git commands to install";
    };
  };

  config = lib.mkIf config.programs.customGitCommands.enable {
    home = {
      # Install git commands to ~/.local/bin
      file =
        # Generate file entries for each command
        (builtins.listToAttrs (map (cmd: {
            name = ".local/bin/${cmd}";
            value = {
              source = "${dotfilesPath}/git/lib/${cmd}";
              executable = true;
            };
          })
          config.programs.customGitCommands.commands))
        //
        # Additional files
        {
          ".local/bin/git-setup-manager" = {
            text = ''
              #!/usr/bin/env bash
              exec ${pkgs.python3}/bin/python3 ${dotfilesPath}/git/lib/git-setup-manager.py "$@"
            '';
            executable = true;
          };

          ".local/bin/git-setup-sqlite.sh" = {
            source = "${dotfilesPath}/git/lib/git-setup-sqlite.sh";
            executable = true;
          };

          ".config/git-setup/.keep" = {
            text = "";
          };

          ".cache/git-setup/.keep" = {
            text = "";
          };

          ".local/bin/git-setup" = {
            text = ''
              #!/usr/bin/env bash
              exec "$HOME/.local/bin/git-setup-wrapper" "$@"
            '';
            executable = true;
          };
        };

      # Add ~/.local/bin to PATH
      sessionPath = ["$HOME/.local/bin"];

      # Migration script for old installations
      activation.migrateGitCommands = lib.hm.dag.entryAfter ["writeBoundary"] ''
        # Check for old symlinks
        if [ -L "/usr/local/bin/git-setup" ]; then
          echo "Found old git-setup symlink at /usr/local/bin/git-setup"
          echo "You may want to remove it with: sudo rm /usr/local/bin/git-setup"
        fi

        # Migrate old config if exists
        if [ -f "$HOME/.config/git/setup_config.sh" ] && [ ! -f "$HOME/.config/git-setup/profiles.json" ]; then
          echo "Note: Old git setup config found at ~/.config/git/setup_config.sh"
          echo "Run 'git setup import-1password' to migrate to the new system"
        fi
      '';
    };
  };
}