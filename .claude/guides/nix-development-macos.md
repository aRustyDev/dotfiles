# Nix Development Guide for macOS

## Essential Concepts

### Understanding Nix on macOS

Nix-Darwin provides declarative configuration management for macOS, similar to NixOS but adapted for Darwin systems.

Key differences from Linux:
- Uses `darwin-rebuild` instead of `nixos-rebuild`
- System services managed by launchd, not systemd
- Some packages are macOS-specific
- Requires `--impure` flag for system integration

### Basic Workflow

1. **Edit Configuration**
   ```bash
   cd ~/dotfiles/nix-darwin
   $EDITOR hosts/users/personal.nix
   ```

2. **Build Configuration**
   ```bash
   darwin-rebuild build --flake . --impure
   ```

3. **Apply Configuration**
   ```bash
   sudo darwin-rebuild switch --flake . --impure
   ```

### Development Tools

#### Essential Commands

```bash
# Check flake outputs
nix flake show

# Update flake inputs
nix flake update

# Check specific input
nix flake info

# Garbage collection
nix-collect-garbage -d

# Search packages
nix search nixpkgs package-name
```

#### Nix REPL for Testing

```bash
$ nix repl
nix-repl> :lf .  # Load current flake
nix-repl> inputs.nixpkgs.legacyPackages.aarch64-darwin.hello
nix-repl> :b outputs.darwinConfigurations.MacBook-Pro.system
```

### Writing Nix Modules

#### Module Template

```nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.myProgram;
in
{
  options.programs.myProgram = {
    enable = mkEnableOption "my program";

    package = mkOption {
      type = types.package;
      default = pkgs.myProgram;
      description = "Package to use";
    };

    settings = mkOption {
      type = types.attrs;
      default = {};
      description = "Configuration settings";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    home.file.".config/myprogram/config.json".text =
      builtins.toJSON cfg.settings;
  };
}
```

#### Best Practices

1. **Use `let` bindings** for repeated expressions
2. **Prefer `mkOption` over hardcoding** for flexibility
3. **Add descriptions** to all options
4. **Use appropriate types** for type checking
5. **Make modules composable** with `mkIf`

### Building Packages

#### Simple Package

```nix
pkgs.stdenv.mkDerivation rec {
  pname = "my-tool";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "owner";
    repo = "repo";
    rev = "v${version}";
    sha256 = "...";
  };

  buildInputs = with pkgs; [ ];

  installPhase = ''
    mkdir -p $out/bin
    cp my-tool $out/bin/
  '';
}
```

#### Script Package

```nix
pkgs.writeScriptBin "my-script" ''
  #!/usr/bin/env bash
  echo "Hello from Nix!"
''
```

### Debugging Techniques

#### 1. Build Verbosity

```bash
# Increase verbosity
darwin-rebuild switch --flake . --impure --show-trace -v

# Maximum verbosity
darwin-rebuild switch --flake . --impure --show-trace -vvv
```

#### 2. Debugging Expressions

```nix
# Trace values
let
  myValue = lib.debug.traceVal "Debug:" someExpression;
in
  myValue

# Conditional debugging
let
  debug = msg: val: if debugMode then lib.debug.trace msg val else val;
in
  debug "Processing:" value
```

#### 3. Testing Modules

```nix
# In flake.nix, add test configuration
darwinConfigurations.test = darwin.lib.darwinSystem {
  system = "aarch64-darwin";
  modules = [
    ./test-configuration.nix
  ];
};
```

### Common Patterns

#### Platform Detection

```nix
{
  config = lib.mkMerge [
    (lib.mkIf pkgs.stdenv.isDarwin {
      # macOS-specific config
    })
    (lib.mkIf pkgs.stdenv.isLinux {
      # Linux-specific config
    })
  ];
}
```

#### Optional Dependencies

```nix
buildInputs = with pkgs; [
  required-dep
] ++ lib.optional stdenv.isDarwin darwin.apple_sdk.frameworks.Security
  ++ lib.optional enableFeature optional-dep;
```

#### Dynamic Attribute Sets

```nix
# Generate multiple similar items
lib.genAttrs [ "foo" "bar" "baz" ] (name: {
  "${name}-config" = true;
})
```

### Performance Tips

1. **Use Binary Cache**
   ```bash
   # Check if using cache
   nix show-config | grep substituters
   ```

2. **Optimize Builds**
   - Use `--max-jobs` for parallel builds
   - Enable `sandbox = true` in nix.conf
   - Use remote builders for heavy compilations

3. **Minimize Rebuilds**
   - Pin nixpkgs version in flake.lock
   - Use specific package versions
   - Separate frequently changing configs

### Security Considerations

1. **Never Store Secrets in Nix Store**
   - Use agenix or sops-nix
   - Integrate with 1Password CLI
   - Use environment variables at runtime

2. **Validate Inputs**
   ```nix
   assertion = cfg.port >= 1024;
   message = "Port must be >= 1024";
   ```

3. **Review Dependencies**
   - Check package sources
   - Verify SHA256 hashes
   - Use official nixpkgs when possible

### Testing Strategies

#### Unit Testing Nix

```nix
# tests/default.nix
{ pkgs ? import <nixpkgs> {} }:

pkgs.lib.runTests {
  testSimple = {
    expr = 1 + 1;
    expected = 2;
  };

  testModule = {
    expr = (import ./module.nix { inherit pkgs; }).someFunction "input";
    expected = "output";
  };
}
```

#### Integration Testing

```bash
# Test in isolated environment
nix build .#darwinConfigurations.test.system
./result/sw/bin/darwin-rebuild check
```

### Advanced Topics

#### Overlays

```nix
# In flake.nix
overlays = [
  (final: prev: {
    myPackage = prev.myPackage.overrideAttrs (old: {
      version = "custom";
    });
  })
];
```

#### Custom Builders

```nix
mkMyDerivation = { name, ... }@args:
  pkgs.stdenv.mkDerivation (args // {
    builder = ./my-builder.sh;
    inherit name;
  });
```

#### Flake Templates

```nix
templates = {
  default = {
    path = ./template;
    description = "My project template";
  };
};
```

## Resources

- [Nix Pills](https://nixos.org/guides/nix-pills/) - Fundamentals
- [nix.dev](https://nix.dev/) - Modern documentation
- [Nix Darwin Manual](https://daiderd.com/nix-darwin/manual/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
