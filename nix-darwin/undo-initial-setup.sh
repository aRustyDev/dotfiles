#!/bin/bash

# Undo script for initial-setup.sh
# This reverses the changes made through step 4 (before nix-darwin switch)

set -e

echo "=== Undoing Initial nix-darwin Setup ==="
echo ""
echo "This will undo changes made by initial-setup.sh through step 4"
echo "It will NOT undo any nix-darwin installation if that completed"
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled"
    exit 1
fi

# Step 1: Stop nix daemon
echo ""
echo "1. Stopping Nix daemon..."
sudo launchctl stop org.nixos.nix-daemon 2>/dev/null || true

# Step 2: Remove experimental features from nix.conf
echo ""
echo "2. Removing experimental features from /etc/nix/nix.conf..."
if grep -q "experimental-features" /etc/nix/nix.conf 2>/dev/null; then
    # Create backup
    sudo cp /etc/nix/nix.conf /etc/nix/nix.conf.backup-$(date +%Y%m%d-%H%M%S)
    # Remove the experimental-features line
    sudo sed -i '' '/experimental-features = nix-command flakes/d' /etc/nix/nix.conf
    echo "Removed experimental-features line"
else
    echo "No experimental-features line found"
fi

# Step 3: Remove build users
echo ""
echo "3. Removing Nix build users..."
for i in {1..32}; do
    user="_nixbld$i"
    if id -u "$user" &>/dev/null 2>&1; then
        echo "Removing user $user..."
        sudo dscl . -delete /Users/"$user"
    fi
done

# Step 4: Remove nixbld group
echo ""
echo "4. Removing nixbld group..."
if dscl . -read /Groups/nixbld &>/dev/null 2>&1; then
    echo "Removing nixbld group..."
    sudo dscl . -delete /Groups/nixbld
else
    echo "nixbld group not found"
fi

# Step 5: Restart nix daemon (if it was running before)
echo ""
echo "5. Restarting Nix daemon..."
sudo launchctl start org.nixos.nix-daemon 2>/dev/null || true

echo ""
echo "=== Undo Complete! ==="
echo ""
echo "The following have been reverted:"
echo "✓ Removed nixbld group and build users"
echo "✓ Removed experimental-features from nix.conf"
echo "✓ Restarted nix daemon"
echo ""
echo "Note: This did NOT remove any nix-darwin installation if step 5 completed"
echo "To fully remove nix-darwin, use: make -f makefile-analyst uninstall"
