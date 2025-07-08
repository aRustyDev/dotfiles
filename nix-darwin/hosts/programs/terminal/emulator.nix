# home.nix
# home-manager switch
{
  lib,
  pkgs,
  ...
}: {
  home = {
    username = lib.mkDefault "greymatter";
    homeDirectory = lib.mkDefault "/Users/greymatter";
    stateVersion = "24.05"; # Please read the comment before changing.

    # Makes sense for user specific applications that shouldn't be available system-wide
    packages = with pkgs; [
      # alacritty # https://www.youtube.com/watch?v=uOnL4fEnldA
      # kitty
      # wezterm
      ghostty-bin # Binary distribution for macOS
    ];

    # Home Manager is pretty good at managing dotfiles. The primary way to manage
    # plain files is through 'home.file'.
    # file = {
    #   ".config/starship/config.toml".source = "/Users/greymatter/dotfiles/starship/starship.toml";
    # };

    # sessionVariables = {
    #   ZDOTDIR = "/Users/greymatter/.config/zsh";
    #   STARSHIP_CONFIG = "/Users/greymatter/.config/starship/config.toml";
    # };
  };
  # programs = {
  # };
}
