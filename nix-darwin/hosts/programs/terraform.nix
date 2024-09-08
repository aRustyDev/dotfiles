# home.nix
# home-manager switch

{ config, lib, pkgs, ... }:

let
  home_dir = "/Users/greymatter";
in
{
  home = {
    username = lib.mkDefault "greymatter";
    homeDirectory = lib.mkDefault "/Users/greymatter";
    stateVersion = "24.05"; # Please read the comment before changing.

# Makes sense for user specific applications that shouldn't be available system-wide
    packages = with pkgs; [
      # terraform
      # tenv
      # terraform-local
      # terraform-docs
      # terraform-inventory
      # # pluralith # Not in nixpkgs
      # tftui
    ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
    # file = {
    #   ".config/starship/config.toml".source = (builtins.toPath "${home_dir}/dotfiles/starship/starship.toml");
    # };

    # sessionVariables = {
    #   TF_LOG = "debug";
    #   TF_CLI_ARGS = "-no-color";
    #   TF_LOG_PATH = (builtins.toPath "${home_dir}/.cache/terraform.log");
    #   TF_DATA_DIR = (builtins.toPath "${home_dir}/.config/terraform"); # https://developer.hashicorp.com/terraform/cli/config/environment-variables#tf_data_dir
    #   TF_CLI_CONFIG_FILE = (builtins.toPath "${home_dir}/.config/terraform/.tfrc"); # https://developer.hashicorp.com/terraform/cli/config/environment-variables#tf_cli_config_file
    #   TF_PLUGIN_CACHE_DIR = (builtins.toPath "${home_dir}/.config/terraform/plugins"); # https://developer.hashicorp.com/terraform/cli/config/environment-variables#tf_plugin_cache_dir
    # };
  };
  # programs = {
  # };
}
