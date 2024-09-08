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
	@cp -r bash/ ~/dotfiles/bash/ || true
	@cp -r nu/ ~/dotfiles/nu/ || true
	@cp -r sh/ ~/dotfiles/sh/ || true
	@cp -r fish/ ~/dotfiles/fish/ || true
	@cp -r zellij/ ~/dotfiles/zellij/ || true
	@cp -r macOS/ ~/dotfiles/macOS/ || true
	@cp -r wezterm/ ~/dotfiles/wezterm/ || true
	@cp -r skhd/ ~/dotfiles/skhd/ || true
	@rm -rf ~/dotfiles/*/examples || true
