# Example: How to integrate git-setup into your Nix-Darwin configuration

{ config, pkgs, lib, ... }:

{
  # Option 1: Install via home.file (symlink approach)
  home.file = {
    ".local/bin/git-setup" = {
      source = ./commands/git-setup-advanced;
      executable = true;
    };
  };

  # Option 2: Create a proper Nix package
  home.packages = [
    (pkgs.writeScriptBin "git-setup" ''
      #!${pkgs.bash}/bin/bash
      exec ${./commands/git-setup-advanced} "$@"
    '')
  ];

  # Option 3: Git alias approach (works without PATH changes)
  programs.git = {
    enable = true;
    aliases = {
      setup = "!${config.home.homeDirectory}/repos/code/personal/dotfiles/git/commands/git-setup-advanced";
    };
  };

  # Ensure dependencies are available
  home.packages = with pkgs; [
    _1password
    jq
  ];
}
