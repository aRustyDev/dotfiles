# User configuration for asmith (Cisco)
{
  lib,
  pkgs,
  config,
  dotfilesPath,
  ...
}: {
  imports = [../../pkg-mgr/homebrew/casks.nix];

  home = {

    # AWS-specific PATH configuration
    sessionVariables = {
      # Set AWS-specific paths
      AWS_CONFIG_FILE = "${config.home.homeDirectory}/.local/config/aws/credentials";
      AWS_SHARED_CREDENTIALS_FILE = "${config.home.homeDirectory}/.local/config/aws/config";

      # Note: PATH is managed by .zshrc to ensure proper ordering
      # Any special PATH requirements should be added to .zshrc
    };

    # Additional AWS-specific packages
    packages = with pkgs; [
      # Add any AWS-specific tools here
    ];

    homebrew = {
        casks = [];
    };

    # AWS-specific dotfiles
    file = {
      ".config/aws/config".source = "${dotfilesPath}/aws/config";
    };
  };
}
