# User configuration for asmith (Cisco)
{
  lib,
  pkgs,
  config,
  dotfilesPath,
  ...
}: {
  home = {

    # User-specific PATH configuration
    sessionVariables = {
      # Set user-specific paths
      TENV_ROOT = "${config.home.homeDirectory}/.local/pkg/tenv";
      TF_PLUGIN_CACHE_DIR = "${config.home.homeDirectory}/.local/pkg/terraform/plugins";

      # Note: PATH is managed by .zshrc to ensure proper ordering
      # Any special PATH requirements should be added to .zshrc
    };

    # Tenv setup activation
    activation.setupTenv = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [[ ! -d "$HOME/.local/pkg/tenv" ]] || [[ -z "$(ls -A $HOME/.local/pkg/tenv 2>/dev/null)" ]]; then
        echo "Setting up Tenv managed 'terraform' for first time..."
        tenv tf install latest
        echo "Setting up Tenv managed 'terragrunt' for first time..."
        tenv tg install latest
        echo "Setting up Tenv managed 'OpenTofu' for first time..."
        tenv tofu install latest
      else

      fi
    '';
  };
}
