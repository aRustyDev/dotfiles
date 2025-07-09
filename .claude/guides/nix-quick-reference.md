# Nix Quick Reference for macOS

## Essential Commands

### Daily Operations
```bash
# Build and switch configuration
sudo darwin-rebuild switch --flake ~/dotfiles/nix-darwin --impure

# Build only (test changes)
darwin-rebuild build --flake ~/dotfiles/nix-darwin --impure

# Update flake inputs
nix flake update

# Garbage collection
nix-collect-garbage -d

# List generations
darwin-rebuild --list-generations

# Rollback
darwin-rebuild --rollback
```

### Package Management
```bash
# Search packages
nix search nixpkgs <package>

# Try package temporarily
nix shell nixpkgs#<package>

# Show package info
nix eval nixpkgs#<package>.meta.description
```

### Debugging
```bash
# Build with trace
darwin-rebuild build --flake . --impure --show-trace

# Nix REPL
nix repl
:lf .                    # Load current flake
:b <expression>          # Build expression
:p <expression>          # Print value

# Check flake
nix flake check
nix flake show

# Evaluate option
nix eval .#darwinConfigurations.hostname.config.option.path
```

## Common Nix Patterns

### Package Lists
```nix
# With conditions
home.packages = with pkgs; [
  git
  vim
] ++ lib.optional stdenv.isDarwin darwin-specific-pkg
  ++ lib.optionals enableDev [ gcc make ];
```

### File Management
```nix
# Static file
home.file.".config/app/config".source = ./config;

# Generated file
home.file.".config/app/config".text = ''
  setting = value
'';

# Executable
home.file.".local/bin/script" = {
  executable = true;
  text = ''#!/usr/bin/env bash
    echo "Hello"
  '';
};
```

### Environment Variables
```nix
# System-wide
environment.variables = {
  EDITOR = "nvim";
};

# User-specific
home.sessionVariables = {
  MY_VAR = "value";
};

# PATH additions
home.sessionPath = [
  "$HOME/.local/bin"
];
```

### Conditionals
```nix
# Simple condition
config = lib.mkIf config.programs.foo.enable {
  # ...
};

# Multiple conditions
config = lib.mkMerge [
  (lib.mkIf condition1 { })
  (lib.mkIf condition2 { })
];

# Platform specific
lib.mkIf pkgs.stdenv.isDarwin { }
lib.mkIf pkgs.stdenv.isLinux { }
```

## Module Template
```nix
{ config, lib, pkgs, ... }:

let
  cfg = config.programs.myProgram;
in
{
  options.programs.myProgram = {
    enable = lib.mkEnableOption "my program";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.myProgram;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
```

## Useful Functions

### List Operations
```nix
lib.optional condition item              # Add item if true
lib.optionals condition [ items ]        # Add items if true
lib.flatten [ [ a ] [ b ] ]             # Flatten nested lists
lib.unique [ a b a ]                    # Remove duplicates
lib.filter (x: x > 5) list              # Filter list
```

### String Operations
```nix
lib.concatStringsSep "," [ "a" "b" ]    # Join with separator
lib.optionalString condition "text"      # String if true
lib.strings.hasPrefix "pre" "prefix"    # Check prefix
lib.replaceStrings ["a"] ["b"] "abc"    # Replace in string
```

### Attribute Set Operations
```nix
lib.mapAttrs (k: v: v + 1) attrs        # Transform values
lib.filterAttrs (k: v: v > 0) attrs     # Filter attributes
lib.mapAttrsToList (k: v: "${k}=${v}")  # Convert to list
lib.mkMerge [ attrs1 attrs2 ]           # Merge sets
```

### Assertions
```nix
assertions = [{
  assertion = cfg.value > 0;
  message = "Value must be positive";
}];
```

## File Paths
```nix
# Relative to file
./config.json

# Home directory
config.home.homeDirectory

# Package output
"${pkgs.myapp}/share/file"

# String interpolation
"${config.home.homeDirectory}/.config"
```

## Common Type Definitions
```nix
types.str                  # String
types.int                  # Integer
types.bool                 # Boolean
types.path                 # File path
types.package              # Nix package
types.listOf types.str     # List of strings
types.attrsOf types.int    # Set of integers
types.nullOr types.str     # Nullable string
types.enum ["a" "b"]       # One of values
types.submodule { }        # Nested module
```

## Error Fixes

### "undefined variable"
- Import needed: `with pkgs;` or `pkgs.thing`
- Check spelling

### "attribute missing"
- Check path: `config.programs.thing.enable`
- May need different attribute path

### "infinite recursion"
- Don't use `config.x = config.x + 1`
- Use `mkDefault` or `mkForce`

### "repeated attribute"
- Combine into single attribute set
- Use `//` to merge sets

## Tips & Tricks

1. **Test in REPL first**
   ```bash
   nix repl
   :l <nixpkgs>
   ```

2. **Use `--dry-run`**
   ```bash
   darwin-rebuild dry-run
   ```

3. **Pin nixpkgs**
   ```nix
   inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-23.11-darwin";
   ```

4. **Override packages**
   ```nix
   package = pkgs.hello.overrideAttrs (old: {
     version = "custom";
   });
   ```

5. **Debug with trace**
   ```nix
   value = lib.trace "Debug: ${toString x}" x;
   ```
