# base-home.nix
# Shared base configuration for all users
{
  username,
  homeDirectory,
  machineType ? "default",
}: {
  lib,
  pkgs,
  ...
}: let
  home_dir = homeDirectory;
in {
  home = {
    username = lib.mkDefault username;
    homeDirectory = lib.mkDefault homeDirectory;
    stateVersion = "24.05"; # Please read the comment before changing.

    # NOTE: These get overwritten by any "shell"rc managed by home.file
    shellAliases = {
      ll = "ls -l";
      la = "ls -Al";
      pu = "pushd";
      po = "popd";
    };
    # Makes sense for user specific applications that shouldn't be available system-wide
    packages = with pkgs; [
      helix
      # lunarvim
      # spacevim
      # vimPlugins.neogit
      # gitoxide
      neovim
      zed-editor
      claude-code
      # https://www.youtube.com/watch?v=x__SZUuLOxw
      # https://www.youtube.com/watch?v=E2mKJ73M9pg
      zellij
      starship
      # antidote
      tmux
      ghostty-bin # Binary distribution for macOS

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

      _1password-cli
      # _1password-cli-beta  # No beta version available in nixpkgs
      # _1password-gui
      _1password-gui-beta
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
      # # font-awesome_5
      # # typodermic-free-fonts
      # # typodermic-public-domain
      # # input-fonts
      # # google-fonts
      # # bront_fonts
      # # profont
      # # profont
      # # bat
      # # zoxide
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

      # Rust : https://xeiaso.net/blog/how-i-start-nix-2020-03-08/
      rustup

      # Node.js version management
      volta
      # rustycli
      # rust-script
      # rust-petname
      # rust-code-analysis
      # jetbrains.rust-rover
      # rustup-toolchain-install-master

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
    file = {
      ".config/zsh/.zshrc".source = ../../zsh/.zshrc;
      ".config/1Password/ssh/agent.toml".source = ../../1Password/agent.toml;
      ".config/starship.toml".source = ../../starship/starship.toml;
      ".config/ghostty/config".source = ../../ghostty/config;
      ".config/zed/settings.json".source = ../../zed/settings.json;
      # ".claude" = {
      #   source = "${inputs.prompts}/.claude";
      #   recursive = true;
      # };
      # ".config/wezterm".source = ../../wezterm;
      # ".config/skhd".source = ../../skhd;
      # ".config/zellij".source = ../../zellij;
      # ".config/nvim".source = ../../nvim;
      # ".config/nix".source = ../../nix;
      # ".config/nix-darwin".source = ../../nix-darwin;
      # ".config/tmux".source = ../../tmux;
    };

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      PAGER = "less";
      LESS = "-R";
      ZDOTDIR = "${home_dir}/.config/zsh";
      GPG_TTY = "$(tty)";
      LANG = "en_US.UTF-8";
      LC_ALL = "en_US.UTF-8";
      HISTSIZE = "32768";
      HISTFILESIZE = "32768"; # "${HISTSIZE}";
      HISTCONTROL = "ignoreboth";
      STARSHIP_CONFIG = "${home_dir}/.config/starship/config.toml";
      CARGO_HOME = "${home_dir}/.cargo";
      RUSTUP_HOME = "${home_dir}/.rustup";
      RUST_BACKTRACE = "1";
      VOLTA_HOME = "${home_dir}/.volta";
    };

    sessionPath = [
      "/run/current-system/sw/bin"
      "$HOME/.nix-profile/bin"
      "$HOME/.cargo/bin"
      "$HOME/.volta/bin"
    ];

    # Automatically set up Rust toolchain on first run
    activation.setupRust = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [[ ! -d "$HOME/.rustup/toolchains" ]] || [[ -z "$(ls -A $HOME/.rustup/toolchains 2>/dev/null)" ]]; then
        echo "Setting up Rust toolchain for first time..."
        $DRY_RUN_CMD ${pkgs.rustup}/bin/rustup install stable
        $DRY_RUN_CMD ${pkgs.rustup}/bin/rustup default stable
        $DRY_RUN_CMD ${pkgs.rustup}/bin/rustup component add rustfmt clippy rust-analyzer
      fi
    '';

    # Automatically set up Volta and npm tools
    activation.setupVolta = lib.hm.dag.entryAfter ["writeBoundary"] (
      let
        # Read tool configurations
        defaultTools = builtins.fromJSON (builtins.readFile ./npm-tools/default.json);

        # Read machine-specific tools if the file exists
        machineToolsFile = ./npm-tools + "/${machineType}.json";
        machineTools =
          if builtins.pathExists machineToolsFile
          then builtins.fromJSON (builtins.readFile machineToolsFile)
          else {tools = [];};

        # Combine and deduplicate tools
        allTools = defaultTools.tools ++ machineTools.tools;

        # Filter enabled tools only
        enabledTools = builtins.filter (tool: tool.enabled or true) allTools;

        # Generate install commands for each tool
        installCommands =
          map (
            tool: let
              packageSpec =
                if tool.version == "latest"
                then tool.name
                else "${tool.name}@${tool.version}";
            in ''
              echo "Installing ${tool.name} (${tool.description or "npm package"})..."
              # Escape special characters in package name for grep
              escapedName=$(echo "${tool.name}" | sed 's/[[\.*^$()+?{|]/\\&/g')
              if ! ${pkgs.volta}/bin/volta list --format plain 2>/dev/null | grep -q "^$escapedName@"; then
                $DRY_RUN_CMD ${pkgs.volta}/bin/volta install ${packageSpec} || echo "Warning: Failed to install ${tool.name}"
              else
                echo "${tool.name} is already installed"
              fi
            ''
          )
          enabledTools;

        # Join all install commands
        installScript = lib.concatStringsSep "\n" installCommands;
      in ''
        echo "Setting up Volta for Node.js management..."

        # Ensure Volta is set up with Node
        if [[ ! -d "$HOME/.volta/bin/node" ]]; then
          echo "Installing Node.js via Volta..."
          $DRY_RUN_CMD ${pkgs.volta}/bin/volta install node@lts
        fi

        # Create volta symlink if it doesn't exist
        if [[ ! -L "$HOME/.volta/bin/volta" ]]; then
          echo "Creating volta symlink..."
          $DRY_RUN_CMD ln -sf ${pkgs.volta}/bin/volta "$HOME/.volta/bin/volta"
        fi

        # Install npm tools from configuration
        echo "Checking npm tools for ${machineType}..."
        ${installScript}

        echo "Volta setup complete!"
      ''
    );
  };
  programs = {
    home-manager.enable = true;

    zsh = {
      enable = true;
      initContent = ''
        # If you come from bash you might have to change your $PATH.
        # export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
        source ~/.bash_profile

        # Path to your Oh My Zsh installation.
        export ZSH="$HOME/.oh-my-zsh"

        # Set name of the theme to load --- if set to "random", it will
        # load a random theme each time Oh My Zsh is loaded, in which case,
        # to know which specific one was loaded, run: echo $RANDOM_THEME
        # See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
        ZSH_THEME="robbyrussell"

        # Set list of themes to pick from when loading at random
        # Setting this variable when ZSH_THEME=random will cause zsh to load
        # a theme from this variable instead of looking in $ZSH/themes/
        # If set to an empty array, this variable will have no effect.
        # ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

        # Uncomment the following line to use case-sensitive completion.
        # CASE_SENSITIVE="true"

        # Uncomment the following line to use hyphen-insensitive completion.
        # Case-sensitive completion must be off. _ and - will be interchangeable.
        # HYPHEN_INSENSITIVE="true"

        # Uncomment one of the following lines to change the auto-update behavior
        # zstyle ':omz:update' mode disabled  # disable automatic updates
        # zstyle ':omz:update' mode auto      # update automatically without asking
        # zstyle ':omz:update' mode reminder  # just remind me to update when it's time

        # Uncomment the following line to change how often to auto-update (in days).
        # zstyle ':omz:update' frequency 13

        # Uncomment the following line if pasting URLs and other text is messed up.
        # DISABLE_MAGIC_FUNCTIONS="true"

        # Uncomment the following line to disable colors in ls.
        # DISABLE_LS_COLORS="true"

        # Uncomment the following line to disable auto-setting terminal title.
        # DISABLE_AUTO_TITLE="true"

        # Uncomment the following line to enable command auto-correction.
        # ENABLE_CORRECTION="true"

        # Uncomment the following line to display red dots whilst waiting for completion.
        # You can also set it to another string to have that shown instead of the default red dots.
        # e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
        # Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
        # COMPLETION_WAITING_DOTS="true"

        # Uncomment the following line if you want to disable marking untracked files
        # under VCS as dirty. This makes repository status check for large repositories
        # much, much faster.
        # DISABLE_UNTRACKED_FILES_DIRTY="true"

        # Uncomment the following line if you want to change the command execution time
        # stamp shown in the history command output.
        # You can set one of the optional three formats:
        # "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
        # or set a custom format using the strftime function format specifications,
        # see 'man strftime' for details.
        # HIST_STAMPS="mm/dd/yyyy"

        # Would you like to use another custom folder than $ZSH/custom?
        # ZSH_CUSTOM=/path/to/new-custom-folder

        # Which plugins would you like to load?
        # Standard plugins can be found in $ZSH/plugins/
        # Custom plugins may be added to $ZSH_CUSTOM/plugins/
        # Example format: plugins=(rails git textmate ruby lighthouse)
        # Add wisely, as too many plugins slow down shell startup.
        plugins=(git)

        source $ZSH/oh-my-zsh.sh

        # User configuration

        # export MANPATH="/usr/local/man:$MANPATH"

        # You may need to manually set your language environment
        # export LANG=en_US.UTF-8

        # Preferred editor for local and remote sessions
        # if [[ -n $SSH_CONNECTION ]]; then
        #   export EDITOR='vim'
        # else
        #   export EDITOR='mvim'
        # fi

        # Compilation flags
        # export ARCHFLAGS="-arch $(uname -m)"

        # Set personal aliases, overriding those provided by Oh My Zsh libs,
        # plugins, and themes. Aliases can be placed here, though Oh My Zsh
        # users are encouraged to define aliases within a top-level file in
        # the $ZSH_CUSTOM folder, with .zsh extension. Examples:
        # - $ZSH_CUSTOM/aliases.zsh
        # - $ZSH_CUSTOM/macos.zsh
        # For a full list of active aliases, run `alias`.
        #
        # Example aliases
        # alias zshconfig="mate ~/.zshrc"
        # alias ohmyzsh="mate ~/.oh-my-zsh"
        export PATH="/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/opt/X11/bin:/Library/Apple/usr/bin:/Library/TeX/texbin:/Applications/VMware Fusion.app/Contents/Public:/usr/local/go/bin:/Users/analyst/.cargo/bin:/Users/analyst/.nix-profile/bin:/nix/var/nix/profiles/default/bin:/opt/X12/bin:/Applications/VMware:/opt/google-cloud-sdk/bin:/opt/google-cloud-sdk/bin:/opt/google-cloud-sdk/bin"
        #. "/Users/analyst/.deno/env"export PATH="/usr/local/opt/node@22/bin:$PATH"
        source /Users/analyst/.config/op/plugins.sh
        source /Users/analyst/.config/op/plugins.sh
        source /Users/analyst/.config/op/plugins.sh
        source /Users/analyst/.config/op/plugins.sh
        export PATH="/usr/local/opt/ruby/bin:$PATH"
        export PATH="$HOME/.fvm/bin:$HOME/.fluvio/bin:$PATH"

        . "$HOME/.atuin/bin/env"

        eval "$(atuin init zsh)"
      '';
    };

    starship = {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = false;
      enableBashIntegration = true;
    };
  };
}
