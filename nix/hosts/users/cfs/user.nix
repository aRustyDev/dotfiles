# nix/hosts/users/cfs/user.nix
{
  lib,
  pkgs,
  config,
  dotfilesPath,
  ...
}:
let
  # Define the list of casks once
  userPkgs = with pkgs; [
    # Add any CFS-specific tools here
  ];
in
{
  imports = [
    ("${config.dot.nix.mods}" + /hosts/base.nix)
  ];

  config.packages.user = userPkgs;

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
    packages = userPkgs;

    # CFS-specific dotfiles
    file = {};
  };
};
