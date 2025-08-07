# nix/hosts/users/cisco/casks.nix
{ config, lib, pkgs, ... }:
{
  # Directly set the value for the declared option config.casks.user
  config.casks.user = [
    # always upgrade auto-updated or unversioned cask to latest version even if already installed
    # NOTE: The casks here should be things that need to be updated regularly or easily

  ];
}
