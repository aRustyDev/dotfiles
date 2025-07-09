# base.nix - Shared base configuration for all users
{
  pkgs,
  dotfilesPath,
  ...
}: {
  imports = [
    ../modules/git-commands.nix
    ../modules/mcp-servers.nix
  ];

  home = {
    # Base packages available to all users
    packages = with pkgs; [
      # Editors
      helix
      neovim
      zed-editor

      # Terminal multiplexers and emulators
      zellij
      starship
      tmux
      ghostty-bin

      # Security tools
      _1password-cli
      _1password-gui-beta

      # Text processing
      ripgrep
      jq
      yq

      # Development tools
      pre-commit
      lazygit
      volta # Node.js version manager
      rustup # Rust toolchain installer

      # File managers
      yazi

      # Other utilities
      glow
      bruno
      obsidian
    ];

    # Common shell aliases
    shellAliases = {
      ll = "ls -l";
      la = "ls -Al";
      pu = "pushd";
      po = "popd";
      nxu = "nix flake update --flake ~/.config/nix-darwin";
      "git-setup" = "git-setup-advanced";
    };

    # Common environment variables (user-specific paths will be set in user configs)
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      PAGER = "less";
      LESS = "-R";
      GPG_TTY = "$(tty)";
      LANG = "en_US.UTF-8";
      LC_ALL = "en_US.UTF-8";
      HISTSIZE = "32768";
      HISTFILESIZE = "32768";
      HISTCONTROL = "ignoreboth";
      RUST_BACKTRACE = "1";
    };

    # Common dotfile links
    file = {
      ".config/starship.toml".source = "${dotfilesPath}/starship/starship.toml";
      ".config/ghostty/config".source = "${dotfilesPath}/ghostty/config";
      ".config/zed/settings.json".source = "${dotfilesPath}/zed/settings.json";
    };

    # State version
    stateVersion = "24.05";
  };

  # Enable custom git commands for all users
  programs.customGitCommands = {
    enable = true;
    commands = [
      "git-setup-wrapper"
      "git-setup-v2"
      "git-setup-advanced"
    ];
  };

  # Common program configurations
  programs = {
    home-manager.enable = true;

    git = {
      enable = true;
      extraConfig = {
        push.autoSetupRemote = true;
        pull.rebase = true;
      };
    };

    zsh = {
      enable = true;
      enableCompletion = true;
    };
  };
}
