# User configuration for adam (Personal)
{
  lib,
  pkgs,
  config,
  dotfilesPath,
  ...
}: {
  imports = [
    ("${config.dot.nix.mods}" + /hosts/base.nix)
  ];

  home = {
    username = config.dot.user.name;
    homeDirectory = config.dot.user.home;

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
