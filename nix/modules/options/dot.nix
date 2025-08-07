# nix/modules/options/dot.nix
{ lib, ... }:
{
  options.dot = lib.mkOption {
    type = lib.types.attrs;
    description = "Structured paths and configurations for dotfiles.";
    default = {};
    # This `apply` function ensures that when multiple modules define `config.dot`,
    # they are recursively merged. This is the default for attrs, but explicit is good.
    apply = lib.recursiveUpdate;
  };
}
