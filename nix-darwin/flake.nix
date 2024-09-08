{
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
      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;

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

      security.pam.enableSudoTouchIdAuth = true;

      # Homebrew needs to be installed on its own!
      homebrew.enable = true;
      homebrew.casks = [
	      # "wireshark"
        "orbstack"
        # "nikitabobko/tap/aerospace" # https://www.youtube.com/watch?v=-FoWClVHG5g
        # "tetra" # https://tetragon.io/docs/installation/tetra-cli/
      ];
      # zen-browser/browser https://github.com/zen-browser/desktop.git
      # homebrew.brews = [
	    #   "imagemagick"
      # ];

      users.users."$USER" = {
          name = "$USER";
          home = "/Users/$USER";
      };
      users.users."greymatter".home = "/Users/greymatter";
      # nix.configureBuildUsers = true; # omerxx
      # nix.useDaemon = true; # omerxx

      # # https://daiderd.com/nix-darwin/manual/index.html      #
      # system.defaults = {
      #   dock.autohide = true;
      #   dock.mru-spaces = false;
      #   finder.AppleShowAllExtensions = true;
      #   finder.FXPreferredViewStyle = "clmv";
      #   loginwindow.LoginwindowText = "aRustyDev";
      #   screencapture.location = "~/Pictures/screenshots";
      #   screensaver.askForPasswordDelay = 10;
      # };
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#gm-mbp
    darwinConfigurations."gm-mbp" = nix-darwin.lib.darwinSystem {
      system = "x86_64-darwin";
      modules = [
	      configuration
        ./configuration.nix
        home-manager.darwinModules.home-manager {
          home-manager.backupFileExtension = "nix.bak";
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          # https://nixos-and-flakes.thiscute.world/nixos-with-flakes/modularize-the-configuration
          home-manager.users.greymatter = import ./hosts/personal.nix;
        }
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."gm-mbp".pkgs;
  };
}
