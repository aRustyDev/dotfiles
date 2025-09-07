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
