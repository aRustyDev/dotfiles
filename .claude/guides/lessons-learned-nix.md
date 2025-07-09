# Lessons Learned: Nix Development on macOS

This document captures real-world experiences and solutions encountered while working with Nix-Darwin configurations.

## PATH Configuration Issues

### The Problem
- `darwin-rebuild` command not found after installation
- PATH being overridden by nix-darwin configurations
- Commands installed by Nix not accessible

### Root Cause
The use of `lib.mkForce` in PATH configuration prevents proper PATH merging:
```nix
# Bad - This overrides everything
home.sessionVariables.PATH = lib.mkForce "/some/paths";
```

### The Solution
1. Remove all `mkForce` from PATH configurations
2. Use `home.sessionPath` for adding paths
3. Let `.zshrc` handle final PATH ordering

```nix
# Good - Allows merging
home.sessionPath = [ "$HOME/.local/bin" ];
```

In `.zshrc`:
```bash
# Initialize path array from current PATH
path=(${(s/:/)PATH})

# Ensure darwin-rebuild is accessible
if [[ -d /run/current-system/sw/bin ]]; then
    path=('/run/current-system/sw/bin' $path)
fi
```

### Key Learning
User shell configuration should have final control over PATH ordering. Nix should provide paths but not force ordering.

## Pre-commit Hook Failures

### Common Issues Encountered

1. **Nix Formatting**
   - alejandra auto-formats Nix files
   - Let it run and accept changes

2. **Repeated Attribute Keys**
   ```nix
   # Bad - causes "repeated attribute" error
   home = { packages = [...]; };
   home = { file = {...}; };

   # Good - single attribute
   home = {
     packages = [...];
     file = {...};
   };
   ```

3. **Broken Markdown Links**
   - Update paths after moving files
   - Use relative paths consistently

### Best Practice
Always run `git add -A` after pre-commit fixes to stage formatter changes.

## Module Development Insights

### File Management
When installing files to user home:
```nix
# For simple files
home.file.".config/app/config".text = "content";

# For complex installations with metadata
home.file = lib.mkMerge ([
  { ".base/dir/.keep".text = ""; }
] ++ lib.flatten (
  lib.mapAttrsToList (name: cfg:
    # Generate file entries dynamically
  ) config.items
));
```

### Conditional Configuration
Use `lib.mkIf` extensively:
```nix
config = lib.mkIf config.programs.myProgram.enable {
  # Only applied when enabled
};
```

### Secret Management
Never put secrets in Nix:
```nix
# Bad
password = "secret123";

# Good
secretEnv = {
  PASSWORD = "op://vault/item/field";
};
```

Then use `op run` in wrapper scripts.

## Building Custom Packages

### Caching Strategy
For source builds that shouldn't rebuild unnecessarily:
```nix
let
  sourceHash = builtins.hashString "sha256" src.path;
in
  pkgs.stdenv.mkDerivation {
    # ...
    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = sourceHash;
  };
```

### Multi-Runtime Support
Pattern for supporting different runtimes:
```nix
defaultBuildPhase = {
  node = "npm ci && npm run build";
  go = "go build -o ${name}";
  python = "pip install -r requirements.txt";
}.${runtime} or "";
```

## Debugging Techniques

### Finding Issues
1. Use `--show-trace` liberally:
   ```bash
   darwin-rebuild build --flake . --show-trace
   ```

2. Check generated files:
   ```bash
   cat result/etc/bashrc
   ```

3. Use Nix REPL:
   ```bash
   nix repl
   :lf .  # Load flake
   ```

### Common Error Messages

**"attribute missing"**
- Check flake outputs structure
- Verify system name matches

**"infinite recursion"**
- Don't reference config values in their own definition
- Use `mkDefault` instead of direct assignment

**"hash mismatch"**
- Use `lib.fakeSha256` first
- Copy actual hash from error
- Replace fake hash

## Repository Organization

### Effective Structure
```
nix-darwin/
├── flake.nix          # Entry point
├── hosts/
│   ├── base.nix       # Shared config
│   └── users/*.nix    # User configs
└── modules/           # Custom modules
```

### Module Best Practices
1. Each module should be self-contained
2. Use options for configuration
3. Provide sensible defaults
4. Document with descriptions

## Performance Optimization

### Build Time
- Pin nixpkgs version in flake.lock
- Separate frequently changing configs
- Use binary cache when possible

### Evaluation Time
- Avoid complex computations in Nix
- Use `let` bindings for repeated values
- Minimize imports

## Platform Considerations

### macOS Specifics
- Always use `--impure` flag
- Some Linux packages won't work
- Use `stdenv.isDarwin` for conditionals
- Understand launchd vs systemd differences

### Cross-Platform Modules
```nix
config = lib.mkMerge [
  (lib.mkIf stdenv.isDarwin {
    # macOS-specific
  })
  (lib.mkIf stdenv.isLinux {
    # Linux-specific
  })
];
```

## Testing Strategies

### Incremental Testing
1. Build without switching:
   ```bash
   darwin-rebuild build --flake .
   ```

2. Check specific attributes:
   ```bash
   nix eval .#darwinConfigurations.hostname.config.some.option
   ```

3. Test in minimal config first

### Rollback Safety
- Know your generation number
- Can always rollback:
  ```bash
  darwin-rebuild --rollback
  ```

## Key Takeaways

1. **Start Simple**: Get basic config working before adding complexity
2. **Read Errors Carefully**: Nix errors are usually descriptive
3. **Use Version Control**: Commit working states frequently
4. **Document Everything**: Future you will thank present you
5. **Test Incrementally**: Don't change everything at once
6. **Understand the Tools**: Learn what Nix is actually doing

## Common Gotchas

1. **Import Paths**: Must be relative or absolute, not dynamic
2. **String Interpolation**: Use `${}` in Nix, not `$()`
3. **Attribute Names**: Can't start with numbers, use quotes if needed
4. **List Concatenation**: Use `++`, not `+`
5. **Boolean Logic**: `&&` is not valid, use function composition

## Resources for Deep Dives

- Nix Pills: Understand fundamentals
- nix.dev: Modern practices
- GitHub nixpkgs: Learn from examples
- Discord/Matrix: Active community help
