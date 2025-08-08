# nix/zsh/config.nix
{ config, pkgs, lib, ... }:

let
  # Example input list passed to the module
  inputList = config.dot.zed;

  # Mapping from known elements to JSON file paths
  settingsMap = {
    agent = ./settings/agent.json;
    sieve = ./settings/sieve.json;
    ssh = ./settings/ssh.json;
  };

  # Function to load JSON for a given element if it exists in the map
  loadJsonForElement = element:
    if builtins.hasAttr element settingsMap then
      builtins.fromJSON (builtins.readFile (settingsMap.${element}))
    else
      {};

  # Filter inputList for known elements and load their JSONs
  loadedJsons = map loadJsonForElement (builtins.filter (e: builtins.hasAttr e settingsMap) inputList);

  # Merge all loaded JSON objects into one attribute set
  settingsMerged = builtins.foldl' (acc jsonObj: acc // jsonObj) {} loadedJsons;

in
# This module will contribute to the 'config.dot' option
{
  options.myModule.inputList = {
    type = with pkgs.lib.types; listOf string;
    description = "List of elements to check and load JSON for";
  };

  config = {
    dot = rec {
      zed = {
        enable = true;
        settings = settingsMerged;
        dir = "${config.dot.cfg.dir}/zsh";
        completions = "${zsh.dir}/completions";
        symlinks = "${zsh.dir}/symlinks";
        plugins = "${zsh.dir}/plugins";
        aliases = "${zsh.dir}/aliases";
        env = "${zsh.dir}/.zshenv";
        cfg =  "${zsh.dir}/.zshrc";
      };
    }
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
      "${config.dot.cfg.dir}/zed/settings.json".source = "${config.dot.nix.dir}/zed/settings.json";
    };
  };
}
