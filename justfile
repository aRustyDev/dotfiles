restart target:
    @if [ {{target}} = "zshrc" ]; then \
        echo "Clearing antidote cache and plugins..."; \
        rm -rf $(antidote home) 2>/dev/null || true; \
        rm -f $ZDOTDIR/plugins/antidote.zsh 2>/dev/null || true; \
        echo "Copying new .zshrc..."; \
        cp /Users/arustydev/repos/homelab/.zshrc $ZDOTDIR/.zshrc; \
        echo "Restarting shell..."; \
    fi
