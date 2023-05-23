# shellcheck shell=bash

LS_PATH='ls'
LS_PARAMS='-F'
GNU_LS_PARAMS="$LS_PARAMS --ignore-backups --color --group-directories-first --human-readable"

if is_linux; then
    LS_PARAMS=$GNU_LS_PARAMS
elif is_osx; then
    LS_PARAMS=$GNU_LS_PARAMS
    LS_PATH="$(brew --prefix coreutils)/bin/gls"
fi

alias ls='$LS_PATH $LS_PARAMS'
alias ll='ls -l'
alias la='LC_COLLATE=C ls -A'
alias lla='la -l'

alias grep='grep --color=auto'

alias gdb='gdb -silent'
alias cscope='cscope -qR'
alias refresh='source ~/.bashrc'

alias sudol='sudo -E'

alias pr='poetry run'

alias link-lvimrc='ln -s ~/dotfiles/vim/default-lvimrc .lvimrc'
