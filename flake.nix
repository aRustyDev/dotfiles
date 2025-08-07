{
  description = "Darwin system flake for cfs/cisco/home/usaf";

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
    darwinConfiguration = {config, lib, pkgs, ...}: {
      # Nix daemon settings
      nix.settings.experimental-features = "nix-command flakes";

      programs = {
        # Enable zsh
        # Create /etc/zshrc that loads the nix-darwin environment.
        zsh.enable = true; # default shell on catalina

        # fish.enable = true;
        # nushell.enable = true;
      };

      # Platform (The platform the configuration will be used on.)
      nixpkgs = {
        hostPlatform = "aarch64-darwin";
        config.allowUnfree = true;
      };

      services = {};

      # Touch ID for sudo
      security.pam.services.sudo_local.touchIdAuth = true;

      # Homebrew needs to be installed on its own!
      homebrew = {
          enable = true;
          global.autoUpdate = true; # "false" for declarative || "true" for 'homebrew' manageable.
      };

      # https://medium.com/@zmre/nix-darwin-quick-tip-activate-your-preferences-f69942a93236
      # system.activationScripts.postUserActivation.text = ''
      #   # Following line should allow us to avoid a logout/login cycle
      #   /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
      # '';
      system = {
        # System configuration revision
        # Set Git commit hash for darwin-version.
        configurationRevision = self.rev or self.dirtyRev or null;

        # Used for backwards compatibility, please read the changelog before changing.
        # $ darwin-rebuild changelog
        stateVersion = 4;

        defaults = {

          # START: https://daiderd.com/nix-darwin/manual/index.html      #
          dock.autohide = true;
          dock.mru-spaces = false;
          finder.AppleShowAllExtensions = true;
          finder.FXPreferredViewStyle = "clmv";
          # loginwindow.LoginwindowText = username;
          screencapture.location = "~/Pictures/screenshots";
          screensaver.askForPasswordDelay = 180;
          # END: https://daiderd.com/nix-darwin/manual/index.html      #

          CustomUserPreferences = {
            "com.apple.finder" = {
              ShowExternalHardDrivesOnDesktop = true;
              ShowHardDrivesOnDesktop = true;
              ShowMountedServersOnDesktop = true;
              ShowRemovableMediaOnDesktop = true;
              _FXSortFoldersFirst = true;
              # When performing a search, search the current folder by default
              FXDefaultSearchScope = "SCcf";
            };
            "com.apple.desktopservices" = {
              # Avoid creating .DS_Store files on network or USB volumes
              DSDontWriteNetworkStores = true;
              DSDontWriteUSBStores = true;
            };
            "com.apple.screensaver" = {
              # Require password immediately after sleep or screen saver begins
              askForPassword = 3600;
              askForPasswordDelay = 0;
            };
            "com.apple.screencapture" = {
              location = "~/Desktop";
              type = "png";
            };
            "com.apple.SoftwareUpdate" = {
              AutomaticCheckEnabled = true;
              # Check for software updates daily, not just once per week
              ScheduleFrequency = 1;
              # Download newly available updates in background
              AutomaticDownload = 1;
              # Install System data files & security updates
              CriticalUpdateInstall = 1;
            };
            # "com.apple.Safari" = {
            #   # Privacy: don’t send search queries to Apple
            #   UniversalSearchEnabled = false;
            #   SuppressSearchSuggestions = true;
            #   # Press Tab to highlight each item on a web page
            #   WebKitTabToLinksPreferenceKey = true;
            #   ShowFullURLInSmartSearchField = true;
            #   # Prevent Safari from opening ‘safe’ files automatically after downloading
            #   AutoOpenSafeDownloads = false;
            #   ShowFavoritesBar = false;
            #   IncludeInternalDebugMenu = true;
            #   IncludeDevelopMenu = true;
            #   WebKitDeveloperExtrasEnabledPreferenceKey = true;
            #   WebContinuousSpellCheckingEnabled = true;
            #   WebAutomaticSpellingCorrectionEnabled = false;
            #   AutoFillFromAddressBook = false;
            #   AutoFillCreditCardData = false;
            #   AutoFillMiscellaneousForms = false;
            #   WarnAboutFraudulentWebsites = true;
            #   WebKitJavaEnabled = false;
            #   WebKitJavaScriptCanOpenWindowsAutomatically = false;
            #   # "com.apple.Safari.ContentPageGroupIdentifier.WebKit2TabsToLinks" = true;
            #   # "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" = true;
            #   # "com.apple.Safari.ContentPageGroupIdentifier.WebKit2BackspaceKeyNavigationEnabled" = false;
            #   # "com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabled" = false;
            #   # "com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabledForLocalFiles" = false;
            #   # "com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically" = false;
            # };
          };
        };
      };
    };

    # Function to create a darwin configuration for a specific machine
    mkDarwinConfiguration = {
      username,
      usercfg,
      # dot,
      ...
    }:
      let
        # Define paths at this level so they're available throughput
        dotfilesPath = "/Users/${username}/.config/nix";
        homeDirectory = "/Users/${username}";
      in
      nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = {
          inherit usercfg dotfilesPath;                                 # Pass usercfg to system modules
        };

        modules = [
          # Imports
          darwinConfiguration
          home-manager.darwinModules.home-manager
          (./nix/hosts/users + "/${usercfg}" + /casks.nix)

          # Specific Definitions
          {
            # Determinate uses its own daemon to manage the Nix installation that conflicts with nix-darwin’s native Nix management.
            nix.enable = false; # For Determinate Systems Nix.
            system.primaryUser = username;
            users.users."${username}" = {
              name = username;
              home = homeDirectory;
            };

            # TODO: How to define the common 'Files' here, and then import/with the usercfg values into scope.
            home-manager = {
              # Set the specific user for this machine
              users."${username}" = {
                # This is the list of modules that will be evaluated for this user's Home Manager config
                modules = [
                  # 1. Import the 'dot' option definition
                  ./nix/modules/options/dot.nix

                  # 2. Import your main user configuration module
                  (import (./nix/hosts/users + "/${usercfg}" + /user.nix))

                  # 3. Import the 'tree' module that contributes dotfile path fields
                  ./nix/modules/dot/tree.nix

                  # Add any other Home Manager modules here as needed
                ];

                backupFileExtension = "nix.bak";
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = {
                  # Only pass truly "extra" arguments here.
                  # 'dot' is now handled by the module system's 'config' object.
                  inherit usercfg dotfilesPath;
                };
              };
            };
          }
        ];
      };
  in {
    # Machine configurations
    darwinConfigurations = {
      # CFS configuration
      "cfs" = mkDarwinConfiguration {
        username = "asmith";
        usercfg =  "cfs";
      };

      # Cisco configuration
      "cisco" = mkDarwinConfiguration {
        username = "adamsm";
        usercfg =  "cisco";
      };

      # Personal configuration
      "personal" = mkDarwinConfiguration {
        username = "adam";
        usercfg =  "personal";
      };
    };
  };
}
