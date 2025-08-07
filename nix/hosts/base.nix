# base.nix - Shared base configuration for all users
{
  config,
  pkgs,
  dotfilesPath,
  ...
}: {
  imports = [
    ("${config.dot.nix.mods}" + /modules/git-commands.nix)
    ("${config.dot.nix.mods}" + /pkg-mgr/node/volta.nix)
    # ("${config.dot.nix.mods}" + /pkg-mgr/homebrew/casks.nix)
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
      antidote
      zsh-completions
      # zsh-autosuggestions # benchmark: time zsh -i -c exit
      # zsh-autocomplete    # benchmark: time zsh -i -c exit

      # Nu Shell
      nushell
      # nushellPlugins.net
      # nushellPlugins.dbus
      # nushellPlugins.units
      # nushellPlugins.semver

      # CLI QoL tools
      atuin
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
      # yaziPlugins.glow
      # yaziPlugins.git
      # yaziPlugins.sudo
      # yaziPlugins.diff
      # yaziPlugins.mount
      # yaziPlugins.chmod
      # yaziPlugins.miller # Awk+Sed+cut+join+sort
      # yaziPlugins.restore
      # yaziPlugins.lazygit
      # yaziPlugins.duckdb
      # yaziPlugins.mactag
      # yaziPlugins.starship
      # yaziPlugins.relative-motions
      # yaziPlugins.time-travel


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
      # ZDOTDIR = "${config.dot.cfg.dir}/zsh";
      STARSHIP_CONFIG = "${config.dot.cfg.dir}/starship/config.toml";
      STARSHIP_CACHE = "${config.dot.cfg.local}/cache/starship";
      STARSHIP_SHELL = "zsh";
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
      ".config/starship/config.toml".source = "${config.dot.nix.dots}/starship/starship.toml";
      ".config/ghostty/config".source = "${config.dot.nix.dots}/ghostty/config";
      ".config/zed/settings.json".source = "${config.dot.nix.dots}/zed/settings.json";
      ".local/git/bin/git-setup".source = "${config.dot.nix.dots}/zsh/zshenv";                    #
      ".config/1Password/ssh/agent.toml".source = "${config.dot.nix.dots}/1Password/agent.toml";   #
    };

    # State version
    stateVersion = "24.05";
  };

  # TODO: This will be turned into a nix package eventually.
  # # Enable custom git commands for all users
  # programs.customGitCommands = {
  #   enable = true;
  #   commands = [
  #     "git-setup-wrapper"
  #     "git-setup-v2"
  #     "git-setup-advanced"
  #   ];
  # };

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
