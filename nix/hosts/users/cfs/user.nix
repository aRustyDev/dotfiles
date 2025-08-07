# User configuration for analyst (CFS)
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

    # Additional CFS-specific packages
    packages = with pkgs; [
      # Add any CFS-specific tools here
    ];

    # CFS-specific dotfiles
    file = {};
  };
}
