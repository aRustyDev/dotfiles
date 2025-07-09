# Nix Troubleshooting Guide for macOS

## Common Issues and Solutions

### 1. Command Not Found After Installation

**Problem**: Installed a package but command not available
```bash
sudo darwin-rebuild switch --flake ~/dotfiles/nix-darwin --impure
# But: command not found
```

**Solutions**:
1. Check PATH configuration:
   ```bash
   echo $PATH
   which <command>
   ```

2. Ensure `/run/current-system/sw/bin` is in PATH:
   ```bash
   # In .zshrc
   path=('/run/current-system/sw/bin' $path)
   ```

3. For user packages, check Home Manager PATH:
   ```bash
   ls ~/.nix-profile/bin/
   ```

### 2. PATH Being Overridden

**Problem**: PATH set in Nix config but not working

**Root Cause**: `lib.mkForce` prevents PATH merging

**Solution**:
```nix
# Remove this:
home.sessionVariables.PATH = lib.mkForce "...";

# Use this instead:
home.sessionPath = [ "$HOME/.local/bin" ];
```

### 3. Pre-commit Hook Failures

**Problem**: Commits fail due to formatting or linting

**Common Errors**:
- Nix formatting issues
- Broken markdown links
- Repeated attribute keys

**Solutions**:
1. Let alejandra format Nix files:
   ```bash
   alejandra .
   ```

2. Fix repeated attributes:
   ```nix
   # Bad - repeated 'home' key
   home = { packages = [...]; };
   home = { file = {...}; };

   # Good - single 'home' key
   home = {
     packages = [...];
     file = {...};
   };
   ```

3. Update markdown links after moving files

### 4. Flake Build Errors

**Problem**: `error: attribute 'xxx' missing`

**Debugging Steps**:
1. Check flake outputs:
   ```bash
   nix flake show ./nix-darwin
   ```

2. Verify attribute path:
   ```bash
   nix build ./nix-darwin#darwinConfigurations.hostname.system
   ```

3. Use `--show-trace` for details:
   ```bash
   darwin-rebuild build --flake ./nix-darwin --show-trace
   ```

### 5. SHA256 Mismatch

**Problem**: `error: hash mismatch in fixed-output derivation`

**Solution**:
1. Use `lib.fakeSha256` initially
2. Build and get actual hash from error
3. Replace with correct hash:
   ```nix
   sha256 = "actual-hash-from-error";
   ```

### 6. Module Import Issues

**Problem**: Module not found or not working

**Checklist**:
1. Correct import path:
   ```nix
   imports = [ ../modules/my-module.nix ];
   ```

2. Module has correct structure:
   ```nix
   { config, lib, pkgs, ... }: {
     # options and config
   }
   ```

3. Check for circular imports

### 7. Home Manager Activation Failures

**Problem**: Activation script fails

**Debugging**:
```bash
# See what will be activated
home-manager build --flake .#username

# Check activation script
cat result/activate
```

**Common Fixes**:
- Ensure directories exist before writing files
- Use `lib.hm.dag.entryAfter` for proper ordering
- Check file permissions

### 8. Secret Management Issues

**Problem**: Secrets exposed in Nix store

**Solution**: Never put secrets directly in Nix
```nix
# Bad
password = "secret123";

# Good - use 1Password
secretEnv = {
  PASSWORD = "op://vault/item/field";
};
```

### 9. Platform-Specific Issues

**Problem**: Linux-specific packages on macOS

**Solution**: Use platform conditionals
```nix
home.packages = with pkgs; [
  vim
] ++ lib.optionals stdenv.isLinux [
  linux-only-package
] ++ lib.optionals stdenv.isDarwin [
  darwin-only-package
];
```

### 10. Debugging Techniques

#### Check Current Configuration
```bash
# View generated configuration
darwin-rebuild build --flake . --show-trace
cat result/etc/bashrc  # or other generated files
```

#### Nix REPL
```bash
nix repl
:lf ./nix-darwin  # Load flake
# Explore configuration
```

#### Trace Function Calls
```nix
let
  debug = lib.debug.traceVal;
in {
  someValue = debug "This will print" actualValue;
}
```

#### Build Single Derivation
```bash
nix build .#packages.x86_64-darwin.myPackage
```

## Prevention Tips

1. **Test in VM/Container**: Before applying system-wide
2. **Use Version Control**: Commit working configurations
3. **Incremental Changes**: Small changes, test frequently
4. **Read Error Messages**: Nix errors are usually descriptive
5. **Keep Flake Updated**: `nix flake update` regularly
6. **Document Changes**: Comment why, not what
