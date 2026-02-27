get_fpaths(){
    local mypath=(
        "/usr/share/zsh/$ZSH_VERSION/functions" \
        "/usr/share/zsh/site-functions" \
        "$ZDOTDIR/functions" \
        "$ZDOTDIR/completions" \
        "/usr/local/share/zsh/site-functions" \
        "/usr/share/zsh/functions"
    )
    # Add brew paths if brew exists
    if command -v brew >/dev/null 2>&1; then
        BREW_PREFIX="$(brew --prefix)"
        fpath=(
            $mypath \
            "$BREW_PREFIX/share/zsh-completions" \
            "$BREW_PREFIX/share/zsh/site-functions" \
            $fpath
        )
    else
        fpath=(
            $mypath \
            $fpath
        )
    fi

    for profile in ${(z)NIX_PROFILES}; do
      fpath+=($profile/share/zsh/site-functions $profile/share/zsh/$ZSH_VERSION/functions $profile/share/zsh/vendor-completions)
    done
}
