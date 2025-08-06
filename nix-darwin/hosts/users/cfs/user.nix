# User configuration for analyst (CFS)
{
  lib,
  pkgs,
  config,
  dotfilesPath,
  ...
}: {
  imports = [
    ../../base.nix
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

    # CFS-specific dotfiles
    file = {};
  };
}
