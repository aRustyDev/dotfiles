fpath=(
    "/usr/share/zsh/site-functions" \
    "/usr/local/share/zsh/site-functions" \
    "$HOME/.zsh/functions" \
    "$HOME/.config/zsh/functions" \
    "$(brew --prefix)/share/zsh-completions"
)
export FPATH="${(j|:|)fpath}"

# ---------------------------------------
# === === === === ENV VAR === === === ===
# ---------------------------------------

export STARSHIP_CONFIG=~/.config/starship.toml
export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock

# ---------------------------------------
# === === === === Aliases === === === ===
# ---------------------------------------

alias ll='ls -l'
alias python=python3
alias pip=pip3

# ---------------------------------------
# === === === Initializations === === ===
# ---------------------------------------

eval "$(atuin init zsh)"
eval "$(starship init zsh)"
eval "$(brew shellenv)"

# autoload -Uz compinit && compinit

# -----------------------------------
# === === === Completions === === ===
# -----------------------------------

kubectl completion zsh > "${fpath[2]}/_kubectl"
helm completion zsh > "${fpath[2]}/_helm"
