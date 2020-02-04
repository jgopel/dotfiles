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
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'preservim/nerdcommenter'
Plugin 'preservim/nerdtree'
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

" Configure autosave plugin
let g:auto_save = 1
let g:auto_save_in_insert_mode = 0  " do not save while in insert mode

" Configure CtrlP
let g:ctrlp_cmd = 'CtrlPMixed'

" Configure NERDcommenter
let g:NERDSpaceDelims = 1
let g:NERDTrimTrailingWhitespace = 1

" Code file settings
autocmd FileType c,cpp,python autocmd BufWritePre <buffer> %s/\s\+$//e " Strip trailing whitespace

" Colors
colorscheme luna-term

" Shortcuts
map <C-n> :NERDTreeFind<CR>

nmap <F12> :set invrelativenumber<CR>

autocmd FileType c,cpp nnoremap <buffer><Leader>cf :<C-u>ClangFormat<CR>
autocmd FileType c,cpp vnoremap <buffer><Leader>cf :ClangFormat<CR>

nnoremap <leader>gl :YcmCompleter GoToDeclaration<CR>
nnoremap <leader>gf :YcmCompleter GoToDefinition<CR>
nnoremap <leader>gg :YcmCompleter GoToDefinitionElseDeclaration<CR>

" Filetype specifc overrides
autocmd FileType gitcommit setlocal textwidth=72
autocmd FileType gitcommit setlocal colorcolumn=+1
autocmd FileType gitcommit setlocal colorcolumn+=51 " Title width

