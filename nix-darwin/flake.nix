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
    darwinConfiguration = {
      # Nix daemon settings
      nix.settings.experimental-features = "nix-command flakes";

      programs = {
        # Enable zsh
        # Create /etc/zshrc that loads the nix-darwin environment.
        zsh.enable = true; # default shell on catalina

        # fish.enable = true;
        # nushell.enable = true;
      };

      system = {
        # System configuration revision
        # Set Git commit hash for darwin-version.
        configurationRevision = self.rev or self.dirtyRev or null;

        # Used for backwards compatibility, please read the changelog before changing.
        # $ darwin-rebuild changelog
        stateVersion = 4;
      };


      # Platform (The platform the configuration will be used on.)
      nixpkgs = {
        hostPlatform = "aarch64-darwin";
        config.allowUnfree = true;
      };

      services = {
        # Auto upgrade nix package and the daemon service.
        nix-daemon.enable = true;
      };

      # Touch ID for sudo
      security.pam.services.sudo_local.touchIdAuth = true;

      # Homebrew needs to be installed on its own!
      homebrew = {
          enable = true;
          global.autoUpdate = true; # "false" for declarative || "true" for 'homebrew' manageable.
          casks = import userConfig;
      };

      # https://medium.com/@zmre/nix-darwin-quick-tip-activate-your-preferences-f69942a93236
      # system.activationScripts.postUserActivation.text = ''
      #   # Following line should allow us to avoid a logout/login cycle
      #   /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
      # '';
      system.defaults.CustomUserPreferences = {
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
        "com.apple.Safari" = {
          # Privacy: don’t send search queries to Apple
          UniversalSearchEnabled = false;
          SuppressSearchSuggestions = true;
          # Press Tab to highlight each item on a web page
          WebKitTabToLinksPreferenceKey = true;
          ShowFullURLInSmartSearchField = true;
          # Prevent Safari from opening ‘safe’ files automatically after downloading
          AutoOpenSafeDownloads = false;
          ShowFavoritesBar = false;
          IncludeInternalDebugMenu = true;
          IncludeDevelopMenu = true;
          WebKitDeveloperExtrasEnabledPreferenceKey = true;
          WebContinuousSpellCheckingEnabled = true;
          WebAutomaticSpellingCorrectionEnabled = false;
          AutoFillFromAddressBook = false;
          AutoFillCreditCardData = false;
          AutoFillMiscellaneousForms = false;
          WarnAboutFraudulentWebsites = true;
          WebKitJavaEnabled = false;
          WebKitJavaScriptCanOpenWindowsAutomatically = false;
          "com.apple.Safari.ContentPageGroupIdentifier.WebKit2TabsToLinks" = true;
          "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" = true;
          "com.apple.Safari.ContentPageGroupIdentifier.WebKit2BackspaceKeyNavigationEnabled" = false;
          "com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabled" = false;
          "com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabledForLocalFiles" = false;
          "com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically" = false;
        };
      };


      # https://daiderd.com/nix-darwin/manual/index.html      #
      system.defaults = {
        dock.autohide = true;
        dock.mru-spaces = false;
        finder.AppleShowAllExtensions = true;
        finder.FXPreferredViewStyle = "clmv";
        loginwindow.LoginwindowText = "analyst";
        screencapture.location = "~/Pictures/screenshots";
        screensaver.askForPasswordDelay = 180;
      };
    };

    # Function to create a darwin configuration for a specific machine
    mkDarwinConfiguration = {
      username,
      userConfig,
    }:
      nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = {
          dotfilesPath = "/Users/${username}/.configs/nix";
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

            # TODO: How to define the common 'Files' here, and then import/with the userConfig values into scope.
            home-manager = {
              backupFileExtension = "nix.bak";
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {
                dotfilesPath = "/Users/${username}/.configs/nix";
              };
              users."${username}" = import "./hosts/users/${userConfig}";
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
        userConfig = cfs.nix;
      };

      # Cisco configuration
      "cisco" = mkDarwinConfiguration {
        username = "adamsm";
        userConfig = cisco.nix;
      };

      # Personal configuration
      "personal" = mkDarwinConfiguration {
        username = "adam";
        userConfig = personal.nix;
      };
    };
  };
}
