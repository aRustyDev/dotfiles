#!/usr/bin/env bash
#
# Setup script for git-setup command
# This creates the appropriate symlinks and ensures proper configuration

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMANDS_DIR="$SCRIPT_DIR/commands"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}Git Setup Configuration${NC}"
echo

# Check which version to use
echo "Select git-setup version:"
echo "1) MVP (git-setup-v2) - Stable, basic features"
echo "2) Advanced - Caching, fuzzy matching, enhanced UI"
echo
read -p "Choice (1-2): " version_choice

case $version_choice in
    1)
        SOURCE_SCRIPT="git-setup-v2"
        echo -e "${GREEN}Selected MVP version${NC}"
        ;;
    2)
        SOURCE_SCRIPT="git-setup-advanced"
        echo -e "${GREEN}Selected Advanced version${NC}"
        ;;
    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac

# Make scripts executable
chmod +x "$COMMANDS_DIR/git-setup-v2"
chmod +x "$COMMANDS_DIR/git-setup-advanced"

# Create main git-setup symlink
cd "$COMMANDS_DIR"
ln -sf "$SOURCE_SCRIPT" git-setup
echo -e "${GREEN}✓ Created git-setup -> $SOURCE_SCRIPT symlink${NC}"

# Offer to install system-wide
echo
echo "Install system-wide?"
echo "1) Symlink to /usr/local/bin (requires sudo)"
echo "2) Add to PATH in shell config"
echo "3) Use git alias"
echo "4) Skip system-wide installation"
echo
read -p "Choice (1-4): " install_choice

case $install_choice in
    1)
        echo -e "${BLUE}Creating system-wide symlink...${NC}"
        sudo ln -sf "$COMMANDS_DIR/git-setup" /usr/local/bin/git-setup
        echo -e "${GREEN}✓ Installed to /usr/local/bin/git-setup${NC}"
        ;;
    2)
        echo
        echo "Add this line to your ~/.zshrc or ~/.bashrc:"
        echo
        echo -e "${YELLOW}export PATH=\"$COMMANDS_DIR:\$PATH\"${NC}"
        echo
        ;;
    3)
        echo -e "${BLUE}Creating git alias...${NC}"
        git config --global alias.setup "!$COMMANDS_DIR/git-setup"
        echo -e "${GREEN}✓ Created git alias 'setup'${NC}"
        echo "You can now use: git setup <profile>"
        ;;
    4)
        echo "Skipping system-wide installation"
        echo "You can run the command directly:"
        echo -e "${YELLOW}$COMMANDS_DIR/git-setup${NC}"
        ;;
esac

# Check dependencies
echo
echo -e "${BLUE}Checking dependencies...${NC}"

missing_deps=()
for cmd in op jq git; do
    if command -v "$cmd" &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} $cmd"
    else
        echo -e "  ${RED}✗${NC} $cmd"
        missing_deps+=("$cmd")
    fi
done

if [[ ${#missing_deps[@]} -gt 0 ]]; then
    echo
    echo -e "${YELLOW}Missing dependencies:${NC}"
    for dep in "${missing_deps[@]}"; do
        case $dep in
            op)
                echo "  Install 1Password CLI:"
                echo "    brew install --cask 1password-cli"
                ;;
            jq)
                echo "  Install jq:"
                echo "    brew install jq"
                ;;
        esac
    done
fi

echo
echo -e "${GREEN}Setup complete!${NC}"
echo
echo "Next steps:"
echo "  1. Run 'git setup -add' to create your first profile"
echo "  2. Use 'git setup <profile>' in any git repository"
echo "  3. See 'git setup -help' for all options"
