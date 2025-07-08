# User configuration for analyst (CFS)
{
  lib,
  pkgs,
  ...
}:
(import ../base-home.nix {
  username = "analyst";
  homeDirectory = "/Users/analyst";
}) {inherit lib pkgs;}
