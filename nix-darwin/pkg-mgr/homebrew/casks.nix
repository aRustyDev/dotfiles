{
  config,
  lib,
  pkgs,
  dotfilesPath,
  ...
}: {
    homebrew = {
        enable = true;
        global.autoUpdate = true; # "false" for declarative || "true" for 'homebrew' manageable.
        casks = [
            # always upgrade auto-updated or unversioned cask to latest version even if already installed
            # NOTE: The casks here should be things that need to be updated regularly or easily
            "zen-browser"
            "orbstack"
            "1password-cli@beta"
            "1password@nightly"
        ];
    };
}