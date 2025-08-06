# User configuration for asmith (Cisco)
{
  lib,
  pkgs,
  config,
  dotfilesPath,
  ...
}: {
  imports = [
    ../../base.nix
  ];

  home = {
    username = "adamsm";
    homeDirectory = "/Users/adamsm";

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
      ".config/ssh/config".source = "${dotfilesPath}/ssh/config/cisco";
      ".config/ssh/gitlab.pub".source = "${dotfilesPath}/ssh/pubs/cisco.gitlab";
    };
  };
}
