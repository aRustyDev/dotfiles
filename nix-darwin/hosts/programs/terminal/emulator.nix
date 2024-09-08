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
      # alacritty # https://www.youtube.com/watch?v=uOnL4fEnldA
      # kitty
      # wezterm
    ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
    # file = {
    #   ".config/starship/config.toml".source = (builtins.toPath "${home_dir}/dotfiles/starship/starship.toml");
    # };

    # sessionVariables = {
    #   ZDOTDIR = (builtins.toPath "${home_dir}/.config/zsh");
    #   STARSHIP_CONFIG = (builtins.toPath "${home_dir}/.config/starship/config.toml");
    # };
  };
  # programs = {
  # };
}
