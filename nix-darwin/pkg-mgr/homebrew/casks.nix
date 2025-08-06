{
  config,
  lib,
  pkgs,
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

            # "act"
            # "act_runner"
            # "action-docs"
            # "action-validator"
            # "actionlint"

            # benerator # Test Data Generation

            # "attr"
            # "aws-keychain"
            # "awslogs"
            # "azure-cli"
            # "azqr"
            # "authz0"
            # "bingrep"
            # "bpftop"
            # "brook" # Custom Proxy tool
            # "buffrs" pkg mgr for Protobuff

            # "bashdb"
            # "bashate"
            # "bashunit"
            # "bagels" # CLI Expense Tracker
            # "backlog-md" # CLI Backlog tracker

            # "bazel"
            # "bazel-diff"
            # "bazel-remote"

            # "assh"
            # "asroute"
            # "asnmap"
            # "asn"

            # "asitop"
            # "asimov"
            # "asciitex" # Generate ASCII-art representations of mathematical equations
            # "aamath" # Generate ASCII-art representations of mathematical equations
            # "asciinema"
            # "api-linter"
            # "apgdiff"
            # "antlr"
            # "antigen" # "antidote" ZSH Plugin Managers

            # "ansible"
            # "analog"
            # "alp"
            # "alloy-analyzer"
            # "alive2"
            # "ali"
            # "aliae"
            # "alejandra" # Nix fmt
            # "align"
            # "ahoy" # Self Documenting CLI
            # "aggregate"
            # "age"
            # "age-plugin-se"
            # "age-plugin-yubikey"
            # "afsctool"
            # "afl++"
            # "aespipe"
            # "aescrypt"
            # "adr-viewer"
            # "adr-tools"
            # "acl"
            # "ack"
            # "aarch64-elf-binutils"
            # "aarch64-elf-gcc"
            # "aarch64-elf-gdb"
        ];
    };
}
