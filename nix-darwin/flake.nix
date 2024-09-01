{
  # https://github.com/LnL7/nix-darwin
  description = "Example Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = with pkgs; [
        vim
        neovim
          # https://www.youtube.com/watch?v=x__SZUuLOxw
          # https://www.youtube.com/watch?v=E2mKJ73M9pg
        wget
        git
        gnupg
        vscode

        librewolf
        # zen # https://github.com/NixOS/nixpkgs/issues/327982
        arc-browser
        mullvad-browser

        slack-cli
        slack
        slack-term

        _1password-cli
        _1password-cli-beta
        _1password-gui
        _1password-gui-beta
        go-passbolt-cli

        direnv

        fscryptctl
        age
        agebox # Git Repo Encryption

        xcodes
        darwin.xcode
        xcode-install
        xcbuild
        # swiftPackages.xcbuild
        cocoapods
        cocoapods-beta
        darwin.ios-deploy
        xcbeautify

        # SSH :
        sshs
        fast-ssh
        # tctl # Not in nixpkgs
        # tsh # Not in nixpkgs
        # teleport-connect # Not in nixpkgs

        # TUIs (Misc) :
        so
        docui
        impala
        dooit
        tdf
        tuifeed
        jqp
        notcurses
        bluetuith
        youtube-tui
        hextazy
        thokr
        clipse
        caligula
        nix-inspect
        oha
        lazysql
        gobang
        russ
        mprocs
        ngggram
        scope-tui
        s-tui
        openapi-tui
        md-tui
        mqtt-tui
        manga-tui
        libcryptui
        gpg-tui
        gitui
        csv-tui
        cicero

        atac
        termshark
        tshark
        # portal # Still not sure about this one
        glow
        ripgrep
        # orbstack
        # localstack
        # nerdfonts
        # bat
        # zoxide
        starship
        # alacritty # https://www.youtube.com/watch?v=uOnL4fEnldA
        # kitty
        # wezterm
        tmux # https://www.youtube.com/watch?v=DzNmUNvnB04
        yazi
        bruno
        obsidian
        pre-commit
        lazygit

        # Terraform :
        terraform
        tenv
        terraform-local
        terraform-docs
        terraform-inventory
        # pluralith # Not in nixpkgs
        tftui

        # Android
        adbtuifm

        # Workflow : https://temporal.io/how-it-works
        # temporal-cli # Still not sure about this one

        # Rust : https://xeiaso.net/blog/how-i-start-nix-2020-03-08/
        rustup
        rustc
        cargo
        rustfmt
        rustPackages.clippy
        rustycli
        rust-script
        rust-petname
        rust-code-analysis
        jetbrains.rust-rover
        rustup-toolchain-install-master
        # RUST_BACKTRACE = 1;

        # Java :
        jetbrains.idea-ultimate

        # golang
        jetbrains.goland

        # C/C++ :
        jetbrains.clion

        atuin
        natscli
        nats-top
        nats-server
        nkeys
        nsc

        cloudflared
        cloudflare-warp
        wrangler
        cloudflare-utils

        citrix_workspace
        vmware-horizon-client
        vmware-workstation
        virtualbox
        kvmtool
        libvirt
        virter
        qemu
        firectl
        firecracker

        # ruby
        # python
        # node
        # vault
        # helm
        # packer
        # vagrant

        wireguard-tools
        wireguard-go

        jq
        yq

        # kubectl
        # kubelogin-oidc
        # kubeshark
        # k9s
        # cilium-cli

        # aws-cli
        # azure-cli
        # google-cloud-sdk
      ];

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh.enable = true;  # default shell on catalina
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 4;


      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "x86_64-darwin";

      # Enable touch id for sudo
      security.pam.enableSudoTouchIdAuth = true;

      users.users.arustydev.home = "/Users/analyst";
      home-manager.backupFileExtension = "backup";
      nix.configureBuildUsers = true;
      nix.useDaemon = true;

      # https://daiderd.com/nix-darwin/manual/index.html      #
      system.defaults = {
        dock.autohide = true;
        dock.mru-spaces = false;
        finder.AppleShowAllExtensions = true;
        finder.FXPreferredViewStyle = "clmv";
        loginwindow.LoginwindowText = "aRustyDev";
        screencapture.location = "~/Pictures/screenshots";
        screensaver.askForPasswordDelay = 10;
      };

      # Homebrew needs to be installed on its own!
      homebrew.enable = true;
      homebrew.casks = [
	      "wireshark"
        "orbstack"
        "nikitabobko/tap/aerospace" # https://www.youtube.com/watch?v=-FoWClVHG5g
        "tetra" # https://tetragon.io/docs/installation/tetra-cli/
      ];
      homebrew.brews = [
	      "imagemagick"
      ];
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."simple" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."simple".pkgs;
  };
}
