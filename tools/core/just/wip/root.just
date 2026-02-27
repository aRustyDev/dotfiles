set unstable := true

import 'scripts/just/cloud9.just'
import 'scripts/just/ssh.just'
import 'scripts/just/common.just'
import 'scripts/just/installs.just'
import 'scripts/just/packer.just'

# === === === === === === === === === === === === === === === === === === === === === === ===
#  Recipes
# === === === === === === === === === === === === === === === === === === === === === === ===

# Initialize the repo (install deps + initialize tools)
[group('core')]
init: install
    #!/usr/bin/env bash
    # Generate default config file
    echo "" | "{{ mustache }}" "{{ config_default_tmpl }}" > "{{ config }}"
    # Hydrate templates w/ config.yaml
    just config "tags"
    just config "ssh"
    just config "paths"
    just hydrate
    # just ssh-init
    just packer-init

# Hydrate templates w/ config.yaml
[group('core')]
hydrate:
    @just config "tags-git"
    @just hydrate-ssh

# Build docs for the repo
[group('core')]
docs:
    @just packer-docs

# Build the AMI using Packer with resolved source and variable files.
[group('core')]
build d=distro: authn_aws hydrate
    #!/usr/bin/env bash
    # just hydrate-cloud9 "{{ d }}"
    just update-config ".ec2.ami.distro" "{{ d }}"
    just packer-build

# List unique for 'target'.
[group('core')]
[group('list')]
uniq target param="":
    @just "ls-uniq-{{ if param != "" { target + " " + param } else { target } }}"

# Update Config.yaml with 'target' (tags|paths)
[group('core')]
config target:
    @just "config-{{ target }}"

# Clean up generated files
[group('core')]
clean: packer-clean

# Format/Lint+Fix all files in repository
[group('core')]
fmt: cspell
    #!/usr/bin/env bash
    just --fmt -f {{ root }}/justfile
    for j in $(ls {{ root }}/scripts/just); do
        just --fmt --unstable -f {{ root }}/scripts/just/$j
    done
    packer fmt "{{ root }}/packer/"
