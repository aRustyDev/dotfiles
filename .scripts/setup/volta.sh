#!/usr/bin/env bash
# Volta setup script for Nix home-manager activation
# This script is called by volta.nix during activation

set -euo pipefail

# Arguments passed from Nix
VOLTA_BIN="${1}"
MACHINE_CONFIG="${2}"
DEFAULT_TOOLS_FILE="${3}"
MACHINE_TOOLS_FILE="${4}"
DRY_RUN_CMD="${DRY_RUN_CMD:-}"

echo "Setting up Volta for Node.js management..."
echo "Machine configuration: ${MACHINE_CONFIG}"

# Step 1: Ensure Volta home directory exists
if [[ ! -d "$HOME/.volta" ]]; then
  echo "Creating Volta home directory..."
  $DRY_RUN_CMD mkdir -p "$HOME/.volta/bin"
fi

# Step 2: Create Volta symlink
if [[ ! -L "$HOME/.volta/bin/volta" ]]; then
  echo "Creating volta symlink..."
  $DRY_RUN_CMD ln -sf "${VOLTA_BIN}" "$HOME/.volta/bin/volta"
fi

# Step 3: Set up PATH for this script
export PATH="$HOME/.volta/bin:$PATH"

# Step 4: Install Node.js if not already installed
if ! command -v node &> /dev/null || [[ ! -f "$HOME/.volta/bin/node" ]]; then
  echo "Installing Node.js LTS via Volta..."
  $DRY_RUN_CMD volta install node@lts
  
  # Wait for installation
  sleep 1
  
  # Verify installation
  if command -v node &> /dev/null; then
    echo "Node.js installed successfully: $(node --version)"
  else
    echo "Warning: Node.js installation may have failed"
    exit 1
  fi
else
  echo "Node.js is already installed: $(node --version)"
fi

# Step 5: Install npm if needed
if ! command -v npm &> /dev/null; then
  echo "Installing npm..."
  $DRY_RUN_CMD volta install npm
fi

# Step 6: Parse and install tools
install_tools_from_file() {
  local tools_file="$1"
  local file_type="$2"
  
  if [[ ! -f "$tools_file" ]]; then
    echo "Warning: $file_type tools file not found: $tools_file"
    return
  fi
  
  echo "Processing $file_type tools from: $tools_file"
  
  # Use jq to parse the JSON file
  local tools=$(jq -r '.tools[] | select(.enabled != false) | "\(.name)|\(.version)|\(.description // "npm package")"' "$tools_file" 2>/dev/null || echo "")
  
  if [[ -z "$tools" ]]; then
    echo "No tools found in $tools_file"
    return
  fi
  
  # Process each tool
  while IFS='|' read -r name version description; do
    # Skip empty lines
    [[ -z "$name" ]] && continue
    
    # Determine package spec
    local package_spec="$name"
    if [[ "$version" != "latest" && -n "$version" ]]; then
      package_spec="${name}@${version}"
    fi
    
    echo "Checking ${name}..."
    
    # Check if already installed
    if volta list --format plain 2>/dev/null | grep -q "^package ${name}@"; then
      echo "  ✓ ${name} is already installed"
    else
      echo "  → Installing ${name} (${description})..."
      if $DRY_RUN_CMD volta install "${package_spec}"; then
        echo "  ✓ Successfully installed ${name}"
      else
        echo "  ✗ Warning: Failed to install ${name}"
      fi
    fi
  done <<< "$tools"
}

# Install default tools
echo ""
echo "Installing common npm tools..."
install_tools_from_file "$DEFAULT_TOOLS_FILE" "default"

# Install machine-specific tools
echo ""
echo "Installing ${MACHINE_CONFIG}-specific npm tools..."
install_tools_from_file "$MACHINE_TOOLS_FILE" "machine-specific"

# Show summary
echo ""
echo "Volta setup complete!"
echo "Installed packages:"
volta list --format plain | grep "^package" | sed 's/^package /  - /' || true