# Nix-Darwin Configuration Patterns

## Common Patterns and Best Practices

### Module Structure

Standard Nix-Darwin module pattern:
```nix
{ config, lib, pkgs, ... }:
{
  options = {
    programs.myTool.enable = lib.mkEnableOption "my tool";
  };

  config = lib.mkIf config.programs.myTool.enable {
    # Implementation
  };
}
```

### Package Management

#### System Packages (nix-darwin)
```nix
environment.systemPackages = with pkgs; [
  git
  vim
];
```

#### User Packages (Home Manager)
```nix
home.packages = with pkgs; [
  ripgrep
  jq
];
```

### Environment Variables

#### System-wide
```nix
environment.variables = {
  EDITOR = "nvim";
};
```

#### User-specific
```nix
home.sessionVariables = {
  CUSTOM_VAR = "value";
};
```

### Path Management

#### Avoiding mkForce
- **Problem**: `lib.mkForce` prevents proper PATH merging
- **Solution**: Let .zshrc handle final PATH configuration
- **Pattern**: Remove mkForce, use sessionPath instead

```nix
# Bad - prevents merging
home.sessionVariables.PATH = lib.mkForce "...";

# Good - allows proper merging
home.sessionPath = [ "$HOME/.local/bin" ];
```

### File Management

#### Static Files
```nix
home.file.".config/app/config".source = ./config;
```

#### Generated Files
```nix
home.file.".config/app/config".text = ''
  setting = value
'';
```

#### Executable Scripts
```nix
home.file.".local/bin/script" = {
  executable = true;
  text = ''
    #!/usr/bin/env bash
    echo "Hello"
  '';
};
```

### Activation Scripts

For tasks that need to run after configuration:
```nix
home.activation.myTask = lib.hm.dag.entryAfter ["writeBoundary"] ''
  echo "Running post-activation task"
'';
```

### Conditional Configuration

```nix
config = lib.mkIf (condition) {
  # Only applied if condition is true
};

# Multiple conditions
config = lib.mkMerge [
  (lib.mkIf condition1 { ... })
  (lib.mkIf condition2 { ... })
];
```

### Shell Integration

#### Aliases
```nix
home.shellAliases = {
  ll = "ls -l";
  gs = "git status";
};
```

#### Shell-specific Config
```nix
programs.zsh = {
  enable = true;
  initExtra = ''
    # Custom zsh configuration
  '';
};
```

### Program Configuration

Pattern for configuring programs:
```nix
programs.git = {
  enable = true;
  userName = "John Doe";
  userEmail = "john@example.com";
  extraConfig = {
    push.autoSetupRemote = true;
  };
};
```

## Anti-patterns to Avoid

1. **Using mkForce unnecessarily** - Prevents configuration merging
2. **Hardcoding paths** - Use variables like `config.home.homeDirectory`
3. **Storing secrets in Nix** - Use 1Password or other secret managers
4. **Complex logic in Nix** - Keep it declarative, use scripts for logic
5. **Not using `lib.optional`** - For conditional list items

## Useful Functions

- `lib.mkEnableOption`: Create boolean options
- `lib.mkOption`: Create custom options
- `lib.mkIf`: Conditional configuration
- `lib.mkMerge`: Merge multiple configurations
- `lib.optional`: Conditionally include list items
- `lib.optionals`: Multiple conditional items
- `lib.optionalString`: Conditional strings
- `lib.concatStringsSep`: Join strings with separator
