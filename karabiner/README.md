# karabiner

Karabiner-Elements - powerful keyboard customizer for macOS.

## Current Configuration

- **Status**: Stub module (no config installed yet)
- `examples/` - Reference configurations

## TODOs

### Setup (Critical)

- [ ] **Create karabiner.json**: Main configuration file
  - Config location: `~/.config/karabiner/karabiner.json`
  - Karabiner manages this file directly

- [ ] **Note**: Karabiner modifies its config file in-place
  - May need to use copy instead of symlink
  - Or configure Karabiner to use a different path

### Configuration (High Priority)

- [ ] **Basic remappings**:
  ```json
  {
    "simple_modifications": [
      { "from": { "key_code": "caps_lock" }, "to": [{ "key_code": "escape" }] }
    ]
  }
  ```

- [ ] **Complex modifications**: Hyper key, layers
  ```json
  {
    "description": "Caps Lock → Hyper (Ctrl+Option+Cmd+Shift)",
    "manipulators": [{
      "from": { "key_code": "caps_lock", "modifiers": { "optional": ["any"] } },
      "to": [{ "key_code": "left_shift", "modifiers": ["left_control", "left_option", "left_command"] }],
      "to_if_alone": [{ "key_code": "escape" }],
      "type": "basic"
    }]
  }
  ```

- [ ] **Device-specific rules**: Different keyboards
  - Internal MacBook keyboard
  - External mechanical keyboard
  - Differentiate by vendor_id/product_id

### Popular Modifications

- [ ] **Caps Lock as Escape/Hyper**: Most common mod
- [ ] **Vim navigation**: Caps + hjkl for arrows
- [ ] **App switching**: Hyper + letter for specific apps
- [ ] **Window management**: Integration with aerospace/yabai

### Integration

- [ ] **Aerospace integration**: Keybindings for window management
- [ ] **Application shortcuts**: Quick app launching
  ```json
  { "from": { "key_code": "t", "modifiers": { "mandatory": ["hyper"] } },
    "to": [{ "shell_command": "open -a 'Terminal'" }] }
  ```

### Resources

- [ ] **Goku**: Consider using Goku for easier configuration
  - Write rules in EDN instead of JSON
  - https://github.com/yqrashawn/GokuRakuJoudo

- [ ] **Import rules from community**:
  - https://ke-complex-modifications.pqrs.org/

## Notes

Karabiner-Elements requires:
- Input Monitoring permission (System Preferences → Privacy)
- Sometimes requires restart after permission changes
- Config file is actively managed by the app

## References

- [Karabiner-Elements Website](https://karabiner-elements.pqrs.org/)
- [Complex Modifications](https://ke-complex-modifications.pqrs.org/)
- [Goku](https://github.com/yqrashawn/GokuRakuJoudo)
- [Karabiner God Mode](https://medium.com/@nikitavoloboev/karabiner-god-mode-7407a5ddc8f6)
