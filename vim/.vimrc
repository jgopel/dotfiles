" VimPlug bootstrap
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()

Plug 'Valloric/YouCompleteMe', { 'do': './install.py --clangd-completer --rust-completer' }
Plug 'airblade/vim-gitgutter'
Plug 'bkad/CamelCaseMotion'
Plug 'dense-analysis/ale'
Plug 'embear/vim-localvimrc'
Plug 'godlygeek/tabular'
Plug 'jszakmeister/vim-togglecursor'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'preservim/nerdcommenter'
Plug 'preservim/nerdtree'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-surround'
Plug 'vim-airline/vim-airline'
Plug 'vim-scripts/Tabmerge'
Plug 'vim-scripts/argtextobj.vim'
Plug 'vim-scripts/vim-auto-save'

" Colors
Plug 'sainnhe/sonokai'

call plug#end()

" Basic environment variables
set nocompatible

syntax on

set number
set relativenumber

set ruler

set autoindent
set smartindent
filetype indent on

set wrap
set linebreak

set hlsearch
set ignorecase
set smartcase

set mouse=a

set splitright
set splitbelow

set backspace=indent,eol,start
set encoding=utf-8

" Setup tab depth
set tabstop=8
set softtabstop=0
set shiftwidth=2

set expandtab
set smarttab

autocmd FileType python setlocal shiftwidth=4

" Line after column 80
set colorcolumn=81

" cursor shape
if &term =~? 'screen-' || &term =~? 'xterm-'
  let g:togglecursor_force = 'xterm'
endif

" Colors
let g:sonokai_style = 'default'
let g:sonokai_better_performance = 1

let g:sonokai_spell_foreground = 1
let g:sonokai_disable_italic_comment = 1

colorscheme sonokai
let g:airline_theme = 'sonokai'

" General purpose shortcuts
noremap <F10> :set invspell<CR>
noremap <F11> :set invpaste<CR>
noremap <F12> :set invrelativenumber<CR>

map <up> <C-w><up>
map <down> <C-w><down>
map <left> <C-w><left>
map <right> <C-w><right>

" Configure ALE
let g:ale_change_sign_column_color = 1
let g:ale_lint_on_insert_leave = 1
let g:ale_linters_explicit = 1

nnoremap <Leader>cf :ALEFix<CR>
nnoremap <leader>an :ALENext<CR>
nnoremap <leader>ap :ALEPrev<CR>

" Configure autosave
let g:auto_save = 1
let g:auto_save_in_insert_mode = 0

" Configure CamelCaseMotion
let g:camelcasemotion_key = '<leader>'

" Configure localvimrc
let g:localvimrc_persistent = 1

" Configure NERDTree
noremap <C-n> :NERDTreeFind<CR>

" Configure NERDcommenter
let g:NERDCustomDelimiters = {
    \ 'python': {'left': '#'}
\ }

let g:NERDCommentEmptyLines = 1
let g:NERDSpaceDelims = 1
let g:NERDTrimTrailingWhitespace = 1

" Configure fzf
noremap <C-p> :GitFiles<CR>
noremap <leader>p :Files<CR>

" Configure YouCompleteMe
let g:ycm_auto_hover = ''
let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_autoclose_preview_window_after_insertion = 1

nmap <leader>d <plug>(YCMHover)

nnoremap <leader>gl :YcmCompleter GoToDeclaration<CR>
nnoremap <leader>gf :YcmCompleter GoToDefinition<CR>
nnoremap <leader>gg :YcmCompleter GoToDefinitionElseDeclaration<CR>

nnoremap <leader>vgl :vsplit \| YcmCompleter GoToDeclaration<CR>
nnoremap <leader>vgf :vsplit \| YcmCompleter GoToDefinition<CR>
nnoremap <leader>vgg :vsplit \| YcmCompleter GoToDefinitionElseDeclaration<CR>

" Cucumber settings
autocmd FileType cucumber setlocal spell
autocmd FileType cucumber autocmd BufWritePre <buffer> %s/\s\+$//e

autocmd FileType cucumber map <leader><Tab> :Tabularize /\|<CR>

" Git settings
autocmd FileType gitcommit setlocal spell
autocmd FileType gitcommit setlocal textwidth=72
autocmd FileType gitcommit setlocal colorcolumn=+1
autocmd FileType gitcommit setlocal colorcolumn+=51 " Title width

" Groovy settings
autocmd BufRead,BufNewFile Jenkinsfile set filetype=groovy
autocmd FileType groovy autocmd BufWritePre <buffer> %s/\s\+$//e

" Haskell settings
autocmd FileType haskell autocmd BufWritePre <buffer> %s/\s\+$//e

" Markdown settings
autocmd FileType markdown setlocal spell
autocmd FileType markdown autocmd BufWritePre <buffer> %s/\s\+$//e

autocmd FileType markdown map <leader><Tab> :Tabularize /\|<CR>

" Shell settings
autocmd FileType sh autocmd BufWritePre <buffer> %s/\s\+$//e

" VimFile settings
autocmd FileType vim autocmd BufWritePre <buffer> %s/\s\+$//e
