# fzf configuration for zsh
# Source this file in .zshrc or symlink to ~/.config/fzf/fzf.zsh

# Use fd for file search (respects .gitignore)
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'

# Default options
export FZF_DEFAULT_OPTS="
  --height 40%
  --layout=reverse
  --border
  --info=inline
  --preview-window=right:50%:wrap
"

# Catppuccin Mocha theme
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS
  --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8
  --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
  --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
"

# Preview settings
export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -50'"

# History search
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window=down:3:wrap"
