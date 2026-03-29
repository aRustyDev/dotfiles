# =============================================================================
# Core (direct modules)
# =============================================================================

# Git version control with 1Password signing
mod git 'core/git/justfile'
# SSH client configuration
mod ssh 'core/ssh/justfile'
# 1Password CLI
mod op 'core/op/justfile'
# Daemon service manager (launchd)
mod daemon 'daemon/justfile'

# =============================================================================
# Groups
# =============================================================================

# Shell environments (zsh, bash, starship)
mod shell 'shells/justfile'
# Terminal emulators & multiplexers
mod term 'terminals/justfile'
# Code editors (nvim, vscode, zed)
mod editor 'editors/justfile'
# Databases (meilisearch, dolt)
mod db 'services/databases/justfile'
# Services (ntfy, n8n)
mod svc 'services/justfile'
# Infrastructure (docker, helm, k9s, kube, terraform)
mod infra 'tools/infra/justfile'
# Operating system (macos, cron, pam, paths)
mod os 'os/justfile'
# VPN (wireguard)
mod vpn 'vpn/justfile'
# Window managers (aerospace, amethyst)
mod wm 'window-mgr/justfile'
# Browsers (zen)
mod browser 'browsers/justfile'
# Version managers (mise, tenv, volta)
mod ver 'tools/ver-mgr/justfile'
# Developer tools, fonts, keyboards, linters, agents
mod tool 'tools/justfile'

set shell := ["bash", "-euo", "pipefail", "-c"]

import '.build/just/lib.just'

# Install all registered modules
install:
    #!/usr/bin/env bash
    echo "📦 Installing all modules..."
    names=(git ssh op daemon shell term editor db svc infra os vpn wm browser ver tool)
    paths=(core/git core/ssh core/op daemon shells terminals editors services/databases services tools/infra os vpn window-mgr browsers tools/ver-mgr tools)
    for i in "${!names[@]}"; do
        name="${names[$i]}"
        jf="{{ justfile_directory() }}/${paths[$i]}/justfile"
        if [[ -f "$jf" ]] && "{{ just_executable() }}" -f "$jf" --list 2>/dev/null | grep -q '^\s*install\b'; then
            echo "📦 $name"
            "{{ just_executable() }}" -f "$jf" install
        else
            echo "⏭️  $name (no install recipe)"
        fi
    done
    echo "🎉 Install complete!"

# List available module groups
list:
    @echo "Module groups:"
    @echo "  Core:    git, ssh, op, daemon"
    @echo "  shell:   zsh, bash, starship"
    @echo "  term:    alacritty, ghostty, kitty, wezterm, mux:{tmux,zellij}"
    @echo "  editor:  nvim, vscode, zed"
    @echo "  db:      meilisearch, dolt"
    @echo "  svc:     ntfy, n8n"
    @echo "  infra:   docker, helm, k9s, kube, terraform"
    @echo "  os:      macos, cron, pam, paths"
    @echo "  vpn:     wireguard"
    @echo "  wm:      aerospace, amethyst"
    @echo "  browser: zen"
    @echo "  ver:     mise, tenv, volta"
    @echo "  tool:    fzf, zoxide, fd, ripgrep, direnv, jq, yazi"
    @echo "           design:{sketch,gimp} lint:{codebook,shellcheck}"
    @echo "           agent:{adrs,beads,gastown} font keeb:{karabiner,skhd}"
    @echo "           other:{glab,sourcebot,stow,...}"

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
