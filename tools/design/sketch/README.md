# sketch

Sketch - Professional digital design for Mac.

## Current Configuration

- `brewfile` - Sketch beta cask

### Notes

Sketch stores configuration in macOS standard locations:
- **Preferences**: `~/Library/Preferences/com.bohemiancoding.sketch3.plist`
- **Plugins**: `~/Library/Application Support/com.bohemiancoding.sketch3/Plugins/`
- **Templates**: `~/Library/Application Support/com.bohemiancoding.sketch3/Templates/`

Configuration is primarily GUI-based through Sketch's preferences panel.

## Installation

```bash
just -f sketch/justfile install
```

## Recipes

```bash
# List installed plugins
just -f sketch/justfile plugins

# Open plugins folder in Finder
just -f sketch/justfile open-plugins

# Show config paths
just -f sketch/justfile info
```

## TODOs

### Plugins (Medium Priority)

- [ ] **Recommended plugins** to consider:
  - [Sketch Runner](https://sketchrunner.com/) - Command palette
  - [Stark](https://www.getstark.co/) - Accessibility checker
  - [Anima](https://www.animaapp.com/) - Design to code
  - [Content Generator](https://github.com/timuric/Content-generator-sketch-plugin) - Placeholder content

### Templates (Low Priority)

- [ ] **Custom templates**: Add project templates to `templates/` directory

### Export (Low Priority)

- [ ] **Export presets**: Document/backup custom export presets

## File Structure

```
sketch/
├── brewfile      # Sketch beta cask
├── justfile      # Installation recipes
├── data.yml      # Module config
└── README.md     # This file
```

## References

- [Sketch Website](https://www.sketch.com/)
- [Sketch Plugins Directory](https://www.sketch.com/extensions/plugins/)
- [Sketch Developer Documentation](https://developer.sketch.com/)
