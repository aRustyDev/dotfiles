{
  description = "Darwin system flake for analyst";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nix-darwin,
    nixpkgs,
    home-manager,
  }: let
    # Base darwin configuration
    darwinConfiguration = {
      # Nix daemon settings
      nix.settings.experimental-features = "nix-command flakes";

      # Enable zsh
      programs.zsh.enable = true;

      # System configuration revision
      system.configurationRevision = self.rev or self.dirtyRev or null;
      system.stateVersion = 4;

      # Platform
      nixpkgs.hostPlatform = "x86_64-darwin";
      nixpkgs.config.allowUnfree = true;

      # Touch ID for sudo
      security.pam.services.sudo_local.touchIdAuth = true;
    };

    # Function to create a darwin configuration for a specific machine
    mkDarwinConfiguration = {
      username,
      userConfig,
    }:
      nix-darwin.lib.darwinSystem {
        system = "x86_64-darwin";
        specialArgs = {
          dotfilesPath = /Users/analyst/dotfiles;
        };
        modules = [
          darwinConfiguration
          ./configuration.nix
          home-manager.darwinModules.home-manager
          {
            # Set the specific user for this machine
            users.users."${username}" = {
              name = username;
              home = "/Users/${username}";
            };

            home-manager = {
              backupFileExtension = "nix.bak";
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {
                dotfilesPath = /Users/analyst/dotfiles;
              };
              users."${username}" = import userConfig;
            };
          }
        ];
      };
  in {
    # Machine configurations
    darwinConfigurations = {
      # CFS configuration
      "cfs" = mkDarwinConfiguration {
        username = "analyst";
        userConfig = ./hosts/users/cfs.nix;
      };

      # Cisco configuration
      "cisco-mbp" = mkDarwinConfiguration {
        username = "asmith";
        userConfig = ./hosts/users/seneca.nix;
      };

      # Personal configuration
      "admz-mbp" = mkDarwinConfiguration {
        username = "adam";
        userConfig = ./hosts/users/personal.nix;
      };

      # Legacy hostname using cfs configuration
      "nw-mbp" = mkDarwinConfiguration {
        username = "analyst";
        userConfig = ./hosts/users/cfs.nix;
      };
    };
  };
}
