# nix/zellij/config.nix
{ config, pkgs, lib, ... }:
# This module will contribute to the 'config.dot' option
{
  config.dot = rec {
    zellij = {
      enable = pkgs.lib.elem "zellij" config.packages.inScope;
      # dir = "${config.dot.cfg.dir}/zsh";
      # completions = "${zsh.dir}/completions";
      # symlinks = "${zsh.dir}/symlinks";
      # plugins = "${zsh.dir}/plugins";
      # aliases = "${zsh.dir}/aliases";
      # env = "${zsh.dir}/.zshenv";
      # cfg =  "${zsh.dir}/.zshrc";
    };
  };
  home = {
    # Common environment variables (user-specific paths will be set in user configs)
    sessionVariables = lib.mkIf (config.dot.zellij.enable) {
      # ZDOTDIR = config.dot.zellij.dir;
    };

    # Common dotfile links
    file = lib.mkIf (config.dot.zellij.enable) {
      # "/etc/zshenv".source = "${dotfilesPath}/zsh/zshenv";                                 # Set this so the 'sessionVariables' for Zsh Take effect
      # "${config.dot.zsh.dir}/.zshenv".source = "${dotfilesPath}/zsh/zshenv";
      # "${config.dot.zsh.dir}/.zprofile".source = "${dotfilesPath}/zsh/zprofile";
      # "${config.dot.zsh.dir}/.zlogout".source = "${dotfilesPath}/zsh/zlogout";
      # "${config.dot.zsh.dir}/.zlogin".source = "${dotfilesPath}/zsh/zlogin";
      # "${config.dot.zsh.dir}/.zshrc".source = "${dotfilesPath}/zsh/zshrc";
      # "${config.dot.zsh.dir}/completions".source = "${dotfilesPath}/zsh/completions/";
      # "${config.dot.zsh.dir}/custom/".source = "${dotfilesPath}/zsh/custom/";
    };
  };
}
