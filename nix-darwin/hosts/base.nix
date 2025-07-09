# base.nix - Shared base configuration for all users
{ lib, pkgs, ... }:

{
  # Base packages available to all users
  home.packages = with pkgs; [
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
    
    # File managers
    yazi
    
    # Other utilities
    glow
    bruno
    obsidian
  ];

  # Common shell aliases
  home.shellAliases = {
    ll = "ls -l";
    la = "ls -Al";
    pu = "pushd";
    po = "popd";
    nxu = "nix flake update --flake ~/.config/nix-darwin";
  };

  # Common environment variables (user-specific paths will be set in user configs)
  home.sessionVariables = {
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

  # Common dotfile links (using relative paths from home directory)
  home.file = {
    ".config/starship.toml".source = ../starship/starship.toml;
    ".config/ghostty/config".source = ../ghostty/config;
    ".config/zed/settings.json".source = ../zed/settings.json;
  };

  # State version
  home.stateVersion = "24.05";
}