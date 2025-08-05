# Golang configuration
{
  lib,
  pkgs,
  config,
  dotfilesPath,
  ...
}: {
  imports = [../base.nix];

  home = {

    # User-specific PATH configuration
    sessionVariables = {
      GOPATH = "${config.home.homeDirectory}/.local/lib/go";

      # Note: PATH is managed by .zshrc to ensure proper ordering
      # Any special PATH requirements should be added to .zshrc
    };

    # # Rust setup activation
    # activation.setupRust = lib.hm.dag.entryAfter ["writeBoundary"] ''
    #   if [[ ! -d "$RUSTUP_HOME/toolchains" ]] || [[ -z "$(ls -A $RUSTUP_HOME/toolchains 2>/dev/null)" ]]; then
    #     echo "Setting up Rust toolchain for first time..."
    #     $DRY_RUN_CMD ${pkgs.rustup}/bin/rustup toolchain install stable --component cargo rust-docs rustfmt clippy rust-analyzer llvm-tools
    #     $DRY_RUN_CMD ${pkgs.rustup}/bin/rustup toolchain install beta --component cargo rust-docs rustfmt clippy rust-analyzer llvm-tools
    #     $DRY_RUN_CMD ${pkgs.rustup}/bin/rustup toolchain install nightly --component cargo rust-docs rustfmt clippy rust-analyzer llvm-tools miri rust-std rustc
    #     $DRY_RUN_CMD ${pkgs.rustup}/bin/rustup default nightly
    #   fi
    # '';
  };
}
