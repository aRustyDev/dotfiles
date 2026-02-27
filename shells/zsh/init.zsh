#!/usr/bin/env zsh
PATHS_FILE=~/.config/.paths.yaml

casks=(
    antidote ffmpeg sevenzip poppler ripgrep \
    resvg imagemagick helm kubectl atuin jq \
    starship zoxide yazi lsd bat fzf nvim yq \
    ansible just helm-ls 1password-cli@beta \
    font-symbols-only-nerd-font tealdeer \
    mise eza pyenv k9s turbot/tap/steampipe \
    zsh gawk grep gnu-sed coreutils texinfo
)
# Optionally install Homebrew casks
# Exit with error if Homebrew is not installed
([[ -n $INSTALL_CASKS ]] && (command -v brew >/dev/null 2>&1 || (echo "brew not found" && exit 1))) && brew install $casks

# Set the non-array vars in ~/.config/zsh/.paths.yaml
LOCALVARS=($(yq -o=json -r '.vars' $PATHS_FILE | jq -r '.  | with_entries(select(.value | type != "array")) | to_entries'))
echo "$LOCALVARS" | jq -c '.[]' | while IFS= read -r obj; do
  eval export $(echo "$obj" | jq -r '.key')=\"$(echo "$obj" | jq -r '.value')\"
done

LOCALVARS=($(yq -o=json -r '.paths' ~/.config/.paths.yaml | jq -r '.[] | "\(.env)=\(.path)"'))
echo "=== LOCALS ==="
for i in $LOCALVARS; do
    # Set local ENV Vars
    eval export $(echo $i)
done

# Create the directories in $PATHS_FILE
DOTDIRS=($(yq '.paths[] | select(.type == "dir") | "\(.env)=\(.path | envsubst)"' $PATHS_FILE))
echo "=== DOTDIRS ==="
for i in $DOTDIRS; do
    # Set local ENV Vars
    mkdir -p $i
done

# Create the paths && files in $PATHS_FILE
DOTFILES=($(yq '.paths[] | select(.type == "file") | "\(.path | envsubst)"' $PATHS_FILE))
echo "=== DOTFILES ==="
for i in $DOTFILES; do
    # Set local ENV Vars
    eval mkdir -p $(dirname $i)
    eval touch $i
done

# DOTENVS: The configured values in $PATHS_FILE
# - contains ENV, DIR, and FILE values
DOTENVS=($(yq -o=json '.paths' $PATHS_FILE | jq -r '.'))
echo "=== DOTENVS ==="
touch $ZDOTDIR/.zshenv
# ENVMAP: The configured values in .zshenv
ENVMAP=$(
    cat $ZDOTDIR/.zshenv | tr -d "'" | awk '
        BEGIN {
            FS="="
            print "["
        }
        { data[NR, 1] = $1; data[NR, 2] = $2 }
        END {
            last = NR
            for (i = 1; i < NR; i++) {
                if (i < last - 1) {
                    print "{\""data[i, 1]"\":\""data[i, 2]"\"},"
                } else {
                    print "{\""data[i, 1]"\":\""data[i, 2]"\"}"
                }
            }
            print "]"
        }
    ' | jq -r '. | unique | .[] | to_entries | .[]'
)
echo "=== ENVMAP ==="
echo $ENVMAP
echo $DOTENVS
# This merges the existing environment variables from .zshenv with the configured values in $PATHS_FILE
echo "$DOTENVS" | jq -c '.[]' | while IFS= read -r obj; do
    iobj="$(echo "$obj" | jq -r '. | "{\"\(.env)\":\"\(.path)\"}"')"
    # Update ENV MAP
    ENVMAP=$(
        (   # JSON Blob #1
            echo $ENVMAP
            # JSON Blob #2
            echo $iobj
        ) | jq -s add
    )
    # echo $iobj
done

ZSHENV=()
echo "=== ENVMAP ==="
# echo $ENVMAP
# From here the merged env vars map get formatted and output to the .zshenv
# echo $ENVMAP | jq -r '. | to_entries | unique | .[]' | jq -c '.'
# echo $ENVMAP | jq -r '. | to_entries | unique | .[]' | jq -c '.' | while IFS= read -r obj; do
#     key=$(echo $obj | jq -c '.key' | tr -d '"')
#     value=$(echo $obj | jq -c '.value')
#     ZSHENV+="$key='$(eval echo "$value" | sed 's/::/:/g' | sed 's|[^/]*/\.\./||g')'\n"
# done
# echo $ZSHENV
# echo $ZSHENV | sed 's/^[[:space:]]*//g' | sed 's/^$//g' > $ZDOTDIR/.zshenv

# touch "$HOME/$STATE/lock.json5"
