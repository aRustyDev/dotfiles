#!/bin/sh
#
# git-setup
#
# aRustyDev
# git setup <registry> <repo>

# TODO: try supporting this config method instead https://markentier.tech/posts/2021/02/github-with-multiple-profiles-gpg-ssh-keys/

# ======================== FAIL FAST ========================

# Purpose: Throw error if `git setup` not used correctly
if [ "$1" == "" ]; then
    set_os_specific_stuff
    echo "Usage:    git setup <Agent.TomlKeyName>"
    echo "          | $OP_AGENT_FILE"
    echo "          | [[ssh-keys]]"
    echo "          | name = \"<UseThisValue>\""
    echo "          | item = \"FooItem\""
    echo "          | vault = \"BarVault\""
    echo "          | account = \"Avengers\""
    echo "Example:  git setup github mycoolrepo"
    echo "NOTE:     SSHKeyName is the name of the SSH Key in defined in your 1Password agent.toml"
    echo "Source:   ~/.config/git/setup_config.sh"
fi

# Check for required commands
for cmd in jq git op yq npm pip; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "$cmd could not be found"
        case "$cmd" in
            jq) echo "jq not installed" ;;
            git) echo "git not installed" ;;
            op) echo "1password-cli not installed" ;;
            yq) echo "yq not installed" ;;
            npm) echo "npm not installed" ;;
            pip) echo "pip not installed" ;;
        esac
        exit 1
    fi
done

# ======================== FUNCTIONS ========================

link_vscode(){
    if ! [ -e /usr/local/bin/code ]; then
        ln -s "$CODE_BIN" /usr/local/bin/code
    fi
}

precommit(){
    if [ -e "$PWD/.pre-commit-config.yaml" ]; then
        pip install pre-commit
        pre-commit install --install-hooks
        pre-commit install --hook-type commit-msg
        # ---- package.json ----
        if [ -e "$PWD/package.json" ]; then
            # If package.json already exists, merge it
            jq -s '.[0] * .[1]' package.json ~/.config/git/commitlint.package.json > package.json
        else
            # Otherwise copy it directly from original .config/git
            cp ~/.config/git/commitlint.package.json .
        fi
        # ---- commitlint.config.js ----
        if [ -e "$PWD/commitlint.config.js" ]; then
            # If commitlint.config.js already exists, copy it as "mine"
            cp ~/.config/git/commitlint.config.js commitlint.config.mine.js
        else
            # Otherwise copy it directly from original .config/git
            cp ~/.config/git/commitlint.config.js .
        fi
        # ---- pre-commit-config.yaml ----
        if [ -e "$PWD/.pre-commit-config.yaml" ]; then
            # If pre-commit-config.yaml already exists, copy it as "mine"
            cp ~/.config/git/.pre-commit-config.yaml .pre-commit-config.mine.yaml
        else
            # Otherwise copy it directly from original .config/git
            cp ~/.config/git/.pre-commit-config.yaml .
        fi
        npm install --save-dev @commitlint/{cli,config-conventional}
        npm i -D conventional-changelog-atom
    fi
}

# Returns the path to the ssh program for the current OS
set_os_specific_stuff (){
    unameOut="$(uname -s)"
    case "${unameOut}" in
        Linux*)
            SSH_PROGRAM="/opt/1Password/op-ssh-sign"
            SSH_ALLOWEDSIGNERS=""
            OP_AGENT_FILE="$HOME/.config/1Password/ssh/agent.toml"
            CODE_BIN=""
            if [ -z "$XDG_CONFIG_HOME"] && [ "$XDG_CONFIG_HOME" -ne "" ]; then
                SSH_ALLOWEDSIGNERS="$XDG_CONFIG_HOME/git/allowed_ssh_signers"
                OP_AGENT_FILE="$XDG_CONFIG_HOME/1Password/ssh/agent.toml"
            fi
            ;;
        Darwin*)
            SSH_PROGRAM="/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
            SSH_ALLOWEDSIGNERS="/Users/$(whoami)/.config/git/allowed_ssh_signers"
            OP_AGENT_FILE="$HOME/.config/1Password/ssh/agent.toml"
            CODE_BIN="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
            if [ -z "$XDG_CONFIG_HOME"] && [ "$XDG_CONFIG_HOME" != "" ]; then
                SSH_ALLOWEDSIGNERS="$XDG_CONFIG_HOME/git/allowed_ssh_signers"
                OP_AGENT_FILE="$XDG_CONFIG_HOME/1Password/ssh/agent.toml"
            fi
            git config --local credential.helper osxkeychain
            ;;
        CYGWIN*)
            SSH_PROGRAM=""
            SSH_ALLOWEDSIGNERS=""
            OP_AGENT_FILE="%LOCALAPPDATA%/1Password/config/ssh/agent.toml"
            CODE_BIN=""
            ;;
        MINGW*)
            SSH_PROGRAM=""
            SSH_ALLOWEDSIGNERS=""
            OP_AGENT_FILE="%LOCALAPPDATA%/1Password/config/ssh/agent.toml"
            CODE_BIN=""
            ;;
        MSYS_NT*)
            SSH_PROGRAM="${env:LOCALAPPDATA}\1Password\app\8\op-ssh-sign.exe"
            SSH_ALLOWEDSIGNERS=""
            OP_AGENT_FILE="%LOCALAPPDATA%/1Password/config/ssh/agent.toml"
            CODE_BIN=""
            ;;
        *)
            echo "UNKNOWN:${unameOut}" && exit 1
    esac
}

git_unset(){
    git config --local --unset user.signingkey
    git config --local --unset user.name
    git config --local --unset user.email
    git config --local --unset gpg.ssh.allowedSignersFile
    git config --local --unset gpg.ssh.program
    git config --local --unset gpg.format
    git config --local --unset tag.gpgsign
    git config --local --unset commit.gpgsign
}

# Returns the info for the ssh key in the specified vault
op_read (){
    op item list --categories "SSH Key" --vault "$1" --format=json | \
    jq --arg TYTLE "$2" '.[] | select(.title | contains($TYTLE))' | \
    op item get --fields "$3"
}

# ======================== MAIN ========================

# Check if Registry is valid & set EnvVars
case "$1" in
    # Valid Registries
    github | gitlab | work | home)
        set_os_specific_stuff
        VAULT=$(NAME="$1" yq -oy '.ssh-keys[] | select(.name | contains(env(NAME))) | .vault' --input-format toml "$OP_AGENT_FILE")
        ITEM=$(NAME="$1" yq -oy '.ssh-keys[] | select(.name | contains(env(NAME))) | .item' --input-format toml "$OP_AGENT_FILE")
        ;;
    *)
        echo "Unknown-Target-SSH-Name: ${1}" && exit 1
esac

git_unset
git config --local init.defaultBranch main
git config --local gpg.ssh.allowedSignersFile "$SSH_ALLOWEDSIGNERS"
git config --local gpg.ssh.program "$SSH_PROGRAM"
git config --local gpg.format ssh
git config --local tag.gpgsign true
git config --local commit.gpgsign true
git config --local user.signingkey "$(op_read "$VAULT" "$ITEM" "public key")"
git config --local user.name $(op_read "$VAULT" "$ITEM" "username")
git config --local user.email $(op_read "$VAULT" "$ITEM" "email")
precommit
link_vscode # TODO
exit 0
