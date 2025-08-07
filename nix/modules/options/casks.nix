{ lib, ... }:
{
  options.casks = { # <--- MODIFIED: Directly define 'casks' as an attribute set
    user = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "List of user-specific Homebrew casks to install.";
      default = [];
    };

    common = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "List of common Homebrew casks to install across users/machines.";
      default = [];
    };

    all = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "Combined list of all Homebrew casks (user + common).";
      default = [];
      readOnly = true; # This option is derived, not set directly
    };
  };
}
