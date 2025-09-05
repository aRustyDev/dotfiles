init_antidote(){
    if [[ -v $ZPLUGINS ]]; then
        echo "ERROR(init_antidote): ZPLUGINS not set [$ZPLUGINS]"
        # exit 1
    fi
    local antidote="${ZPLUGINS}/antidote"
    # Generate a new static file whenever manifest is updated.
    if [[ ! -f "$antidote.zsh.zwc" || "$antidote" -nt "$antidote.zsh.zwc" ]]; then
        antidote bundle <$antidote >|$antidote.zsh
        source $antidote.zsh && zcompile "$antidote.zsh"
    else;
        source $antidote.zsh
    fi
}
