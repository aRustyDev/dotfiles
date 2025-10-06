import '.build/just/lib.just'

all := shell(require("fd") + " . -t d -d 1 " + root)

restart target:
    @if [ {{ target }} = "zshrc" ]; then \
        echo "Clearing antidote cache and plugins..."; \
        rm -rf $(antidote home) 2>/dev/null || true; \
        rm -f $ZDOTDIR/plugins/antidote.zsh 2>/dev/null || true; \
        echo "Copying new .zshrc..."; \
        cp /Users/arustydev/repos/homelab/.zshrc $ZDOTDIR/.zshrc; \
        echo "Restarting shell..."; \
    fi

update:
    @curl https://raw.githubusercontent.com/eza-community/eza/main/deb.asc -o .build/apt/keyrings/gierens.gpg
    @curl https://packages.cloud.google.com/apt/doc/apt-key.gpg -o .build/apt/keyrings/google-cloud.gpg
    @curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | gpg --enarmor -o .build/apt/keyrings/cloudflared.gpg
    @chmod 644 .build/apt/{sources,keyrings}/*

[windows]
[group('windows')]
dependencies:
    @require("choco") upgrade chocolatey
    @choco install most git-delta jq jqp yq 1password@nightly 1password-cli@beta

[unix]
[group('unix')]
dependencies:
    @require("brew") update && brew upgrade
    @brew install most git-delta jq jqp yq 1password@nightly 1password-cli@beta

# install dotfiles (defaults to all; specify to dirname)
[unix]
[group('unix')]
install target=all:
    #!/usr/bin/env zsh
    str="{{target}}"
    arr=("${(@f)str}")
    for absroot in ${arr[@]}; do
        echo "$dir"
        if [ ! path_exists("$absroot") ]; then
            echo "Directory $absroot does not exist"
            continue
        elif [ ! path_exists("$absroot/justfile") ]; then
            echo "$absroot's Justfile does not exist"
            continue
        elif [ ! just -f "$absroot/justfile" --list | require("rg") "install" 2>&1 ]; then
            echo "$absroot/justfile does not have an 'install' recipe"
            continue
        else
            echo "Installing $absroot..."
            echo just -f "$absroot/justfile" install
        fi
    done
