# User configuration for adam (Personal)
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
    username = "adam";
    homeDirectory = "/Users/adam";

    # User-specific PATH configuration
    sessionVariables = {
      # Set user-specific paths

      # Note: PATH is managed by .zshrc to ensure proper ordering
      # Any special PATH requirements should be added to .zshrc
    };

    # Additional personal-specific packages
    packages = with pkgs; [
      # Add any personal tools here
      # For example: games, personal project tools, creative software, etc.
    ];

    # Personal-specific dotfiles
    file = {};
  };
}
