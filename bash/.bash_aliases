LS_PATH="ls"
LS_PARAMS="-F"
GNU_LS_PARAMS="$LS_PARAMS --ignore-backups --color --group-directories-first --human-readable"

if is_linux; then
    LS_PARAMS=$GNU_LS_PARAMS
elif is_osx; then
    LS_PARAMS=$GNU_LS_PARAMS
    LS_PATH="$(/opt/homebrew/bin/brew --prefix coreutils)/bin/gls"
fi

alias sudo="sudo "

alias ls="$LS_PATH $LS_PARAMS"
alias ll="ls -l"
alias la="LC_COLLATE=C ls -A"
alias lla="la -l"

alias grep="grep --color=auto"

alias gdb="gdb -silent"
alias cscope="cscope -qR"
alias refresh="source ~/.bashrc"

alias sudol="sudo -E"
