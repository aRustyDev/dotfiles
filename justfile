import '.build/just/lib.just'

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

dependencies:
    @brew update && brew upgrade
    @brew install most git-delta jq jqp yq 1password@nightly 1password-cli@beta

install target="all":
    @{{ if target == "all" { "just _install-everything" } else { "just -f " + root + "/" + target + "/justfile install" } }}

_install-everything:
    @just install zsh
    @just install homebrew
    @just install op
    @just install ghostty
    @just install aerospace
    @just install bash
    @just install zed
    @just install starship
    @just install nvim
    @just install kube
    @just install git
    @just install ssh
