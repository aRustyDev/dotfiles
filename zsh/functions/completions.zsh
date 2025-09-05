complete -C '/opt/homebrew/bin/aws_completer' aws

generate_completions() {
    if [[ -v $ZDOTDIR ]]; then
        echo "ERROR(generate_completions): ZDOTDIR not set [$ZDOTDIR]"
        # exit 1
    fi
    if [[ -v $HOME && ! -v $XDG_CONFIG_HOME  ]]; then
        echo "ERROR(generate_completions): Neither XDG_CONFIG_HOME nor HOME set"
        # exit 1
    fi
    local output_file="$ZDOTDIR/completions/_$cmd"
    local config="${XDG_CONFIG_HOME:-$HOME/.config}/dot_helper/completions.yaml"
    local shellenv="zsh"

    # Construct completion command, filter for ZSH
    local commands=$(
        yq -o json '.' $config \
        | jq --arg shell "$shellenv" '[. | to_entries
        | .[]
        | (.value |= capture("(?<cmd>.+)\\[(?<shell>.*)\\]"))
        | select(.value.shell | contains($shell))
        | (.value |= "\(.cmd)"+$shell)]'
    )

    for json in $(echo $commands | jq '.'); do
        cmd=$(echo $json | jq '.key')
        echo "::1: $cmd"
        # Only generate if command exists AND (file doesn't exist OR command is newer)
        if command -v "$cmd" >/dev/null 2>&1; then
            echo "::2: exists"
            if [[ ! -f "$output_file" ]] || [[ $(command -v "$cmd") -nt "$output_file" ]]; then
                echo "::3: $(echo $json | jq '\(.key) \(.value)')"
                eval "$(echo $json | jq '\(.key) \(.value)')" 2>/dev/null 1> $output_file
            fi
        fi
    done
}
