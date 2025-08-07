# nix/modules/options/programs.nix
{ config, lib, pkgs, nixpkgs, ... }: # This module needs 'config' to set config.programs.inScope
{
  # 1. Option Definition
  # This declares the 'programs.inScope' option in the global configuration.
  options.programs.inScope = lib.mkOption {
    type = lib.types.listOf lib.types.str; # Use lib.types as lib is passed
    description = "A combined list of all programs to install from various modules.";
    default = []; # Provide a default empty list
    # For lists of strings, the default merge strategy for `lib.types.listOf` is typically concatenation.
    # You generally don't need to specify 'merge' unless you want a different behavior (e.g., unique elements).
  };

  # 2. Config Contribution
  # This module contributes to the 'programs.inScope' option.
  # Assuming config.packages.user, config.packages.common, config.casks.user, and config.casks.common
  # are all lists of strings, you should use list concatenation (++) here.
  # The `lib.mkMerge` function is primarily for merging attribute sets, not concatenating lists.
  config.programs.inScope =
    config.packages.user
    ++ config.packages.common
    ++ config.casks.user
    ++ config.casks.common;
}
