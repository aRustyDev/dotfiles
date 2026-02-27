import './common.just'

# Variables

python_version := "3.13"

# Files

brew_required := root + "/config/brew/required"
brew_recommended := root + "/config/brew/recommended"

# Install all required packages & initialize required tools
[group('core')]
[macos]
install scope="required":
    @echo "[ install({{ scope }}) ]"
    @just "{{ scope }}" || true
    @just pyenv-init bash
    @just pyenv-init zsh

# Install all required packages & initialize required tools
[group('core')]
[linux]
install scope="required":
    @echo "[ install({{ scope }}) ]"
    @just "{{ scope }}" || true
    @just pyenv-init bash

# Setup pyenv for (bash || zsh) w/ specified python ver
[private]
pyenv-init shell="bash":
    #!/usr/bin/env bash
    echo "[ init(pyenv@{{ shell }}) ]"
    touch ~/".{{ shell }}rc"
    grep -qxF 'export PYENV_ROOT="$HOME/.pyenv"' ~/".{{ shell }}rc" || echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/".{{ shell }}rc"
    grep -qxF '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' ~/".{{ shell }}rc" || echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/".{{ shell }}rc"
    grep -qxF 'eval "$(pyenv init - {{ shell }})"' ~/".{{ shell }}rc" || echo 'eval "$(pyenv init - {{ shell }})"' >> ~/".{{ shell }}rc"
    "{{ pyenv }}" install "{{ python_version }}" --skip-existing
    "{{ pyenv }}" local "{{ python_version }}"
    pip install --upgrade pip
    pip install -r "{{ configsd }}/requirements.txt"

# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
# Internal Only Recipes (Used by other recipes only)
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

# (MacOS) Install the minimal packages needed for this project
[group('core')]
[macos]
[private]
required:
    @brew update
    @brew bundle install --file "{{ brew_required }}"
    @"{{ go }}" install github.com/cbroglie/mustache/cmd/mustache@latest

# Install core project dependencies on Unix-like systems via apt and pip.
[group('core')]
[linux]
[private]
required:
    @sudo apt-get install packer
    @sudo apt-get install jq
    @"{{ go }}" install github.com/cbroglie/mustache/cmd/mustache@latest

# (MacOS) Install the additional, but recommended packages for this project
[group('core')]
[macos]
[private]
recommended:
    @brew update
    @brew bundle install --file "{{ brew_recommended }}"

# Use Brew Bundle for atomic check/install of required deps
[group('core')]
[macos]
[private]
ensure-required:
    #!/usr/bin/env bash
    echo "[ verify(dependencies) ]"
    if brew bundle check --no-upgrade --file "{{ brew_required }}" >/dev/null 2>&1; then
        exit 0
    fi
    echo "Installing missing brew dependencies..."
    brew bundle install --file "{{ brew_required }}"
