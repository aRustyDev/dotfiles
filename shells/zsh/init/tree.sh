make_dirs(){
    local PATHS_FILE="$HOME/.config/.paths.yaml"
    if [[ -f $PATHS_FILE ]]; then
        DOTDIRS=($(yq '.paths[] | select(.type == "dir") | "\(.env)=\(.path | envsubst)"' $PATHS_FILE))
        echo "=== DOTDIRS ==="
        for i in $DOTDIRS; do
            # Set local ENV Vars
            mkdir -p $i
        done
    else
        echo "ERROR: [$PATHS_FILE] does not exist"
        return 1
    fi
}

make_files(){
    local PATHS_FILE="$HOME/.config/.paths.yaml"
    if [[ -f $PATHS_FILE ]]; then
        DOTFILES=($(yq '.paths[] | select(.type == "file") | "\(.path | envsubst)"' $PATHS_FILE))
        echo "=== DOTFILES ==="
        for i in $DOTFILES; do
            # Set local ENV Vars
            eval mkdir -p $(dirname $i)
            eval touch $i
        done
    else
        echo "ERROR: [$PATHS_FILE] does not exist"
        return 1
    fi
}
