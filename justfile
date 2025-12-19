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
