# Browsers =====================================================================
# Firefox-based browser with vertical tabs
mod zen 'browsers/zen/justfile'

# Core =========================================================================
# Git version control with 1Password signing
mod git 'core/git/justfile'
# SSH client configuration
mod ssh 'core/ssh/justfile'
# 1Password CLI
mod op 'core/op/justfile'

# Editors ======================================================================
# Neovim text editor
mod nvim 'editors/nvim/justfile'
# Visual Studio Code
mod vscode 'editors/vscode/justfile'
# Zed editor
mod zed 'editors/zed/justfile'

# Fonts ========================================================================
# Nerd Fonts and development fonts
mod fonts 'fonts/justfile'

# OS ===========================================================================
# macOS system preferences
mod macos 'os/macos/justfile'

# Services =====================================================================
# Dolt SQL database with Git versioning
mod dolt 'services/databases/dolt/justfile'
# Meilisearch search engine
mod meilisearch 'services/databases/meilisearch/justfile'
# ntfy push notification service
mod ntfy 'services/ntfy/justfile'
# n8n workflow automation
mod n8n 'services/n8n/justfile'

# Shells =======================================================================
# Bash shell
mod bash 'shells/bash/justfile'
# Starship cross-shell prompt
mod starship 'shells/starship/justfile'
# Zsh shell
mod zsh 'shells/zsh/justfile'

# Terminals ====================================================================
# Alacritty GPU-accelerated terminal
mod alacritty 'terminals/alacritty/justfile'
# Ghostty GPU-accelerated terminal
mod ghostty 'terminals/ghostty/justfile'
# Kitty GPU-accelerated terminal
mod kitty 'terminals/kitty/justfile'
# WezTerm terminal emulator
mod wezterm 'terminals/wezterm/justfile'

# Tools ========================================================================
# Config-less tools (group brewfile)
mod tools 'tools/justfile'
# Docker container runtime
mod docker 'tools/infra/docker/justfile'
# Helm Kubernetes package manager
mod helm 'tools/infra/helm/justfile'
# K9s Kubernetes TUI
mod k9s 'tools/infra/k9s/justfile'
# Kubernetes CLI tools
mod kube 'tools/infra/kube/justfile'
# Terraform infrastructure as code
mod terraform 'tools/infra/terraform/justfile'
# Karabiner keyboard remapper
mod karabiner 'tools/keebs/karabiner/justfile'
# skhd hotkey daemon
mod skhd 'tools/keebs/skhd/justfile'
# tmux terminal multiplexer
mod tmux 'tools/multiplexers/tmux/justfile'
# Zellij terminal workspace
mod zellij 'tools/multiplexers/zellij/justfile'
# mise polyglot runtime manager
mod mise 'tools/mise/justfile'
# Steampipe SQL for cloud APIs
mod steampipe 'tools/steampipe/justfile'
# tenv Terraform version manager
mod tenv 'tools/ver-mgr/tenv/justfile'
# Sketch design application
mod sketch 'tools/design/sketch/justfile'
# Yazi terminal file manager
mod yazi 'tools/file-mgr/yazi/justfile'

# VPN ==========================================================================
# WireGuard VPN
mod wireguard 'vpn/wireguard/justfile'

# Window Managers ==============================================================
# AeroSpace tiling window manager
mod aerospace 'window-mgr/aerospace/justfile'
# Amethyst tiling window manager
mod amethyst 'window-mgr/amethyst/justfile'

set shell := ["bash", "-euo", "pipefail", "-c"]

import '.build/just/lib.just'

# Get all immediate subdirectories (depth 1) that contain a justfile
_subdirs := shell("find " + justfile_directory() + " -mindepth 2 -maxdepth 2 -name 'justfile' -type f -exec dirname {} \\; | xargs -I{} basename {} | sort | tr '\\n' ' '")

restart target:
    @if [ {{ target }} = "zshrc" ]; then \
        echo "Clearing antidote cache and plugins..."; \
        rm -rf $(antidote home) 2>/dev/null || true; \
        rm -f $ZDOTDIR/plugins/antidote.zsh 2>/dev/null || true; \
        echo "Copying new .zshrc..."; \
        cp /Users/arustydev/repos/homelab/.zshrc $ZDOTDIR/.zshrc; \
        echo "Restarting shell..."; \
    fi

update:
    @curl https://raw.githubusercontent.com/eza-community/eza/main/deb.asc -o .build/apt/keyrings/gierens.gpg
    @curl https://packages.cloud.google.com/apt/doc/apt-key.gpg -o .build/apt/keyrings/google-cloud.gpg
    @curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | gpg --enarmor -o .build/apt/keyrings/cloudflared.gpg
    @chmod 644 .build/apt/{sources,keyrings}/*

[windows]
[group('windows')]
dependencies:
    @require("choco") upgrade chocolatey
    @choco install most git-delta jq jqp yq 1password@nightly 1password-cli@beta

[unix]
[group('unix')]
dependencies:
    @require("brew") update && brew upgrade
    @brew install most git-delta jq jqp yq 1password@nightly 1password-cli@beta

# List available install targets (subdirectories with justfiles)
[unix]
[group('unix')]
list-targets:
    @echo "Available install targets:"
    @echo "{{ _subdirs }}" | tr ' ' '\n' | grep -v '^$' | sed 's/^/  - /'

# Install dotfiles
# - No args: install all subdirectories with justfiles
# - Single target: just install zsh
# - Multiple targets (comma-separated): just install zsh,git,tmux
# - Nested paths supported: just install docker/modules/cicd
[unix]
[group('unix')]
install *targets=_subdirs:
    #!/usr/bin/env bash

    # Convert to array
    read -a targets_arr <<< "{{replace(targets, ",", " ")}}"

    for target in "${targets_arr[@]}"; do
        [[ -z "$target" ]] && continue

        # Build absolute path
        target_path="{{ justfile_directory() }}/${target}"
        [[ -d "$target_path" ]] || echo "⚠️  Directory does not exist: ${target}"
        [[ -f "$target_path/justfile" ]] || echo "⚠️  No justfile found in: ${target}"

        # Check if justfile has an 'install' recipe
        if ! "{{ just_executable() }}" -f "$target_path/justfile" --list 2>/dev/null | grep -q '^\s*install\b'; then
            echo "⚠️  No 'install' recipe in: $target_path/justfile"
        else
            # Run the install recipe
            echo "📦 Installing: $target"
            "{{ just_executable() }}" -f "$target_path/justfile" install
            echo "✅ Completed: $target"
        fi
    done
    echo "🎉 Install complete!"

# =============================================================================
# AI Configuration Management
# =============================================================================

# Initialize or update the ai submodule
[unix]
[group('ai')]
ai-init:
    @echo "🔄 Initializing ai submodule..."
    git submodule update --init --recursive ai/
    @echo "✅ ai submodule initialized"

# Update ai submodule to latest from remote
[unix]
[group('ai')]
ai-update:
    @echo "🔄 Updating ai submodule..."
    git submodule update --remote ai/
    @echo "✅ ai submodule updated"

# Install AI configs to global locations (Claude Code)
[unix]
[group('ai')]
install-ai:
    #!/usr/bin/env bash
    echo "📦 Installing AI configs..."

    # Create target directories
    mkdir -p ~/.claude/{commands,skills,hooks,rules}

    # Install from ai/components/ (new structure)
    if [[ -d "{{ justfile_directory() }}/ai/components" ]]; then
        echo "  Installing from ai/components/..."
        [[ -d "{{ justfile_directory() }}/ai/components/commands" ]] && \
            cp -r "{{ justfile_directory() }}/ai/components/commands/"* ~/.claude/commands/ 2>/dev/null || true
        [[ -d "{{ justfile_directory() }}/ai/components/skills" ]] && \
            cp -r "{{ justfile_directory() }}/ai/components/skills/"* ~/.claude/skills/ 2>/dev/null || true
        [[ -d "{{ justfile_directory() }}/ai/components/hooks" ]] && \
            cp -r "{{ justfile_directory() }}/ai/components/hooks/"* ~/.claude/hooks/ 2>/dev/null || true
        [[ -d "{{ justfile_directory() }}/ai/components/rules" ]] && \
            cp -r "{{ justfile_directory() }}/ai/components/rules/"* ~/.claude/rules/ 2>/dev/null || true
    fi

    # Also install from legacy/ during migration period
    if [[ -d "{{ justfile_directory() }}/ai/legacy" ]]; then
        echo "  Installing from ai/legacy/..."
        [[ -d "{{ justfile_directory() }}/ai/legacy/commands" ]] && \
            cp -r "{{ justfile_directory() }}/ai/legacy/commands/"* ~/.claude/commands/ 2>/dev/null || true
        [[ -d "{{ justfile_directory() }}/ai/legacy/skills" ]] && \
            cp -r "{{ justfile_directory() }}/ai/legacy/skills/"* ~/.claude/skills/ 2>/dev/null || true
        [[ -d "{{ justfile_directory() }}/ai/legacy/hooks" ]] && \
            cp -r "{{ justfile_directory() }}/ai/legacy/hooks/"* ~/.claude/hooks/ 2>/dev/null || true
        [[ -d "{{ justfile_directory() }}/ai/legacy/rules" ]] && \
            cp -r "{{ justfile_directory() }}/ai/legacy/rules/"* ~/.claude/rules/ 2>/dev/null || true
    fi

    echo "✅ AI configs installed to ~/.claude/"

# Sync AI configs (update submodule + install)
[unix]
[group('ai')]
ai-sync:
    @echo "🔄 Syncing AI configs..."
    just ai-update
    just install-ai
    @echo "✅ AI configs synced"
