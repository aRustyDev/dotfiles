# home.nix
# home-manager switch

{ config, lib, pkgs, ... }:

let
  home_dir = "/Users/greymatter";
in
{
  home.username = lib.mkDefault "greymatter";
  home.homeDirectory = lib.mkDefault "/Users/greymatter";
  home.stateVersion = "24.05"; # Please read the comment before changing.

# Makes sense for user specific applications that shouldn't be available system-wide
  home.packages = with pkgs; [
    helix
    # lunarvim
    # spacevim
    # vimPlugins.neogit
    # gitoxide
    neovim
      # https://www.youtube.com/watch?v=x__SZUuLOxw
      # https://www.youtube.com/watch?v=E2mKJ73M9pg
    zellij
    starship
    tmux
    # wget
    # git
    # gnupg
    # vscode

    # librewolf
    # # zen # https://github.com/NixOS/nixpkgs/issues/327982
    # arc-browser
    # mullvad-browser

    # slack-cli
    # slack
    # slack-term

    # _1password-cli
    # _1password-cli-beta
    # _1password-gui
    # _1password-gui-beta
    # go-passbolt-cli

    # direnv

    # fscryptctl
    # age
    # agebox # Git Repo Encryption

    # xcodes
    # darwin.xcode
    # xcode-install
    # xcbuild
    # # swiftPackages.xcbuild
    # cocoapods
    # cocoapods-beta
    # darwin.ios-deploy
    # xcbeautify

    # # SSH :
    # sshs
    # fast-ssh
    # # tctl # Not in nixpkgs
    # # tsh # Not in nixpkgs
    # # teleport-connect # Not in nixpkgs

    # # TUIs (Misc) :
    # so
    # docui
    # impala
    # dooit
    # tdf
    # tuifeed
    # jqp
    # notcurses
    # bluetuith
    # youtube-tui
    # hextazy
    # thokr
    # clipse
    # caligula
    # nix-inspect
    # oha
    # lazysql
    # gobang
    # russ
    # mprocs
    # ngggram
    # scope-tui
    # s-tui
    # openapi-tui
    # md-tui
    # mqtt-tui
    # manga-tui
    # libcryptui
    # gpg-tui
    # gitui
    # csv-tui
    # cicero

    # atac
    # termshark
    # tshark
    # # portal # Still not sure about this one
    # glow
    # ripgrep
    # # orbstack
    # # localstack
    # # nerdfonts
    # # bat
    # # zoxide
    # starship
    # # alacritty # https://www.youtube.com/watch?v=uOnL4fEnldA
    # # kitty
    # # wezterm
    # tmux # https://www.youtube.com/watch?v=DzNmUNvnB04
    # yazi
    # bruno
    # obsidian
    # pre-commit
    # lazygit

    # # Terraform :
    # terraform
    # tenv
    # terraform-local
    # terraform-docs
    # terraform-inventory
    # # pluralith # Not in nixpkgs
    # tftui

    # # Android
    # adbtuifm

    # # Workflow : https://temporal.io/how-it-works
    # # temporal-cli # Still not sure about this one

    # # Rust : https://xeiaso.net/blog/how-i-start-nix-2020-03-08/
    # rustup
    # rustc
    # cargo
    # rustfmt
    # rustPackages.clippy
    # rustycli
    # rust-script
    # rust-petname
    # rust-code-analysis
    # jetbrains.rust-rover
    # rustup-toolchain-install-master
    # # RUST_BACKTRACE = 1;

    # # Java :
    # jetbrains.idea-ultimate

    # # golang
    # jetbrains.goland

    # # C/C++ :
    # jetbrains.clion

    # atuin
    # natscli
    # nats-top
    # nats-server
    # nkeys
    # nsc

    # cloudflared
    # cloudflare-warp
    # wrangler
    # cloudflare-utils

    # citrix_workspace
    # vmware-horizon-client
    # vmware-workstation
    # virtualbox
    # kvmtool
    # libvirt
    # virter
    # qemu
    # firectl
    # firecracker

    # # ruby
    # # python
    # # node
    # # vault
    # # helm
    # # packer
    # # vagrant

    # wireguard-tools
    # wireguard-go

    # jq
    # yq

    # # kubectl
    # # kubelogin-oidc
    # # kubeshark
    # # k9s
    # # cilium-cli

    # # aws-cli
    # # azure-cli
    # # google-cloud-sdk
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".zshrc".source = (builtins.toPath "${home_dir}/dotfiles/zsh/.zshrc");
    ".config/1Password/ssh/agent.toml".source = (builtins.toPath "${home_dir}/dotfiles/1password/agent.toml");
    # ".config/wezterm".source = (builtins.toPath "${home_dir}/dotfiles/wezterm");
    # ".config/skhd".source = (builtins.toPath "${home_dir}/dotfiles/skhd");
    ".config/starship/config.toml".source = (builtins.toPath "${home_dir}/dotfiles/starship/starship.toml");
    # ".config/zellij".source = (builtins.toPath "${home_dir}/dotfiles/zellij");
    # ".config/nvim".source = (builtins.toPath "${home_dir}/dotfiles/nvim");
    # ".config/nix".source = (builtins.toPath "${home_dir}/dotfiles/nix");
    # ".config/nix-darwin".source = (builtins.toPath "${home_dir}/dotfiles/nix-darwin");
    # ".config/tmux".source = (builtins.toPath "${home_dir}/dotfiles/tmux");
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    PAGER = "less";
    LESS = "-R";
    ZDOTDIR = (builtins.toPath "${home_dir}/.config/zsh");
    GPG_TTY = "$(tty)";
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    HISTSIZE = "32768";
    HISTFILESIZE = "32768"; # "${HISTSIZE}";
    HISTCONTROL = "ignoreboth";
    STARSHIP_CONFIG = (builtins.toPath "${home_dir}/.config/starship/config.toml");
    HELLO = "world";
  };

  home.sessionPath = [
    "/run/current-system/sw/bin"
    "$HOME/.nix-profile/bin"
  ];
  programs = {
    home-manager.enable = true;
    starship = {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = false;
      enableBashIntegration = true;
      # Configuration written to ~/.config/starship.toml
      settings = {
        add_newline = false;
        format = "$directory$character";
        # shlvl = {
        #   disabled = false;
        #   symbol = "";
        #   style = "bright-red bold";
        # };
        shell = {
          disabled = false;
          format = "$indicator";
          fish_indicator = "";
          bash_indicator = "[BASH](bright-white) ";
          zsh_indicator = "[ZSH](bright-white) ";
        };
        username = {
          style_user = "bright-white bold";
          style_root = "bright-red bold";
        };
        hostname = {
          style = "bright-green bold";
          ssh_only = true;
        };
        nix_shell = {
          symbol = "❄️ ";
          style = "bright-blue bold";
          format = "[$symbol$name]($style) ";
        };
        git_branch = {
          only_attached = true;
          format = "[$symbol$branch]($style) ";
          symbol = "שׂ";
          style = "bright-yellow bold";
        };
        git_commit = {
          only_detached = true;
          format = "[$hash]($style) ";
          style = "bright-yellow bold";
        };
        git_state = {
          style = "bright-purple bold";
        };
        git_status = {
          style = "bright-green bold";
        };
        directory = {
          symbol = "❄️ ";
          style = "bright-blue bold";
          format = "[$symbol$name]($style) ";
          truncation_length = 0;
        };
        cmd_duration = {
          format = "[$duration]($style) ";
          style = "bright-blue";
        };
        jobs = {
          style = "bright-green bold";
        };
        character = {
          success_symbol = "[\\$](bright-green bold)";
          error_symbol = "[\\$](bright-red bold)";
        };
      };
    };

    zsh = {
      enable = true;
      initExtra = ''
        # Add any additional configurations here
        export PATH=/run/current-system/sw/bin:$HOME/.nix-profile/bin:$PATH
        if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
          . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
        fi
      '';
    };
  };
}