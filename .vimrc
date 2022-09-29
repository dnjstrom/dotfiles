set langmenu=en_US.UTF-8

" Automatically install vim-plug if it doesn't exist
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()

" Lua helpers
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-lua/popup.nvim'

" Features
Plug 'scrooloose/nerdtree'
Plug 'tpope/vim-surround'
Plug 'mg979/vim-visual-multi'
Plug 'cohama/lexima.vim'
Plug 'hrsh7th/nvim-compe'
Plug 'hrsh7th/vim-vsnip'
Plug 'ap/vim-css-color'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-eunuch'
Plug 'phaazon/hop.nvim'

" Ergonomics
Plug 'karb94/neoscroll.nvim'

" Finder
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }

" Tmux integration
Plug 'tmux-plugins/vim-tmux'
Plug 'tmux-plugins/vim-tmux-focus-events'
Plug 'christoomey/vim-tmux-navigator'

" Visualization
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'lewis6991/gitsigns.nvim'

" Themes
Plug 'ayu-theme/ayu-vim'
Plug 'arcticicestudio/nord-vim'
Plug 'rakr/vim-one'
Plug 'dracula/vim'
Plug 'morhetz/gruvbox'
Plug 'altercation/vim-colors-solarized'
Plug 'jacoborus/tender.vim'
Plug 'connorholyday/vim-snazzy'
Plug 'mhartington/oceanic-next'
Plug 'bluz71/vim-nightfly-guicolors'

" Highlighting
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" Intellisense
Plug 'neovim/nvim-lspconfig'
Plug 'tami5/lspsaga.nvim'
Plug 'kosayoda/nvim-lightbulb'

call plug#end()


set termguicolors
syntax on

let g:oceanic_next_terminal_bold = 1
"let g:oceanic_next_terminal_italic = 1
colorscheme OceanicNext

" Transparent backgrounds
"hi Normal guibg=NONE ctermbg=NONE
"hi LineNr guibg=NONE ctermbg=NONE
"hi SignColumn guibg=NONE ctermbg=NONE
"hi EndOfBuffer guibg=NONE ctermbg=NONE
"hi DiffAdd guibg=NONE ctermbg=NONE guifg=#a6cc70
"hi DiffChange guibg=NONE ctermbg=NONE guifg=#77a8d9
"hi DiffDelete guibg=NONE ctermbg=NONE guifg=#f27983
"hi SignifySignAdd guibg=NONE ctermbg=NONE guifg=#a6cc70

let g:airline_theme='oceanicnext'
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#fnamemod = ':t'

set shell=/bin/bash
set updatetime=100

" Enable filetype plugins.
filetype plugin on
filetype indent on

set cursorline
set number " Show line numbers in left gutter
set ruler " Display the current line and column
set showmatch " Highlight matching brackets
set nowrap " Don't soft wrap lines
set noerrorbells visualbell t_vb= " Disable all errorbells
set mouse=a " Enable using the mouse
set signcolumn=number

" Allow modelines at the top or bottom of files.
set modeline
set modelines=5

set inccommand=nosplit

" Enable autocompletion of vim-commands.
set wildmenu
set wildmode=longest:list,full
set wildignore+=*/node_modules/*
set wildignore+=*/bower_components/*

" Use 2 spaces for indentation.
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab

" Don't actually close unsaved buffers, just hide them while
" you edit the other buffer.
set hidden

set nohlsearch " Don't hilight search results
set incsearch " Show search results as you type

set ignorecase
set smartcase

set breakindent

" Use the system clipboard as the default clipboard.
set clipboard=unnamed

" Use an intuitive horizontal scroll
set sidescroll=1

" Persistent undo
set undofile
set undodir=$HOME/.vim/undo//
set undolevels=1000
set undoreload=10000

" Global backup directory
set backupdir=$HOME/.vim/backup//
set directory=$HOME/.vim/backup//

" Define how files are saved in order to support file watchers
set backupcopy=yes


" Use space as the leader key.
let mapleader=" "
let maplocalleader=" "

nnoremap j gj
nnoremap k gk

" Clear highlights
map <leader>c :nohl<CR>

" Easily reload the vim config.
command! Reload so $MYVIMRC
command! Config e $MYVIMRC

" UI fixes

" Allow for saving/quitting with lazy shift key.
command! W w
command! Q q
command! Wq wq
command! WQ wq


" Automatically clear search highlights when entering insert mode.
autocmd InsertEnter * :nohlsearch | redraw

" Make 'yank rest of line' consistent with 'delete' and 'change'.
nnoremap Y y$

inoremap § <ESC>
vnoremap § <ESC>

" Set settings and keymaps for split windows
set splitbelow
set splitright

set laststatus=2 " Always show statusline


function MyNerdToggle()
  if @% == ""
    :NERDTreeToggle
  elseif &filetype == 'nerdtree'
    NERDTreeToggle                      
  else                                    
    NERDTreeFind                        
  endif  
endfunction

nnoremap <leader>e :call MyNerdToggle()<CR>
let NERDTreeQuitOnOpen=1
let NERDTreeShowHidden=1

" Easy movement in quickfix window
noremap <A-n> :cn<CR>
noremap ‘ :cn<CR>
noremap <A-p> :cn<CR>
noremap π :cp<CR>

" Navigate tabs using tab button :D
nnoremap  <silent> <tab>  :if &modifiable && !&readonly && &modified <CR> :write<CR> :endif<CR>:bnext<CR>
nnoremap  <silent> <s-tab>  :if &modifiable && !&readonly && &modified <CR> :write<CR> :endif<CR>:bprevious<CR>


" This needs to work on visible buffers, not actual buffer numbers...
nnoremap <leader>1 :b 1<CR>
nnoremap <leader>2 :b 2<CR>
nnoremap <leader>3 :b 3<CR>
nnoremap <leader>4 :b 4<CR>
nnoremap <leader>5 :b 5<CR>
nnoremap <leader>6 :b 6<CR>
nnoremap <leader>7 :b 7<CR>
nnoremap <leader>8 :b 8<CR>
nnoremap <leader>9 :b 9<CR>
nnoremap <leader>0 :b 10<CR>

nmap <C-K>        <C-U>
nmap <C-J>      <C-D>
nmap <C-H>      z20<Left>
nmap <C-L>     z20<Right>
"
" Additional configs
"
lua require("treesitter")
set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()
set foldlevelstart=1000

lua require("nvim-lspconfig")

lua require("_telescope")

lua require("nvim-compe")
set completeopt=menuone,noselect
set shortmess+=c

lua require('gitsigns').setup()

lua require'hop'.setup()
nnoremap s :HopChar2<CR>

lua require('neoscroll').setup({ cursor_scrolls_alone = false })
lua require('lspsaga').setup()
