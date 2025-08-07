# nix/hosts/users/${usercfg}/user.nix
{ config, pkgs, lib, username, homeDirectory, usercfg, dotfilesPath, ... }:
# Note: 'dot' is no longer passed as an explicit argument here,
#       it's accessed via 'config.dot' after merging.
{
  # Define the base parts of config.dot
  config.dot = rec {
    cfg = {
      dir = "${homeDirectory}/.config";
    };
    local = rec {
      dir = "${homeDirectory}/.local";
      data = "${local.dir}/data";
      share = "${local.dir}/share";
      cache = "${local.dir}/cache";
      run = "${local.dir}/run";
    };
    nix = {
      dots = "${cfg.dir}/nix";
      mods = "${nix.dots}/nix";
      pkgs = "${nix.mods}/pkg-mgr";
      mods = "${nix.mods}/modules";
      hosts = "${nix.mods}/hosts";
      plugins = "${nix.mods}/plugins";
    };

    # Machine configuration metadata
    user = {
      cfg = usercfg;
      name = username;
      home = homeDirectory;
    };
  };

  # You can also define other Home Manager configurations here
  # For example:
  # home.packages = [ pkgs.htop pkgs.neofetch ];
  # programs.git.enable = true;
}
