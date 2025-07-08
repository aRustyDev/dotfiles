# User configuration for adam (Personal)
{
  lib,
  pkgs,
  ...
}:
(import ../base-home.nix {
  username = "adam";
  homeDirectory = "/Users/adam";
  machineType = "admz-mbp";
}) {inherit lib pkgs;}
