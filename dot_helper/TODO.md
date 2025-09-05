# TODOs

- [path_helper](path_master): Manage PATH vars based on files in /etc/*paths.d/
- `/etc/shells` config
- zsh config
  - zshenv
  - zshrc
  - zprofile
  - plugins
  - init
- cache config
- .config
- software config
- lib config
- ai config
  - claude
  - cortex
  - gemini


## Commands
```bash
dot_helper completion zsh # zsh, bash, fish, elvish, powershell
dot_helper completions    # run completions for shell based on config
dot_helper paths          # build *PATH's from /etc/*PATHS.d/*
dot_helper fpaths         # build function paths from /etc/shells/*fpath.d/*
dot_helper git            #
dot_helper libs           #
dot_helper shell          # update /etc/shells based on config
dot_helper functions      # manage functions in fpath, deconflict precedence
dot_helper terms          #
dot_helper envs           # manage ENV Vars for shells
dot_helper editor         #
dot_helper alias          # manage aliases from config & depending on whats installed
```

- `atuin dotfiles var set NAME 'value'`


    antidote ffmpeg sevenzip poppler ripgrep \
    resvg imagemagick helm kubectl atuin jq \
    starship zoxide yazi lsd bat fzf nvim yq \
    ansible just helm-ls 1password-cli@beta \
    font-symbols-only-nerd-font tealdeer info \
    mise eza archive pyenv k9s turbot/tap/steampipe \
    zsh gawk grep gnu-sed coreutils



for profile in ${(z)NIX_PROFILES}; do
  fpath+=($profile/share/zsh/site-functions $profile/share/zsh/$ZSH_VERSION/functions $profile/share/zsh/vendor-completions)
done
fpath=($ZDOTDIR/completions $fpath)
fpath=("$(brew --prefix)/share/zsh/site-functions" $fpath)

<!-- # # Configure PATH after nix-daemon.sh to ensure our paths take precedence
# # Initialize path array from current PATH
# path=(${(s/:/)PATH})

# # Ensure darwin-rebuild is accessible by adding nix-darwin path first
# if [[ -d /run/current-system/sw/bin ]]; then
#     path=('/run/current-system/sw/bin' $path)
# fi

# # Add other important paths
# path=("$HOME/.volta/bin" $path)
# path=("$HOME/.cargo/bin" $path)

# # Append additional paths
# path+=('/Applications/VMware Fusion.app/Contents/Public')
# path+=('/usr/local/share/dotnet')
# path+=('~/.dotnet/tools')
# path+=('/usr/local/go/bin')
# path+=("$HOME/.pyenv/shims")
# path+=("$HOME/.local/bin")

# # Ensure unique paths
# typeset -U path cdpath fpath manpath -->
