#!/bin/bash

# Initial nix-darwin setup script for analyst user
# This handles the chicken-and-egg problem of needing build users

set -e

echo "=== Initial nix-darwin Setup for analyst ==="
echo ""

# Step 1: Create build users (if they don't exist)
echo "1. Checking/creating Nix build users..."
if ! dscl . -read /Groups/nixbld &>/dev/null; then
    echo "Creating nixbld group..."
    sudo dscl . -create /Groups/nixbld
    sudo dscl . -create /Groups/nixbld PrimaryGroupID 30000
fi

# Create build users
for i in {1..32}; do
    user="_nixbld$i"
    if ! id -u "$user" &>/dev/null; then
        echo "Creating user $user..."
        sudo dscl . -create /Users/"$user"
        sudo dscl . -create /Users/"$user" UserShell /sbin/nologin
        sudo dscl . -create /Users/"$user" NFSHomeDirectory /var/empty
        sudo dscl . -create /Users/"$user" PrimaryGroupID 30000
        sudo dscl . -create /Users/"$user" UniqueID $((30000 + i))
        sudo dscl . -append /Groups/nixbld GroupMembership "$user"
    fi
done

# Step 2: Update nix.conf with experimental features
echo ""
echo "2. Updating /etc/nix/nix.conf..."
if ! grep -q "experimental-features" /etc/nix/nix.conf 2>/dev/null; then
    echo "experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf
fi

# Step 3: Restart nix daemon
echo ""
echo "3. Restarting Nix daemon..."
sudo launchctl stop org.nixos.nix-daemon 2>/dev/null || true
sudo launchctl start org.nixos.nix-daemon 2>/dev/null || true

# Step 4: Wait a moment for daemon to start
echo "Waiting for daemon to start..."
sleep 2

# Step 5: Run nix-darwin switch
echo ""
echo "4. Running nix-darwin switch..."
echo "This may take a while as it downloads and builds packages..."
cd "$(dirname "$0")"
nix run nix-darwin -- switch --flake .#analyst-mac --impure

echo ""
echo "=== Setup Complete! ==="
echo ""
echo "Next steps:"
echo "1. Open a new terminal to ensure all environment variables are loaded"
echo "2. Run 'darwin-rebuild switch --flake .#analyst-mac' for future updates"
echo "3. Check ~/.config/ for your symlinked configuration files"
