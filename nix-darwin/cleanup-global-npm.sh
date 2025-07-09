#!/usr/bin/env bash
# Cleanup script to remove globally installed npm packages
# Run this after verifying all tools work correctly through Volta

echo "This script will remove globally installed npm packages from /usr/local"
echo "WARNING: This will require sudo and will modify system files"
echo "Make sure all your tools are working through Volta before proceeding!"
echo ""
read -p "Are you sure you want to continue? (y/N) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Cleanup cancelled"
    exit 1
fi

echo "Removing global npm packages..."
sudo npm uninstall -g \
    @anthropic-ai/claude-code \
    @biomejs/biome \
    @commitlint/cli \
    @commitlint/config-conventional \
    @slidev/cli \
    @slidev/theme-bricks \
    @slidev/theme-default \
    astro \
    conventional-changelog-atom \
    corepack \
    crx \
    generator-code \
    grunt-cli \
    pnpm \
    stylelint \
    stylelint-config-standard \
    stylelint-config-standard-scss \
    vsce \
    web-ext \
    yo

echo ""
echo "Checking remaining global packages..."
npm list -g --depth=0

echo ""
echo "Cleanup complete! All npm packages should now be managed through Volta."
echo "You can verify tools are working by running:"
echo "  which claude     # Should show ~/.volta/bin/claude"
echo "  claude --version # Should work correctly"