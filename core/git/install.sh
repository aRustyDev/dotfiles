#!/usr/bin/env bash
#
# Install git-setup command system-wide
# This script sets up the git-setup command to be available everywhere

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMANDS_DIR="$SCRIPT_DIR/commands"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}Git Setup Installation${NC}"
echo

# Check if running from correct directory
if [[ ! -d "$COMMANDS_DIR" ]]; then
    echo -e "${RED}Error: commands directory not found${NC}"
    echo "Please run this script from the dotfiles/git directory"
    exit 1
fi

# Choose installation method
echo "Choose installation method:"
echo "1) Symlink to /usr/local/bin (recommended)"
echo "2) Git alias (no PATH changes needed)"
echo "3) Add to PATH via shell config"
echo
read -p "Selection (1-3): " method

case $method in
    1)
        # Symlink method
        echo -e "\n${BLUE}Installing git-setup to /usr/local/bin${NC}"

        # Ensure /usr/local/bin exists
        sudo mkdir -p /usr/local/bin

        # Remove existing symlink if present
        sudo rm -f /usr/local/bin/git-setup

        # Create symlink to advanced version
        sudo ln -sf "$COMMANDS_DIR/git-setup-advanced" /usr/local/bin/git-setup

        echo -e "${GREEN}✓ Installed successfully${NC}"
        echo -e "${YELLOW}You can now use: git setup <profile>${NC}"
        ;;

    2)
        # Git alias method
        echo -e "\n${BLUE}Creating git alias${NC}"

        git config --global alias.setup "!$COMMANDS_DIR/git-setup-advanced"

        echo -e "${GREEN}✓ Git alias created${NC}"
        echo -e "${YELLOW}You can now use: git setup <profile>${NC}"
        ;;

    3)
        # PATH method
        echo -e "\n${BLUE}Add to PATH${NC}"
        echo
        echo "Add this line to your shell config (~/.zshrc or ~/.bashrc):"
        echo
        echo -e "${YELLOW}export PATH=\"$COMMANDS_DIR:\$PATH\"${NC}"
        echo
        echo "Then reload your shell or run:"
        echo -e "${YELLOW}source ~/.zshrc${NC}"
        ;;

    *)
        echo -e "${RED}Invalid selection${NC}"
        exit 1
        ;;
esac

echo
echo -e "${BLUE}Next steps:${NC}"
echo "1. Run 'git setup -add' to create your first profile"
echo "2. Use 'git setup <profile>' in any git repository"
echo "3. See 'git setup -help' for more options"

# Check dependencies
echo
echo -e "${BLUE}Checking dependencies...${NC}"

missing_deps=()
for cmd in op jq git; do
    if ! command -v "$cmd" &> /dev/null; then
        missing_deps+=("$cmd")
    else
        echo -e "  ${GREEN}✓${NC} $cmd"
    fi
done

if [[ ${#missing_deps[@]} -gt 0 ]]; then
    echo -e "\n${YELLOW}Missing dependencies:${NC}"
    for dep in "${missing_deps[@]}"; do
        echo -e "  ${RED}✗${NC} $dep"
        case $dep in
            op)
                echo "    Install with: brew install --cask 1password-cli"
                ;;
            jq)
                echo "    Install with: brew install jq"
                ;;
        esac
    done
fi
