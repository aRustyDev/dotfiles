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

# Backup a profile (full tar.gz)
just -f zen/justfile backup <profile-id>

# Restore from backup
just -f zen/justfile restore backups/profile-20240101.tar.gz <profile-id>

# Export all essential data (selective backup)
just -f zen/justfile export-all <profile-id>

# Open profile folder
just -f zen/justfile open-profile <profile-id>
```

## Data Import/Export

### Bookmarks

```bash
# Backup bookmark JSON files
just -f zen/justfile backup-bookmarks <profile-id>
```

**File locations:**
- `places.sqlite` - Bookmarks & history database
- `bookmarkbackups/` - Automatic JSON backups

**Manual export:** Bookmarks menu → Manage Bookmarks → Import and Backup → Export to HTML

### Settings & Preferences

```bash
# Export about:config settings
just -f zen/justfile export-prefs <profile-id>

# Export search engine config
just -f zen/justfile export-search <profile-id>
```

**File locations:**
- `prefs.js` - All about:config changes
- `search.json.mozlz4` - Custom search engines (LZ4 compressed)
- `user.js` - Create this for persistent custom settings

### Extensions

```bash
# List extensions in a profile
just -f zen/justfile extensions <profile-id>

# Export extension list as JSON
just -f zen/justfile export-extensions <profile-id>
```

**File locations:**
- `extensions.json` - Installed extensions manifest
- `extension-settings.json` - Extension preferences
- `extensions/` - Extension files

### Theme / Chrome

```bash
# Export userChrome.css and theme files
just -f zen/justfile export-theme <profile-id>

# Import theme to profile
just -f zen/justfile import-theme <profile-id>
```

**File locations:**
- `chrome/userChrome.css` - UI customization
- `chrome/userContent.css` - Webpage styling

**Enable custom CSS:** Set `toolkit.legacyUserProfileCustomizations.stylesheets = true` in about:config

### Workspaces / Spaces

```bash
# Export Zen workspaces (requires lz4)
just -f zen/justfile export-workspaces <profile-id>
```

**File locations:**
- `zen-session.jsonlz4` - Workspaces, folders, tabs (LZ4 compressed)

**Note:** No built-in import feature yet. Copy file between profiles manually.

## Essential Profile Files

| File | Purpose |
|------|---------|
| `places.sqlite` | Bookmarks & history |
| `cookies.sqlite` | Cookies & sessions |
| `extensions.json` | Extensions list |
| `prefs.js` | about:config settings |
| `search.json.mozlz4` | Search engines |
| `zen-session.jsonlz4` | Workspaces |
| `logins.json` + `key4.db` | Saved passwords |
| `cert9.db` | SSL certificates |
| `chrome/` | Theme customization |

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
