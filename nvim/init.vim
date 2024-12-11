" # ===================================================
" #                     Set Leader key
" # ===================================================

let mapleader = "'" " Remap Leader key to '

" # ===================================================
" #                     Various : https://builtin.com/software-engineering-perspectives/neovim-configuration
" # ===================================================
syntax on                   " syntax highlighting
set number                  " add line numbers
set cursorline              " highlight current cursorline
" (TODO) highlight a change after it happens and fade out highlight
" (TODO) track changes as motions & send to NATS (Visual Selections,Changes,Deletes,Yanks, Editor state(every ~2s))
" (TODO) App/Plugin to render and search a graph; use OpenCypher QL as motions?

set softtabstop=4           " see multiple spaces as tabstops so <BS> does the right thing
set tabstop=4               " number of columns occupied by a tab 
set shiftwidth=4            " width for autoindents
set cc=80                   " set an 80 column border for good coding style

set hlsearch                " highlight all search results
set incsearch               " show incremental search results as you type
set ignorecase              " case insensitive searching

set nocompatible            " disable compatibility to old-time vi
set showmatch               " show matching 
set mouse=v                 " middle-click paste with 
set expandtab               " converts tabs to white space
set autoindent              " indent a new line the same amount as the line just typed
set wildmode=longest,list   " get bash-like tab completions
filetype plugin indent on   "allow auto-indenting depending on file type
set mouse=a                 " enable mouse click
set clipboard=unnamedplus   " using system clipboard
filetype plugin on
set ttyfast                 " Speed up scrolling in Vim
" set spell                 " enable spell check (may need to download language package)

" set noswapfile            " disable creating swap file
" set backupdir=~/.cache/vim " Directory to store backup files.

" # ===================================================
" #                     Key Remaps
" # ===================================================

inoremap jk <ESC> " remap ESC to jk

" # ===================================================
" #                     LazyVim Plugin Config
" # ===================================================

call plug#begin("~/.vim/plugged")
 " Plugin Section
 Plug 'dracula/vim'
 Plug 'ryanoasis/vim-devicons'
 Plug 'SirVer/ultisnips'
 Plug 'honza/vim-snippets'
 Plug 'scrooloose/nerdtree'
 Plug 'preservim/nerdcommenter'
 Plug 'mhinz/vim-startify'
 Plug 'neoclide/coc.nvim', {'branch': 'release'}
 " Plug 'aRustyDev/filesync'
 " Plug 'aRustyDev/obsidivim'
 " Plug 'aRustyDev/rust.nvim'
 " Plug 'aRustyDev/js.nvim'
 " Plug 'aRustyDev/c-cpp.nvim'
 " Plug 'aRustyDev/java.nvim'
 " Plug 'aRustyDev/go.nvim'
 " Plug 'aRustyDev/hashicorp.nvim'
 " Plug 'aRustyDev/cloud.nvim'
 " Plug 'aRustyDev/collaborate.nvim'
 " Plug 'aRustyDev/spyder-tools.nvim'
call plug#end()
