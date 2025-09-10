initialize(){
    local cmd=$1
    local config="${XDG_CONFIG_HOME:-$HOME/.config}/dot_helper/initilizations.yaml"
    local is_critical=$(CMD=$cmd yq -r '.[strenv(CMD)] | .critical == true' $config)
    if command -v "$cmd" >/dev/null 2>&1; then
        if $is_critical; then
            cache_eval $cmd
        else;
            zsh-defer cache_eval $cmd
        fi;
    fi;
}

cache_eval(){
    local cmd=$1
    local config="${XDG_CONFIG_HOME:-$HOME/.config}/dot_helper/initilizations.yaml"
    local suffix=$(CMD=$cmd yq -r '.[strenv(CMD)] | .suffix' $config \
        | jq --arg shell "$shellenv" '.suffix
        | capture("(?<cmd>.+)\\[(?<shell>.*)\\]")
        | select( .shell | contains($shell) )
        | "\(.cmd)\($shell)"'
    )
    if command -v "$cmd" >/dev/null 2>&1; then
        _evalcache $cmd $suffix
    fi
}
