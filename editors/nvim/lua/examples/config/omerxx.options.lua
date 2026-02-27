-- Disable mouse mode
vim.o.mouse = ''

-- Enable break indent
vim.o.breakindent = true

-- Set colorscheme
--vim.cmd [[colorscheme onedark]]
vim.cmd.colorscheme "catppuccin"

-- Concealer for Neorg
vim.o.conceallevel = 2

-- [[ Basic Keymaps ]]
-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
