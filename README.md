# aRustyDev's Nix Configuration

> To get started, run
> `make install`
> `darwin-rebuild switch --flake ~/.config/nix-darwin --impure`

## 📊 Project Management

**[View Project Board](https://github.com/users/aRustyDev/projects/16)** | **[View Issues](https://github.com/aRustyDev/dotfiles/issues)** | **[Project Dashboard](PROJECT_DASHBOARD.md)**

This repository is undergoing a comprehensive evolution to become a world-class dotfiles management system using Nix-Darwin and Home-Manager. Track our progress on the project board above.

## How Your Dotfiles Repository Works

Think of your dotfiles repo as a **master blueprint** for setting up your Mac exactly how you like it. It's like having a recipe that can recreate your perfect development environment on any Mac.

### The Key Players

1. **Nix**: A package manager that treats software like LEGO blocks - each piece fits perfectly without conflicting
2. **nix-darwin**: Makes Nix work smoothly on macOS, handling system-level settings
3. **Home Manager**: Your personal assistant that manages user-specific files and settings
4. **Your dotfiles**: Configuration files that tell programs how to behave

### The Installation Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                         DOTFILES INSTALLATION BOOT SEQUENCE          │
└─────────────────────────────────────────────────────────────────────┘

[STAGE 0: PRE-BOOT CHECK]
    │
    ├─→ User runs: `make install`
    │
    └─→ Makefile checks: Is Nix installed?
         ├─→ NO:  Download & Install Nix Package Manager
         │        └─→ Creates /nix directory (your software warehouse)
         │        └─→ Sets up build users (workers that build software)
         │        └─→ Installs nix commands
         └─→ YES: Continue to Stage 1

[STAGE 1: FILE STAGING]
    │
    ├─→ Creates ~/dotfiles/ directory structure
    │   ├── nvim/      (Neovim configuration)
    │   ├── tmux/      (Terminal multiplexer settings)
    │   ├── zsh/       (Shell configuration)
    │   ├── starship/  (Prompt theme)
    │   └── ... (other configs)
    │
    └─→ Copies all configs from repo → ~/dotfiles/
         └─→ Removes example files (keeps only real configs)

[STAGE 2: SYSTEM INITIALIZATION]
    │
    ├─→ Copies nix-darwin configuration to ~/.config/nix-darwin/
    │   ├── flake.nix         (Master blueprint)
    │   ├── configuration.nix (System settings)
    │   └── hosts/           (Machine-specific configs)
    │
    └─→ Runs: `darwin-rebuild switch --flake ~/.config/nix-darwin`

[STAGE 3: NIX-DARWIN BOOT]
    │
    ├─→ Reads flake.nix (your master blueprint)
    │   └─→ Finds configuration for "gm-mbp" (your machine)
    │
    ├─→ Loads configuration.nix
    │   ├─→ Enables core services (like nix-daemon)
    │   ├─→ Sets system-wide settings
    │   └─→ Installs system packages (vim, neovim, helix)
    │
    └─→ Activates Home Manager module

[STAGE 4: HOME MANAGER ACTIVATION]
    │
    ├─→ Reads hosts/personal.nix (your user configuration)
    │
    ├─→ Package Installation Phase
    │   ├─→ Development tools (neovim, tmux, starship)
    │   ├─→ Shell tools (zsh, ripgrep, bat)
    │   ├─→ Git tools (git, lazygit)
    │   └─→ All packages from your lists
    │
    └─→ Dotfile Linking Phase
        ├─→ Creates symbolic links:
        │   ├── ~/.config/zsh/.zshrc     → ~/dotfiles/zsh/.zshrc
        │   ├── ~/.config/starship.toml  → ~/dotfiles/starship/starship.toml
        │   ├── ~/.config/1Password/...  → ~/dotfiles/1password/agent.toml
        │   └─→ All other config files
        │
        └─→ Sets environment variables:
            ├── EDITOR=nvim
            ├── ZDOTDIR=~/.config/zsh
            ├── STARSHIP_CONFIG=~/.config/starship/config.toml
            └─→ All other env vars

[STAGE 5: POST-BOOT CONFIGURATION]
    │
    ├─→ Shell Integration
    │   ├─→ Enables zsh
    │   ├─→ Activates starship prompt
    │   └─→ Sources shell configurations
    │
    ├─→ Program Initialization
    │   ├─→ Neovim: Lazy.nvim installs plugins on first run
    │   ├─→ Pre-commit: Hooks ready for Git repos
    │   └─→ 1Password: SSH agent configured
    │
    └─→ System Ready!
        └─→ All your tools and configs are active
```

### How It All Works Together

```
┌─────────────────────────────────────────────────────────────┐
│                    SYSTEM ARCHITECTURE                       │
└─────────────────────────────────────────────────────────────┘

                        Your Dotfiles Repo
                               │
                    ┌──────────┴──────────┐
                    │    flake.nix        │
                    │  (Master Control)   │
                    └──────────┬──────────┘
                               │
                ┌──────────────┴──────────────┐
                │                             │
        ┌───────▼────────┐          ┌────────▼────────┐
        │  nix-darwin    │          │  Home Manager   │
        │ (System Level) │          │  (User Level)   │
        └───────┬────────┘          └────────┬────────┘
                │                             │
    ┌───────────┴──────────┐      ┌──────────┴──────────┐
    │ • System services    │      │ • User packages     │
    │ • Global packages    │      │ • Dotfile links     │
    │ • macOS settings     │      │ • Shell setup       │
    │ • Security (sudo)    │      │ • Personal tools    │
    └──────────────────────┘      └─────────────────────┘
                │                             │
                └──────────┬──────────────────┘
                           │
                    ┌──────▼──────┐
                    │  Your Mac   │
                    │ Fully Setup │
                    └─────────────┘
```

### What Makes This Special?

1. **Reproducible**: Run this on any Mac and get the exact same setup
2. **Version Controlled**: Every change is tracked in Git
3. **Declarative**: You describe what you want, not how to get it
4. **Atomic**: Updates either fully succeed or fully fail (no broken states)
5. **Rollbackable**: Can return to any previous configuration

### The Magic of Symbolic Links

Instead of copying files everywhere, Home Manager creates **symbolic links** (shortcuts) from standard locations to your centralized dotfiles:

```
~/.config/nvim ─────link────→ ~/dotfiles/nvim/
~/.zshrc ──────────link────→ ~/dotfiles/zsh/.zshrc
```

This means:
- All configs live in one place (~/dotfiles/)
- Changes are instantly reflected everywhere
- Easy to backup and version control

### Why This Approach?

Traditional dotfile management is like manually arranging furniture every time you move. This approach is like having a moving company that photographs your home and recreates it exactly in your new place - down to which drawer your socks go in!
