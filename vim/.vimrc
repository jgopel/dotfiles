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
Plugin 'damage220/vim-finder'
Plugin 'embear/vim-localvimrc'
Plugin 'godlygeek/tabular.git'
Plugin 'preservim/nerdcommenter'
Plugin 'preservim/nerdtree'
Plugin 'psf/black'
Plugin 'rhysd/vim-clang-format'
Plugin 'tpope/vim-surround'
Plugin 'vim-airline/vim-airline'
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

syntax on

" Setup tab depth
set tabstop=8
set softtabstop=0
set shiftwidth=2

set expandtab
set smarttab

" Line after column 80
set colorcolumn=81

" Colors
colorscheme luna-term

" Configure autosave
let g:auto_save = 1
let g:auto_save_in_insert_mode = 0

" Configure NERDcommenter
let g:NERDSpaceDelims = 1
let g:NERDTrimTrailingWhitespace = 1

" Comfigure YouCompleteMe
let g:ycm_add_preview_to_completeopt = 1
let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_autoclose_preview_window_after_insertion = 1

" General purpose shortcuts
map <C-n> :NERDTreeFind<CR>
map <C-p> :Files<CR>

nmap <F12> :set invrelativenumber<CR>

nnoremap <leader>gl :YcmCompleter GoToDeclaration<CR>
nnoremap <leader>gf :YcmCompleter GoToDefinition<CR>
nnoremap <leader>gg :YcmCompleter GoToDefinitionElseDeclaration<CR>

" C/C++ settings
autocmd FileType c,cpp autocmd BufWritePre <buffer> %s/\s\+$//e

autocmd FileType c,cpp nnoremap <buffer><Leader>cf :<C-u>ClangFormat<CR>
autocmd FileType c,cpp vnoremap <buffer><Leader>cf :ClangFormat<CR>

" Cmake settings
autocmd FileType cmake autocmd BufWritePre <buffer> %s/\s\+$//e

" Cucumber settings
autocmd FileType cucumber autocmd BufWritePre <buffer> %s/\s\+$//e

autocmd FileType cucumber map <Tab> :Tabularize /\|<CR>

" Git settings
autocmd FileType gitcommit setlocal textwidth=72
autocmd FileType gitcommit setlocal colorcolumn=+1
autocmd FileType gitcommit setlocal colorcolumn+=51 " Title width

" Haskell settings
autocmd FileType haskell autocmd BufWritePre <buffer> %s/\s\+$//e

" Markdown settings
autocmd FileType markdown autocmd BufWritePre <buffer> %s/\s\+$//e

autocmd FileType markdown map <Tab> :Tabularize /\|<CR>

" Python settings
autocmd FileType python autocmd BufWritePre <buffer> %s/\s\+$//e

autocmd FileType python nnoremap <buffer><Leader>cf :Black<CR>

" VimFile settings
autocmd FileType vim autocmd BufWritePre <buffer> %s/\s\+$//e

