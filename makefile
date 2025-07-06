DOTFILES := (nvim tmux ssh git starship zsh bash nu sh fish zellij macOS wezterm skhd)

# 1. Run sub makefiles
# 2. Copy dotfiles to ~/dotfiles
# 3. Remove examples from ~/dotfiles
install:
	@if ! command -v nix &> /dev/null; then cd nix-darwin && $(MAKE) install; else cd nix-darwin && $(MAKE) update; fi
	@mkdir -p ~/dotfiles/{nvim,nix-darwin,tmux,ssh,git,1Password,starship,zsh,bash,nu,sh,fish,zellij,macOS,wezterm,skhd}
	@cp -r 1Password/ ~/dotfiles/1Password/ || true
	@cp -r nvim/ ~/dotfiles/nvim/ || true
	@cp -r nix-darwin/ ~/dotfiles/nix-darwin/ || true
	@cp -r tmux/ ~/dotfiles/tmux/ || true
	@cp -r ssh/ ~/dotfiles/ssh/ || true
	@cp -r git/ ~/dotfiles/git/ || true
	@cp -r starship/ ~/dotfiles/starship/ || true
	@cp -r zsh/ ~/dotfiles/zsh/ || true
	@#cp -r bash/ ~/dotfiles/bash/ || true
	@#cp -r nu/ ~/dotfiles/nu/ || true
	@#cp -r sh/ ~/dotfiles/sh/ || true
	@#cp -r fish/ ~/dotfiles/fish/ || true
	@cp -r zellij/ ~/dotfiles/zellij/ || true
	@cp -r macOS/ ~/dotfiles/macOS/ || true
	@cp -r wezterm/ ~/dotfiles/wezterm/ || true
	@cp -r skhd/ ~/dotfiles/skhd/ || true
	@rm -rf ~/dotfiles/*/examples || true
	@darwin-rebuild switch --flake ~/.config/nix-darwin --impure

clean-old:
	@nix-env --delete-generations old
	@nix-store --gc

#
# nix --extra-experimental-features 'nix-command flakes' build .#darwinConfigurations.nw-mbp.system --impure

# Only use sudo for the profile creation
# sudo -H nix --extra-experimental-features 'nix-command flakes' build --profile /nix/var/nix/profiles/system .#darwinConfigurations.nw-mbp.system --impure

# Migrate Nix Users
# curl --proto '=https' --tlsv1.2 -sSf -L https://github.com/NixOS/nix/raw/master/scripts/sequoia-nixbld-user-migration.sh | bash -

# Activate (needs sudo because it modifies system files)
# sudo -H /nix/var/nix/profiles/system/activate

# Create the current-system link
# sudo ln -sfn /nix/var/nix/profiles/system /run/current-system

# cat > activate.sh << 'EOF'
# #!/bin/bash
# SYSTEM_PATH="./result"
# export PATH="$SYSTEM_PATH/sw/bin:$PATH"

# # Create necessary directories
# sudo mkdir -p /run/current-system
# sudo ln -sfn "$SYSTEM_PATH" /run/current-system

# # Run activation
# sudo "$SYSTEM_PATH/activate"

# # Set up the system profile
# sudo nix-env --profile /nix/var/nix/profiles/system --set "$SYSTEM_PATH"

# echo "System activated! Add /run/current-system/sw/bin to your PATH"
# EOF

# chmod +x activate.sh
# ./activate.sh

# Add these paths immediately
# export PATH="/run/current-system/sw/bin:$PATH"
# export PATH="/nix/var/nix/profiles/system/sw/bin:$PATH"
# source ~/.zshrc

# darwin-rebuild switch --flake ~/.config/nix-darwin --impure

# sudo scutil --set LocalHostName nw-mbp
# sudo scutil --set ComputerName nw-mbp
# sudo scutil --set HostName nw-mbp
