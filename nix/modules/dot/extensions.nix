# nix/modules/dot/extensions.nix
{ config, pkgs, lib, ... }:
# This module will contribute to the 'config.dot' option
{
  config.dot = rec {
    volta = {
      enable = true;
      # Access parts of dot that might have been defined in other modules via 'config.dot'
      home = "${config.dot.cfg.dir}/volta";
      bin = "${volta.home}/bin";
      nix = "${config.dot.nix.pkgs}/node";
    };
    git = {
      enable = true;
      cfg =  "${config.dot.cfg.dir}/git";
      commands = "${git.cfg}/commands";
      hooks = "${config.dot.nix.pkgs}/hooks";
    };
    scripts = {
      root = "${config.dot.nix.dir}/scripts";
      active = "${scripts.root}/active";
      activation = "${scripts.root}/activation";
    };
    nvim = {
      enable = true;
      cfg =  "${config.dot.cfg.dir}/nvim";
      nix = "${config.dot.nix.dir}/nvim";
    };
  };
}
