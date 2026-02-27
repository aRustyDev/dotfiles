# zoxide configuration for zsh
# Source this file in .zshrc or symlink to ~/.config/zoxide/zoxide.zsh

# Initialize zoxide
eval "$(zoxide init zsh)"

# Optional: Configure zoxide behavior
# export _ZO_DATA_DIR="$HOME/.local/share/zoxide"
# export _ZO_ECHO=1                    # Print matched directory before cd
# export _ZO_EXCLUDE_DIRS="$HOME:/"    # Directories to exclude
# export _ZO_FZF_OPTS="$FZF_DEFAULT_OPTS"  # Use same fzf opts
# export _ZO_MAXAGE=10000              # Maximum frecency score

# Aliases (zoxide init creates 'z' and 'zi' by default)
# alias cd='z'                         # Replace cd with z (optional)
