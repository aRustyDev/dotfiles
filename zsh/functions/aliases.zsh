init_aliases(){
    if [[ -v $ZDOTDIR ]]; then
        echo "ERROR(init_aliases): ZDOTDIR not set [$ZDOTDIR]"
        # exit 1
    fi
    local aliases="$ZDOTDIR/init/aliases.zsh"
    source $aliases
    [[ ! -f "$aliases.zwc" || "$aliases" -nt "$aliases.zwc" ]] && zcompile "$aliases"
}
