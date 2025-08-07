# nix/zsh/config.nix
{ config, pkgs, lib, ... }:
# This module will contribute to the 'config.dot' option
{
  config.dot = rec {
    zsh = {
      enable = true;
      dir = "${config.dot.cfg.dir}/zsh";
      completions = "${zsh.dir}/completions";
      symlinks = "${zsh.dir}/symlinks";
      plugins = "${zsh.dir}/plugins";
      aliases = "${zsh.dir}/aliases";
      env = "${zsh.dir}/.zshenv";
      cfg =  "${zsh.dir}/.zshrc";
    };
  };
  home = {
    # Common environment variables (user-specific paths will be set in user configs)
    sessionVariables = lib.mkIf (config.dot.zsh.enable) {
      ZDOTDIR = config.dot.zsh.dir;
    };

    # Additional Cisco/work-specific packages
    packages = with pkgs; [
      # Add any work-specific tools here
      # For example: corporate VPN clients, work-specific CLI tools, etc.
    ];

    # Common dotfile links
    file = lib.mkIf (config.dot.zsh.enable) {
      "/etc/zshenv".source = "${config.dot.nix.dir}/zsh/zshenv";                                 # Set this so the 'sessionVariables' for Zsh Take effect
      "${config.dot.zsh.dir}/.zshenv".source = "${config.dot.nix.dir}/zsh/zshenv";
      "${config.dot.zsh.dir}/.zprofile".source = "${config.dot.nix.dir}/zsh/zprofile";
      "${config.dot.zsh.dir}/.zlogout".source = "${config.dot.nix.dir}/zsh/zlogout";
      "${config.dot.zsh.dir}/.zlogin".source = "${config.dot.nix.dir}/zsh/zlogin";
      "${config.dot.zsh.dir}/.zshrc".source = "${config.dot.nix.dir}/zsh/zshrc";
      "${config.dot.zsh.dir}/completions".source = "${config.dot.nix.dir}/zsh/completions/";
      "${config.dot.zsh.dir}/custom/".source = "${config.dot.nix.dir}/zsh/custom/";
    };
  };
}
