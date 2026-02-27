#!/usr/bin/env bash
#
# Demo script showing the new git setup workflow

set -euo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}=== Git Setup Demo ===${NC}"
echo
echo "This demo shows how the new git setup system works."
echo

echo -e "${GREEN}Step 1: Adding a profile${NC}"
echo "Instead of modifying 1Password's agent.toml, you run:"
echo -e "${YELLOW}  git setup -add${NC}"
echo
echo "This will:"
echo "  1. Ask for a profile name (e.g., 'github', 'work', 'home')"
echo "  2. Show all SSH keys from your 1Password vaults"
echo "  3. Let you select the appropriate key"
echo "  4. Save the mapping locally"
echo

echo -e "${GREEN}Step 2: Using a profile${NC}"
echo "To configure a repository, simply run:"
echo -e "${YELLOW}  git setup github${NC}"
echo
echo "This will:"
echo "  1. Look up 'github' in your saved profiles"
echo "  2. Fetch the SSH public key from 1Password"
echo "  3. Configure git with signing settings"
echo "  4. Set up commit signature verification"
echo

echo -e "${GREEN}Step 3: Managing profiles${NC}"
echo -e "${YELLOW}  git setup -list${NC}     # See all your profiles"
echo -e "${YELLOW}  git setup -current${NC}  # Check current repo config"
echo -e "${YELLOW}  git setup gh${NC}        # Fuzzy matching (advanced version)"
echo

echo -e "${BLUE}Key Benefits:${NC}"
echo "  ✓ No more commented fields in agent.toml"
echo "  ✓ 1Password SSH agent works normally"
echo "  ✓ Simple profile names (github, work, cisco, cfs, etc.)"
echo "  ✓ Works offline after initial setup"
echo

echo -e "${BLUE}Example Workflow:${NC}"
echo "  # One-time setup for each profile"
echo "  git setup -add  # Add 'github' → 'GitHub SSH Key'"
echo "  git setup -add  # Add 'work' → 'Company GitLab Key'"
echo "  git setup -add  # Add 'cisco' → 'Cisco SSH Key'"
echo
echo "  # Daily usage"
echo "  cd ~/projects/personal-project"
echo "  git setup github"
echo
echo "  cd ~/projects/work-project"
echo "  git setup work"
echo
echo "  cd ~/projects/cisco-project"
echo "  git setup cisco"
