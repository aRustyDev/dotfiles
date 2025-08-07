# User configuration for asmith (Cisco)
{
  lib,
  pkgs,
  config,
  dotfilesPath,
  ...
}: {
  imports = [
    ("${config.dot.nix.mods}" + /hosts/base.nix)
    ("${config.dot.nix.dots}" + /zsh/config.nix)
  ];

  home = {
    username = config.dot.user.name;
    homeDirectory = config.dot.user.home;

    # User-specific PATH configuration
    sessionVariables = {
      # Set user-specific paths

      # Note: PATH is managed by .zshrc to ensure proper ordering
      # Any special PATH requirements should be added to .zshrc
    };

    # Additional Cisco/work-specific packages
    packages = with pkgs; [
      # Add any work-specific tools here
      # For example: corporate VPN clients, work-specific CLI tools, etc.
    ];

    # Cisco-specific dotfiles
    file = {
      ".config/ssh/config".source = "${config.dot.nix.dir}/ssh/config/cisco.merged";
      ".config/ssh/gitlab.pub".source = "${config.dot.nix.dir}/ssh/pubs/cisco.gitlab";
    };
  };
}
