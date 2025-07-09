# Nix Module Development Guide

## Module Anatomy

### Basic Structure

Every Nix module follows this pattern:

```nix
{ config, lib, pkgs, ... }:  # Function arguments

{
  # 1. Import other modules
  imports = [ ./other-module.nix ];

  # 2. Define options
  options = { };

  # 3. Define configuration
  config = { };
}
```

### The Module Arguments

- `config`: The entire system configuration
- `lib`: Nix library functions
- `pkgs`: The package set
- `...`: Accept additional arguments

## Creating Options

### Basic Option Types

```nix
options = {
  services.myService = {
    enable = lib.mkEnableOption "my service";

    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Port to listen on";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.myService;
      defaultText = lib.literalExpression "pkgs.myService";
      description = "Package to use";
    };
  };
};
```

### Common Option Types

```nix
# Basic types
type = lib.types.str;           # String
type = lib.types.int;           # Integer
type = lib.types.bool;          # Boolean
type = lib.types.path;          # File path

# Container types
type = lib.types.listOf lib.types.str;        # List of strings
type = lib.types.attrsOf lib.types.int;       # Attribute set
type = lib.types.nullOr lib.types.str;        # Nullable string

# Special types
type = lib.types.package;       # Nix package
type = lib.types.port;          # Port number (0-65535)
type = lib.types.enum ["a" "b" "c"];  # Enumeration

# Submodules
type = lib.types.submodule {
  options = {
    name = lib.mkOption { type = lib.types.str; };
    value = lib.mkOption { type = lib.types.int; };
  };
};
```

## Implementation Patterns

### Conditional Configuration

```nix
config = lib.mkIf config.services.myService.enable {
  # Only applied when enabled
  systemd.services.myService = {
    description = "My Service";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${cfg.package}/bin/myservice -p ${toString cfg.port}";
    };
  };
};
```

### Merging Configurations

```nix
config = lib.mkMerge [
  # Always applied
  {
    environment.systemPackages = [ pkgs.basic-tool ];
  }

  # Conditionally applied
  (lib.mkIf cfg.enableExtra {
    environment.systemPackages = [ pkgs.extra-tool ];
  })
];
```

### List Manipulation

```nix
# Optional list items
environment.systemPackages = with pkgs; [
  vim
  git
] ++ lib.optional cfg.enableDocker docker
  ++ lib.optionals cfg.enableDevTools [ gcc make cmake ];
```

## Advanced Patterns

### Option Defaults Based on Other Options

```nix
options = {
  services.myApp = {
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/${config.services.myApp.name}";
      defaultText = lib.literalExpression ''"/var/lib/''${config.services.myApp.name}"'';
    };
  };
};
```

### Extensible Option Sets

```nix
options = {
  programs.myProgram.plugins = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule {
      options = {
        enable = lib.mkEnableOption "this plugin";
        config = lib.mkOption {
          type = lib.types.attrs;
          default = {};
        };
      };
    });
    default = {};
  };
};
```

### Module Assertions

```nix
config = {
  assertions = [
    {
      assertion = cfg.port >= 1024 || config.users.users.root.enable;
      message = "Port < 1024 requires root privileges";
    }
  ];
};
```

## Real-World Example: MCP Server Module

```nix
{ config, lib, pkgs, ... }:

let
  cfg = config.programs.mcpServers;

  serverModule = lib.types.submodule {
    options = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };

      type = lib.mkOption {
        type = lib.types.enum [ "binary" "docker" "source" "git" ];
      };

      env = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {};
      };
    };
  };
in
{
  options.programs.mcpServers = {
    enable = lib.mkEnableOption "MCP server management";

    servers = lib.mkOption {
      type = lib.types.attrsOf serverModule;
      default = {};
      description = "MCP servers to manage";
    };
  };

  config = lib.mkIf cfg.enable {
    # Generate a package for each server
    home.packages = lib.flatten (
      lib.mapAttrsToList (name: server:
        lib.optional server.enable (
          pkgs.writeScriptBin "mcp-${name}" ''
            #!/usr/bin/env bash
            echo "Starting ${name} MCP server..."
          ''
        )
      ) cfg.servers
    );
  };
}
```

## Testing Modules

### Interactive Testing

```bash
# Test in REPL
$ nix repl
nix-repl> :l <nixpkgs>
nix-repl> :l ./my-module.nix
nix-repl> config.myOption
```

### Unit Tests

```nix
# test.nix
{ pkgs ? import <nixpkgs> {} }:

let
  eval = pkgs.lib.evalModules {
    modules = [
      ./my-module.nix
      {
        config = {
          programs.myProgram.enable = true;
        };
      }
    ];
  };
in
{
  testEnable = {
    expr = eval.config.programs.myProgram.enable;
    expected = true;
  };
}
```

## Common Pitfalls

### 1. Infinite Recursion

```nix
# Bad - causes infinite recursion
config.foo = config.foo + 1;

# Good - use mkDefault
config.foo = lib.mkDefault 10;
```

### 2. Missing mkIf

```nix
# Bad - always applied
config = {
  services.foo = { };
};

# Good - conditional
config = lib.mkIf cfg.enable {
  services.foo = { };
};
```

### 3. Wrong Option Path

```nix
# Bad - accessing wrong path
cfg = config.services.myService;

# Good - match your option structure
cfg = config.programs.myProgram;
```

## Module Development Workflow

1. **Start Simple**: Basic enable option
2. **Add Options**: Incrementally add configuration
3. **Test Often**: Use `darwin-rebuild build`
4. **Check Types**: Ensure type safety
5. **Document**: Add descriptions to all options
6. **Refactor**: Extract common patterns

## Debugging Tips

```nix
# Debug option values
options.debug = lib.mkOption {
  default = lib.traceVal config.programs.myProgram;
};

# Trace during evaluation
config = lib.trace "Evaluating config" {
  # ...
};

# Conditional debugging
config = lib.mkIf (cfg.enable && cfg.debug) {
  warnings = [ "Debug mode enabled for myProgram" ];
};
```
