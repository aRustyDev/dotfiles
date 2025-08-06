# User configuration for asmith (Cisco)
{
  lib,
  pkgs,
  config,
  dotfilesPath,
  ...
}: {
  imports = [
    ../../pkg-mgr/homebrew/casks.nix
  ];

  home = {

    # Azure-specific PATH configuration
    sessionVariables = {
      # Set Azure-specific paths

      # Note: PATH is managed by .zshrc to ensure proper ordering
      # Any special PATH requirements should be added to .zshrc
    };

    # Additional Azure-specific packages
    packages = with pkgs; [
      # Add any Azure-specific tools here
    ];

    homebrew = {
        casks = [];
    };

    # Azure-specific dotfiles
    file = {
      ".config/azure/config".source = "${dotfilesPath}/azure/config";
    };
  };
}
