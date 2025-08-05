# base.nix - Shared base configuration for all users
{
  pkgs,
  dotfilesPath,
  ...
}: {
  imports = [
    ../modules/git-commands.nix,
    ../pkg-mgr/homebrew/casks.nix,
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

      # Nu Shell
      nushell
      nushellPlugins.net
      nushellPlugins.dbus
      nushellPlugins.units
      nushellPlugins.semver

      # CLI QoL tools
      atuin
      zsh-autosuggestions
      zoxide
      dust
      tealdeer
      hyperfine
      
      # Text processing
      ripgrep
      jq
      yq
      
      # Development tools
      just
      pre-commit
      lazygit
      volta      # Node.js version manager
      rustup     # Rust toolchain installer
      tenv       # OpenTofu, Terraform, Terragrunt and Atmos version manager
      go         # Golang Programming language
      kubectl
      kubernetes-helm
      k9s
      codeql
      gitsign
      rekor-cli
      cosign
      
      
      # File managers
      yazi
      yaziPlugins.glow
      yaziPlugins.git
      yaziPlugins.sudo
      yaziPlugins.diff
      yaziPlugins.mount
      yaziPlugins.chmod
      yaziPlugins.miller # Awk+Sed+cut+join+sort
      yaziPlugins.restore
      yaziPlugins.lazygit
      yaziPlugins.duckdb
      yaziPlugins.mactag
      yaziPlugins.starship
      yaziPlugins.relative-motions
      yaziPlugins.time-travel
      
      
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
      nxu = "nix flake update --flake $HOME/.config/nix/";
      "git-setup" = "git-setup-advanced";
      upd = "homebrew update && homebrew upgrade && volta update";
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
      ZDOTDIR = "${config.home.homeDirectory}/.config/zsh";
      STARSHIP_CONFIG = "${config.home.homeDirectory}/.config/starship/config.toml";
      STARSHIP_CACHE = "${config.home.homeDirectory}/.local/cache/starship";
      STARSHIP_SHELL = "zsh
      # NIX_STORE_DIR = "";
      # NIX_DATA_DIR = "";
      # NIX_LOG_DIR = "";
      # NIX_STATE_DIR = "";
      # NIX_PATH = "";
      # NIX_USER_CONF_FILES = "";
      # NIX_CONFIG = "";
      # NIX_CONF_DIR = "";
      # NIX_USER_CONF_FILES = "";
    };

    # Common dotfile links
    file = {
      ".config/starship/config.toml".source = "${dotfilesPath}/starship/starship.toml";
      ".config/ghostty/config".source = "${dotfilesPath}/ghostty/config";
      ".config/zed/settings.json".source = "${dotfilesPath}/zed/settings.json";
      ".local/git/bin/git-setup".source = "${dotfilesPath}/zsh/.zshenv";                    # 
      ".config/1Password/ssh/agent.toml".source = "${dotfilesPath}/1Password/agent.toml";   # 

      "/etc/zshenv".source = "${dotfilesPath}/zsh/.zshenv";                                 # Set this so the 'sessionVariables' for Zsh Take effect
      ".config/zsh/.zshrc".source = "${dotfilesPath}/zsh/.zshrc";
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