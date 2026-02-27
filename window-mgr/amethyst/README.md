# amethyst

Tiling window manager for macOS, similar to i3 or bspwm.

## Current Configuration

- **Status**: Stub module (no config installed yet)

## TODOs

### Setup (Critical)

- [ ] **Create amethyst config**: JSON configuration file
  - Config location: `~/.amethyst.yml` or `~/.config/amethyst/amethyst.yml`

### Configuration (High Priority)

- [ ] **Layout settings**:
  ```yaml
  layouts:
    - tall
    - wide
    - fullscreen
    - column
    - row
    - floating
    - bsp
  ```

- [ ] **Modifier keys**:
  ```yaml
  mod1:
    - option
    - shift
  mod2:
    - option
    - shift
    - control
  ```

- [ ] **Window margins**:
  ```yaml
  window-margins: true
  window-margin-size: 10
  screen-padding-top: 0
  screen-padding-bottom: 0
  screen-padding-left: 0
  screen-padding-right: 0
  ```

### Features (Medium Priority)

- [ ] **Focus follows mouse**:
  ```yaml
  focus-follows-mouse: true
  mouse-follows-focus: false
  ```

- [ ] **Window behavior**:
  ```yaml
  enables-layout-hud: true
  enables-layout-hud-on-space-change: true
  float-small-windows: true
  mouse-swaps-windows: true
  mouse-resizes-windows: true
  ```

- [ ] **Application-specific rules**:
  ```yaml
  floating:
    - com.apple.systempreferences
    - com.apple.finder
  ```

### Consideration

- [ ] **Evaluate window manager choice**: Consider alternatives
  - `aerospace` - Already configured in this repo (modern, scriptable)
  - `yabai` - Powerful but requires SIP disabled
  - `amethyst` - Simpler, no SIP changes needed
  - Built-in macOS window management (Stage Manager, etc.)

## References

- [Amethyst GitHub](https://github.com/ianyh/Amethyst)
- [Configuration Guide](https://github.com/ianyh/Amethyst#configuration)
- [Default Config](https://github.com/ianyh/Amethyst/blob/development/Amethyst/default.amethyst)
