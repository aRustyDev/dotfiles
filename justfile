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
        [[ -f "$target_path/justfile" ]] || echo "⚠️  No justfile found in: $target"

        # Check if justfile has an 'install' recipe
        if ! "{{ just_executable() }}" -f "$target_path/justfile" --list 2>/dev/null | grep -q '^\s*install\b'; then
            echo "⚠️  No 'install' recipe in: $target/justfile"
        else
            # Run the install recipe
            echo "📦 Installing: $target"
            "{{ just_executable() }}" -f "$target_path/justfile" install
            echo "✅ Completed: $target"
        fi
    done
    echo "🎉 Install complete!"
