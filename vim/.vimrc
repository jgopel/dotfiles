" Basic environment variables
set number
set relativenumber
set ruler
set autoindent
set smartindent
set cindent
set wrap
set linebreak
set mouse=a
syntax on

" Setup tab depth 4 of soft tabs
set tabstop=8
set softtabstop=0
set shiftwidth=2
set expandtab
set smarttab

" Line at column 80
set colorcolumn=81

" Strip trailing whitespace
autocmd FileType c,cpp,python autocmd BufWritePre <buffer> %s/\s\+$//e

" Colors
colorscheme luna-term

" Shortcuts
nmap <F12> :set invrelativenumber<CR>

" Filetype specifc overrides
autocmd FileType gitcommit setlocal textwidth=72
autocmd FileType gitcommit setlocal colorcolumn=+1
autocmd FileType gitcommit setlocal colorcolumn+=51 " Title width

