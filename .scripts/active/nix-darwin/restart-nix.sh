#!/bin/bash

# On macOS
sudo launchctl stop org.nixos.nix-daemon
sudo launchctl start org.nixos.nix-daemon

# Or simply restart it
sudo launchctl kickstart -k system/org.nixos.nix-daemon
