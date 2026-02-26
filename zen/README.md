# zen

Zen Browser - A beautifully designed, privacy-focused Firefox fork.

## Current Configuration

- `brewfile` - Zen Browser cask and OpenSC for smart cards
- `.extensions.yaml` - Curated list of Firefox extensions
- `key-binds.toml` - Custom keybinding reference
- `profiles.*` - Profile backups (split zip archive)

### Extensions Installed

See `.extensions.yaml` for full list. Key extensions:
- **Privacy**: uBlock Origin, Privacy Badger, ClearURLs, DuckDuckGo
- **Productivity**: 1Password, Dark Reader, Cookie Editor
- **Development**: Wappalyzer, ColorZilla, axe DevTools
- **Research**: Zotero Connector, Web Scraper, Wayback Machine

## Installation

```bash
just -f zen/justfile install
```

This installs:
1. Zen Browser via Homebrew
2. Configures 1Password browser integration

## Profile Management

Zen stores profiles in `~/Library/Application Support/zen/Profiles/`.

```bash
# List available profiles
just -f zen/justfile profiles

# Backup a profile
just -f zen/justfile backup <profile-id>

# Restore from backup
just -f zen/justfile restore backups/profile-20240101.tar.gz <profile-id>

# Open profile folder
just -f zen/justfile open-profile <profile-id>
```

## Extension Management

```bash
# List extensions in a profile
just -f zen/justfile extensions <profile-id>

# Export extension list
just -f zen/justfile export-extensions <profile-id>
```

## Keybindings

| Key | Action |
|-----|--------|
| `Cmd+P` | New private window |
| `Cmd+S` | Focus search bar |
| `Cmd+L` | Focus location bar |
| `Cmd+D` | Add bookmark |
| `Cmd+Shift+C` | Copy URL |
| `Cmd+Ctrl+C` | Copy URL as Markdown |
| `Cmd+Shift+X` | Open extensions |
| `Cmd+R` | Reload page |
| `Cmd+Shift+R` | Reload (skip cache) |

## Smart Card / CAC Support

For PIV/CAC smart card authentication:

1. Install OpenSC: `brew install opensc`
2. In Zen: `about:preferences#privacy` → Security Devices → Load
3. Add module path: `/opt/homebrew/lib/opensc-pkcs11.so`

## 1Password Integration

The install recipe automatically adds Zen to 1Password's allowed browsers list at `/etc/1password/custom_allowed_browsers`.

## TODOs

### Extensions (Medium Priority)

- [ ] **Vim navigation**: Choose between Tridactyl, Vimium, or Surfingkeys
- [ ] **GitHub enhancements**: Octotree, GitHub Gloc, Repo Size

### Configuration (Low Priority)

- [ ] **Custom search engines**: Add specialized searches (Rust docs, crates.io, etc.)
- [ ] **userChrome.css**: Custom UI tweaks

## File Structure

```
zen/
├── .extensions.yaml    # Extension manifest
├── key-binds.toml      # Keybinding reference
├── profiles.*          # Profile backup (split archive)
├── brewfile            # Zen Browser cask
├── justfile            # Installation recipes
├── data.yml            # Module config
└── README.md           # This file
```

## References

- [Zen Browser](https://zen-browser.app/)
- [Firefox Extensions](https://addons.mozilla.org/en-US/firefox/)
- [userChrome.css Guide](https://www.userchrome.org/)
- [OpenSC for Smart Cards](https://github.com/OpenSC/OpenSC)
