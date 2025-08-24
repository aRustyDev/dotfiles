load_zshenv() {
    local env_file="$ZDOTDIR/.zshenv"
    if [[ -f "$env_file" ]]; then
        ENVMAP=$(
            # Open .zshenv
            cat $env_file \
            # clean the output
            | tr -d "'" \
            # split ENV to JSON array
            | awk -f $ZDOTDIR/init/data/envmap.awk \
            # return only unique as entried json
            | jq -r '. | unique | .[] | to_entries | .[]'
        )
    else
        echo "Error: File '$env_file' not found."
        return 1
    fi
}

# Q: How to input the two json to merge
merge_env() {
    read -u 0 stdin
    echo "=== MERGING ZSHENV ==="
    # This merges the existing environment variables from .zshenv with the configured values in $PATHS_FILE
    return (
        # JSON Blob #1
        echo $ENVMAP
        # JSON Blob #2
        echo $stdin
    ) | jq -s add
    # echo "$stdin" | jq -c '.[]' | while IFS= read -r obj; do
    #     iobj="$(echo "$obj" | jq -r '. | "{\"\(.env)\":\"\(.path)\"}"')"
    #     # Update ENV MAP
    #     # echo $iobj
    # done
}
