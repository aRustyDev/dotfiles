inject-ssh:
    op account add --address my.1password.com
    op inject --file ssh/config/*
    op inject --file ssh/pubs/*

merge-ssh-config:
    @test -f ssh/config/{include,cisco.*,default} && cat ssh/config/{include,cisco.*,default} > ssh/config/cisco.merged || echo "Cisco SSH Configs not found"
    @test -f ssh/config/{include,blvd.*,default} && cat ssh/config/{include,blvd.*,default} > ssh/config/blvd.merged || echo "Blvd SSH Configs not found"
    @test -f ssh/config/{include,cfs.*,default} && cat ssh/config/{include,cfs.*,default} > ssh/config/cfs.merged || echo "CFS SSH Configs not found"
    @test -f ssh/config/{include,usaf.*,default} && cat ssh/config/{include,usaf.*,default} > ssh/config/usaf.merged || echo "USAF SSH Configs not found"

install-prereqs:
    echo "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo "Installing 1password"
    brew install 1password
    echo "Installing op CLI"
    brew install 1password-cli@beta
    eval $(op signin --account my.1password.com)
    echo "Installing Nix via Determinate Systems"
    curl -fsSL https://install.determinate.systems/nix | sh -s -- install --determinate
    echo "Installing Rosetta for Silicon Macs"
    softwareupdate --install-rosetta --agree-to-license

install: install-prereqs
    echo "Downloading the pre-reqs"
    inject-ssh
    merge-ssh-config

install-cisco: install
    echo "Configuring via Nix-Darwin"
    nix run nix-darwin -- switch --flake nix-darwin/.#cisco
    # nix run nix-darwin -- switch --flake github:my-user/my-repo#my-config             # Potentially faster, but would need to somehow inject before building.
    clean

install-cfs: install
    echo "Configuring via Nix-Darwin"
    nix run nix-darwin -- switch --flake nix-darwin/.#cfs
    # nix run nix-darwin -- switch --flake github:my-user/my-repo#my-config             # Potentially faster, but would need to somehow inject before building.
    clean

install-personal: install
    echo "Configuring via Nix-Darwin"
    nix run nix-darwin -- switch --flake nix-darwin/.#personal
    # nix run nix-darwin -- switch --flake github:my-user/my-repo#my-config             # Potentially faster, but would need to somehow inject before building.
    clean

clean:
    rm -f ssh/config/*.merged
    rm -f ssh/pubs/*.merged

clean-full:
    nix-installer uninstall /nix/receipt.json
