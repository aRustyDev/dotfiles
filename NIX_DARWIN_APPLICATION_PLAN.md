# Nix-Darwin Configuration Application Plan

## 🎯 Objective
Apply the nix-darwin configurations from this repository to the system, ensuring a smooth transition with proper backups and rollback capabilities.

## 📊 Current System State
- **Nix**: ✅ Installed (v2.23.1)
- **nix-darwin**: ✅ Installed
- **Current Generation**: `/nix/store/hhi3gfy5d9jlh17xa7v0ga0fszqn62zx-darwin-system-25.11.e04a388`
- **Hostname**: `nw-mbp` (matches configuration)
- **Homebrew**: ❌ Not installed (will need installation if using homebrew features)

## 🛡️ Pre-Application Backup Strategy

### 1. System State Backup
```bash
# Backup current generation reference
echo "Current generation: $(readlink /run/current-system)" > ~/nix-darwin-backup-$(date +%Y%m%d).txt

# List current packages
nix-env -q > ~/nix-packages-backup-$(date +%Y%m%d).txt

# Backup current nix-darwin configuration
cp -r ~/.config/nix-darwin ~/.config/nix-darwin.backup-$(date +%Y%m%d)
```

### 2. Dotfiles Backup
```bash
# Backup existing dotfiles that will be managed by home-manager
for file in ~/.config/zsh/.zshrc ~/.config/1Password/ssh/agent.toml ~/.config/starship.toml; do
  if [ -f "$file" ]; then
    cp "$file" "$file.backup-$(date +%Y%m%d)"
  fi
done
```

## 🚀 Application Sequence

### Phase 1: Preparation
1. **Switch to main branch and pull latest**
   ```bash
   cd ~/dotfiles
   git checkout main
   git pull origin main
   ```

2. **Choose configuration approach**
   - Option A: Use `flake.nix` (current, without homebrew)
   - Option B: Use `flake-analyst.nix` (with homebrew enabled)

3. **Install Homebrew** (if using Option B)
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

### Phase 2: Configuration Sync
1. **Update local configuration**
   ```bash
   # Copy/link the configuration to nix-darwin directory
   cd ~/dotfiles/nix-darwin
   make copy-config  # or use manual cp commands
   ```

2. **Validate configuration**
   ```bash
   cd ~/dotfiles/nix-darwin
   nix flake check
   ```

### Phase 3: Build and Test
1. **Dry run (build without switching)**
   ```bash
   cd ~/dotfiles/nix-darwin
   darwin-rebuild build --flake .#nw-mbp
   ```

2. **Review changes**
   ```bash
   # Check what will be installed
   nix-store -qR ./result | grep -v '/nix/store' | sort | uniq
   ```

### Phase 4: Apply Configuration
1. **Apply the configuration**
   ```bash
   cd ~/dotfiles/nix-darwin
   darwin-rebuild switch --flake .#nw-mbp
   ```

2. **Verify application**
   ```bash
   # Check new generation
   darwin-rebuild --list-generations
   
   # Verify symlinks
   ls -la ~/.config/
   ```

## ⚠️ Potential Issues and Solutions

### Issue 1: Homebrew Integration
- **Problem**: Homebrew not installed but configuration expects it
- **Solution**: Either install Homebrew or use flake.nix which has it disabled

### Issue 2: Existing Dotfiles
- **Problem**: Conflicts with existing configuration files
- **Solution**: Home-manager will create `.backup` files automatically

### Issue 3: Path Issues
- **Problem**: Hardcoded paths in configurations
- **Solution**: Already addressed with relative paths in recent updates

### Issue 4: Missing SSH Keys
- **Problem**: agent.toml references SSH keys that don't exist
- **Solution**: Keys will need to be added to 1Password

## 🔄 Rollback Procedures

### Quick Rollback
```bash
# List all generations
darwin-rebuild --list-generations

# Switch to previous generation (replace N with generation number)
darwin-rebuild switch --rollback
```

### Manual Rollback
```bash
# Restore backed up configuration
cp -r ~/.config/nix-darwin.backup-$(date +%Y%m%d)/* ~/.config/nix-darwin/

# Rebuild with old configuration
darwin-rebuild switch --flake ~/.config/nix-darwin#nw-mbp
```

## 📋 Verification Checklist

After application, verify:
- [ ] System boots and functions normally
- [ ] Shell (zsh) loads with correct configuration
- [ ] Starship prompt displays correctly
- [ ] 1Password SSH agent configuration is in place
- [ ] All expected packages are available
- [ ] Home-manager symlinks are created correctly

## 🔧 Post-Application Tasks

1. **Clean up backups** (after confirming everything works)
   ```bash
   # Remove old backup files after a week of stable operation
   find ~ -name "*.backup-*" -mtime +7 -delete
   ```

2. **Update shell configuration**
   ```bash
   # Ensure new shell configuration is loaded
   source ~/.zshrc
   ```

3. **Test key applications**
   - Test neovim/helix editors
   - Verify git configuration
   - Check 1Password SSH integration

## 📝 Commands Summary

```bash
# Complete application in one go (after backups)
cd ~/dotfiles
git checkout main
git pull origin main
cd nix-darwin
darwin-rebuild switch --flake .#nw-mbp

# Or use the makefile
cd ~/dotfiles/nix-darwin
make switch
```

## 🚨 Emergency Contacts
- Nix-Darwin Issues: https://github.com/LnL7/nix-darwin/issues
- Home-Manager Issues: https://github.com/nix-community/home-manager/issues
- This Repository Issues: https://github.com/aRustyDev/dotfiles/issues

---
*Created: $(date)*
*Last Updated: $(date)*