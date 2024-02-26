" Vundle bootstrap and configuration
if !filereadable($HOME . '/.vim/bundle/Vundle.vim/.git/config') && confirm("Clone Vundle?","Y\nn") == 1
    exec '!git clone https://github.com/gmarik/Vundle.vim ~/.vim/bundle/Vundle.vim/'
    exec '!vim +PluginInstall +qall'
endif
set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'

" Vundle plugin list
Plugin 'Valloric/YouCompleteMe'
Plugin 'airblade/vim-gitgutter'
Plugin 'bkad/CamelCaseMotion'
Plugin 'dense-analysis/ale'
Plugin 'embear/vim-localvimrc'
Plugin 'godlygeek/tabular.git'
Plugin 'jszakmeister/vim-togglecursor'
Plugin 'junegunn/fzf'
Plugin 'junegunn/fzf.vim'
Plugin 'preservim/nerdcommenter'
Plugin 'preservim/nerdtree'
Plugin 'tpope/vim-abolish'
Plugin 'tpope/vim-surround'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-scripts/Tabmerge'
Plugin 'vim-scripts/argtextobj.vim'
Plugin 'vim-scripts/vim-auto-save'

" Colors
Plugin 'notpratheek/vim-luna'

" Vundle end
call vundle#end()
filetype plugin indent on

" Basic environment variables
set number
set relativenumber

set ruler

set autoindent
set smartindent
set cindent

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

syntax on

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
colorscheme luna-term

" General purpose shortcuts
noremap <F10> :set invspell<CR>
noremap <F11> :set invpaste<CR>
noremap <F12> :set invrelativenumber<CR>

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

" Cucumber settings
autocmd FileType cucumber setlocal spell
autocmd FileType cucumber autocmd BufWritePre <buffer> %s/\s\+$//e

autocmd FileType cucumber map <Tab> :Tabularize /\|<CR>

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

autocmd FileType markdown map <Tab> :Tabularize /\|<CR>

" Shell settings
autocmd FileType sh autocmd BufWritePre <buffer> %s/\s\+$//e

" VimFile settings
autocmd FileType vim autocmd BufWritePre <buffer> %s/\s\+$//e
