# Migrate all npm packages to Volta management

## Summary
Currently, the system has npm packages installed globally via npm in `/usr/local/lib/node_modules`, which creates conflicts and inconsistencies. All npm packages should be managed exclusively through Volta for better version control and user isolation.

## Current State
The following npm packages are installed globally outside of Volta:
- @anthropic-ai/claude-code (1.0.44)
- @biomejs/biome
- @commitlint/cli
- @commitlint/config-conventional
- @slidev/cli
- @slidev/theme-bricks
- @slidev/theme-default
- astro
- conventional-changelog-atom
- corepack
- crx
- generator-code
- grunt-cli
- npm
- pnpm
- stylelint
- stylelint-config-standard
- stylelint-config-standard-scss
- vsce
- web-ext
- yo

## Migration Plan
1. ✅ Update npm-tools configuration files to include all packages
2. ✅ Fix PATH configuration to prioritize Volta-managed tools
3. ⏳ Apply nix-darwin configuration to install tools via Volta
4. ⏳ Remove global npm installations from `/usr/local/lib/node_modules`
5. ⏳ Verify all tools work correctly through Volta

## Configuration Changes Made
- Updated `hosts/npm-tools/default.json` to include all npm packages
- Modified `hosts/base-home.nix` to set explicit PATH without contamination from other users
- PATH now prioritizes `$HOME/.volta/bin` over `/usr/local/bin`

## Cleanup Steps Required
```bash
# After Volta installation is confirmed working:
sudo npm uninstall -g @anthropic-ai/claude-code @biomejs/biome @commitlint/cli @commitlint/config-conventional @slidev/cli @slidev/theme-bricks @slidev/theme-default astro conventional-changelog-atom corepack crx generator-code grunt-cli pnpm stylelint stylelint-config-standard stylelint-config-standard-scss vsce web-ext yo

# Verify no packages remain
npm list -g --depth=0
```

## Benefits
- User-specific tool installations
- Better version management
- No sudo required for npm operations
- Consistent tool versions across projects
- Cleaner system state