# User configuration for analyst (CFS)
{
  lib,
  pkgs,
  config,
  dotfilesPath,
  ...
}: {
  imports = [
    ../base.nix
    ../../pkg-mgr/npm/volta.nix
    ../../pkg-mgr/homebrew/casks.nix
  ];

  home = {
    username = "asmith";
    homeDirectory = "/Users/asmith";

    # User-specific PATH configuration
    sessionVariables = {
      # Set user-specific paths

      # Note: PATH is managed by .zshrc to ensure proper ordering
      # Any special PATH requirements should be added to .zshrc
    };

    # Additional CFS-specific packages
    packages = with pkgs; [
      # Add any CFS-specific tools here
    ];

    homebrew = {
        casks = [
          "adobe-acrobat-pro"
        ];
    };

    # CFS-specific dotfiles
    file = {};
  };
}
