# nix/hosts/users/cfs/casks.nix
{
  config, # The merged configuration, including your custom config.casks.user
  lib,
  pkgs,
  ...
}:
let
  # Define the list of casks once
  userCasks = [
    # always upgrade auto-updated or unversioned cask to latest version even if already installed
    # NOTE: The casks here should be things that need to be updated regularly or easily
    "adobe-acrobat-pro"
  ];
in
{
  # 1. Contribute to the Nix-Darwin 'homebrew.casks' option
  # This is a top-level option directly understood by nix-darwin.
  homebrew.casks = userCasks;

  # 2. Contribute to your custom 'config.casks.user' option
  # This is part of your custom configuration structure.
  config.casks.user = userCasks;
}
