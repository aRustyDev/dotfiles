# nvim

Neovim - hyperextensible Vim-based text editor.

## Current Configuration

- `init.lua` - Entry point (loads config.lazy)
- `lua/config/` - Core configuration (keymaps, lazy, options)
- `lua/plugins/` - Plugin specifications (kanagawa theme)
- `lua/examples/` - Reference configs from omerxx
- `lua/todo/` - Plugins to evaluate/add
- `spell/` - Spell check dictionaries

### Features Enabled
- Lazy.nvim for plugin management
- Kanagawa color scheme

## TODOs

### Cleanup (High Priority)

- [ ] **Organize lua/ structure**: Examples and todo dirs mixed with config
  - Consider moving examples outside lua/ or to a reference directory
  - Evaluate plugins in lua/todo/ and either add or remove

- [ ] **Review lazy-lock.json**: Not symlinked (lazy.nvim writes to it)
  - Consider adding to .gitignore if not tracking lockfile

### Options (From TODO.md)

- [ ] **Git change indicators**: Color-coded left gutter (gitsigns.nvim)
- [ ] **Warning/alert icons**: Right side diagnostics
- [ ] **Cursor underline**: Underline cursor style option
- [ ] **Line numbers**: Relative + absolute line numbers
- [ ] **Oil keymap**: Parent directory navigation
- [ ] **Undo history**: Persistent undo between sessions (undotree or built-in)

### Plugins (From TODO.md - High Priority)

- [ ] **File management**:
  - `stevearc/oil.nvim` - File explorer as buffer
  - `nvim-tree/nvim-tree.lua` - File tree sidebar

- [ ] **Fuzzy finding**:
  - `nvim-telescope/telescope.nvim` - Fuzzy finder
  - `ibhagwan/fzf-lua` - FZF integration

- [ ] **LSP & Completion**:
  - LSP configuration (lspconfig)
  - Completion (nvim-cmp or blink.cmp)
  - `folke/lazydev.nvim` - Lua dev setup

- [ ] **Treesitter**:
  - `nvim-treesitter/nvim-treesitter` - Syntax highlighting
  - `nvim-treesitter/nvim-treesitter-textobjects` - Enhanced motions

### Plugins (From TODO.md - Medium Priority)

- [ ] **UI/UX**:
  - `folke/which-key.nvim` - Keybinding hints
  - `folke/noice.nvim` - UI improvements
  - `rcarriga/nvim-notify` - Notifications
  - `nvim-lualine/lualine.nvim` - Statusline

- [ ] **Git**:
  - `lewis6991/gitsigns.nvim` - Git decorations
  - `NeogitOrg/neogit` - Git interface

- [ ] **Editing**:
  - `kylechui/nvim-surround` - Surround motions
  - `tpope/vim-sleuth` - Auto-detect indentation
  - `NMAC427/guess-indent.nvim` - Indent detection

### Plugins (Low Priority)

- [ ] **Debugging**: `mfussenegger/nvim-dap` + `rcarriga/nvim-dap-ui`
- [ ] **Markdown**: `MeanderingProgrammer/render-markdown.nvim`, `OXY2DEV/markview.nvim`
- [ ] **Obsidian**: `obsidian-nvim/obsidian.nvim`
- [ ] **Diagnostics**: `folke/trouble.nvim`
- [ ] **Formatting**: `stevearc/conform.nvim`
- [ ] **Folding**: `kevinhwang91/nvim-ufo`

### Integration

- [ ] **GitLab extension**: See https://docs.gitlab.com/editor_extensions/neovim/setup/
- [ ] **Atuin integration**: Shell history in nvim (explore options)
- [ ] **Tmux/Zellij navigation**: vim-tmux-navigator or similar

## File Loading Order

1. `init.lua` - Entry point
2. `lua/config/lazy.lua` - Lazy.nvim bootstrap
3. `lua/config/options.lua` - Vim options
4. `lua/config/keymaps.lua` - Key mappings
5. `lua/plugins/*.lua` - Plugin specs

## References

- [Neovim Documentation](https://neovim.io/doc/)
- [Lazy.nvim](https://github.com/folke/lazy.nvim)
- [Kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim)
- [LazyVim](https://www.lazyvim.org/)
- [Dotfyle - Plugin Trending](https://dotfyle.com/neovim/plugins/trending)
