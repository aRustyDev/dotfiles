default: (install "cisco")
sshTmplCfg := "ssh/.tmpl/config"

op-inject:
    op account add --address my.1password.com
    for file in `ls ssh/.tmpl/config/`; do \
      op inject -f -i ssh/.tmpl/config/$file -o ssh/config/$file; \
    done
    for file in `ls ssh/.tmpl/pubs/`; do \
      op inject -f -i ssh/.tmpl/pubs/$file -o ssh/pubs/$file; \
    done

hydrate: op-inject
    for file in `ls '{{sshTmplCfg}}' | grep -Eo "(cisco)|(blvd)"`; do \
        cat "{{sshTmplCfg}}/includes" "{{sshTmplCfg}}/$file"* "{{sshTmplCfg}}/default" > ssh/config/$file.merged; \
        echo "merged $file"; \
    done

install-prereqs:
    if ! command -v brew > /dev/null 2>&1; then \
        echo "Installing Homebrew"; \
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
    fi
    if ! brew list --cask | grep -q "1password@nightly" 2>&1; then \
        echo "Installing 1password"; \
        brew install 1password@nightly; \
    fi
    if ! brew list --cask | grep -q "1password-cli@beta" 2>&1; then \
        echo "Installing 1password CLI"; \
        brew install 1password-cli@beta; \
    fi
    cat .data/assets/asciiart/1password-setup.txt
    if ! command -v nix > /dev/null 2>&1; then \
        echo "Installing Nix via Determinate Systems"; \
        curl -fsSL https://install.determinate.systems/nix | sh -s -- install --determinate; \
    fi
    echo "Installing Rosetta for Silicon Macs"
    softwareupdate --install-rosetta --agree-to-license



install target: install-prereqs
    echo "Downloading the pre-reqs"
    just hydrate
    echo "Configuring via Nix-Darwin for {{target}}"
    sudo nix run nix-darwin -- switch --flake "nix-darwin/.#{{target}}"
    # nix run nix-darwin -- switch --flake github:my-user/my-repo#my-config             # Potentially faster, but would need to somehow inject before building.
    clean

clean:
    rm -f ssh/config/*.merged
    rm -f ssh/pubs/*.merged

clean-full:
    /nix/nix-installer uninstall /nix/receipt.json
