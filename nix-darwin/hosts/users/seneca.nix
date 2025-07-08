# User configuration for asmith (Cisco)
{
  lib,
  pkgs,
  ...
}:
(import ../base-home.nix {
  username = "asmith";
  homeDirectory = "/Users/asmith";
}) {inherit lib pkgs;}
