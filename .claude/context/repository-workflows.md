# Repository Workflows and Procedures

## Daily Development Workflow

### Making Configuration Changes

1. **Edit Configuration**
   ```bash
   cd ~/dotfiles
   $EDITOR nix-darwin/hosts/users/personal.nix
   ```

2. **Test Build**
   ```bash
   darwin-rebuild build --flake ./nix-darwin --impure
   ```

3. **Apply Changes**
   ```bash
   sudo darwin-rebuild switch --flake ./nix-darwin --impure
   ```

4. **Commit Changes**
   ```bash
   git add -A
   git commit -m "feat(nix): add new package configuration"
   ```

### Adding New Software

#### Via Nix Package
1. Search for package:
   ```bash
   nix search nixpkgs <package-name>
   ```

2. Add to configuration:
   ```nix
   home.packages = with pkgs; [
     existing-package
     new-package  # Added
   ];
   ```

3. Apply and test

#### Via Custom Module
1. Create module in `nix-darwin/modules/`
2. Import in `base.nix`
3. Configure in user file
4. Test thoroughly

### Working with MCP Servers

1. **Add Server Configuration**
   ```nix
   programs.mcpServers.servers.myserver = {
     enable = true;
     type = "docker";
     src = "image:tag";
   };
   ```

2. **Build and Install**
   ```bash
   darwin-rebuild switch --flake ./nix-darwin --impure
   ```

3. **Verify Installation**
   ```bash
   mcp-manage list
   mcp-test test myserver
   ```

4. **Export Docker Images** (if needed)
   ```bash
   mcp-manage export-docker myserver
   ```

## Git Workflow

### Commit Conventions

Follow conventional commits:
- `feat:` New features
- `fix:` Bug fixes
- `docs:` Documentation changes
- `refactor:` Code refactoring
- `chore:` Maintenance tasks
- `test:` Test additions/changes

### Branch Strategy

```bash
# Feature development
git checkout -b feature/add-new-tool

# Bug fixes
git checkout -b fix/path-configuration

# Documentation
git checkout -b docs/update-readme
```

### Pre-commit Hooks

The repository uses pre-commit hooks for:
- Nix formatting (alejandra)
- Markdown linting
- File organization

If a commit fails:
1. Let formatters fix issues
2. Review changes
3. Re-add and commit

## Maintenance Tasks

### Regular Updates

```bash
# Update flake inputs
cd ~/dotfiles/nix-darwin
nix flake update

# Test updates
darwin-rebuild build --flake . --impure

# Apply if successful
sudo darwin-rebuild switch --flake . --impure
```

### Cleanup

```bash
# Remove old generations
sudo nix-collect-garbage -d

# Clean MCP docker exports
mcp-manage cleanup

# Remove unused packages
nix-store --gc
```

### Backup Procedures

1. **Configuration Backup**
   - Git push to remote
   - Tag stable versions

2. **State Backup**
   ```bash
   # Backup current generation
   darwin-rebuild list-generations
   ```

## Troubleshooting Workflow

### When Things Break

1. **Check Recent Changes**
   ```bash
   git log --oneline -10
   git diff HEAD~1
   ```

2. **Rollback if Needed**
   ```bash
   # Rollback to previous generation
   darwin-rebuild --rollback

   # Or specific generation
   darwin-rebuild switch --switch-generation N
   ```

3. **Debug Build**
   ```bash
   darwin-rebuild build --flake . --show-trace -v
   ```

4. **Test Minimal Config**
   - Comment out recent additions
   - Build incrementally
   - Identify problematic change

## Documentation Updates

### When to Update Docs

- After adding new modules
- When changing workflows
- After solving complex issues
- When patterns emerge

### Documentation Structure

1. **Context files** (`.claude/context/`): System state and configuration
2. **Guides** (`.claude/guides/`): How-to and learning resources
3. **Module docs**: In-line documentation in Nix files
4. **README files**: User-facing documentation

### Keeping Docs Current

```bash
# After major changes
$EDITOR .claude/index.md  # Update index
$EDITOR .claude/context/  # Update relevant context
git add .claude/
git commit -m "docs: update configuration context"
```

## Security Procedures

### Secret Rotation

1. Update in 1Password
2. Update references in Nix configs
3. Test affected services
4. Document in security log

### Audit Checklist

- [ ] No secrets in Nix files
- [ ] No secrets in git history
- [ ] 1Password references valid
- [ ] Permissions appropriate
- [ ] No unnecessary exposure

## Multi-Machine Management

### Adding New Machine

1. Create machine configuration:
   ```bash
   cp nix-darwin/hosts/users/personal.nix \
      nix-darwin/hosts/users/newmachine.nix
   ```

2. Add to flake.nix:
   ```nix
   darwinConfigurations."NewMachine" = darwin.lib.darwinSystem {
     # ...
   };
   ```

3. Customize configuration
4. Build and test on target machine

### Syncing Changes

```bash
# On development machine
git push

# On other machines
git pull
sudo darwin-rebuild switch --flake . --impure
```
