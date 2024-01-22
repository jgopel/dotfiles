# shellcheck shell=bash

set +x
PROMPT_COMMAND=""

# Determine where this script actually lives
SOURCE="${BASH_SOURCE[0]}"
RESOLVED_SOURCE="$(realpath "${SOURCE}")"
DIR="$(dirname "${RESOLVED_SOURCE}")"

# Pull in handy-dandy bash functions
if [[ -f $DIR/functions.sh ]]; then
    # shellcheck disable=1091
    . "$DIR/functions.sh"
else
    echo "$DIR/functions.sh not found"
fi

# Do includes
include_if_exists /etc/bashrc true
include_if_exists "$DIR/.bash_aliases"
include_if_exists "$DIR/terminal_colors.sh"
include_if_exists "$DIR/.bashrc_$(hostname -s)"

# Remove need to type cd
shopt -s autocd
shopt -s cdspell
alias -- -="cd -"

# Extend history to 10 billion entries, don't store duplicates, and write
# out immediately so that commands are available across terminals
export HISTFILESIZE=
export HISTSIZE=
export HISTCONTROL=ignoreboth:ignoredups
shopt -s histappend
PROMPT_COMMAND="history -a;$PROMPT_COMMAND"

# Environment settings
export SVN_EDITOR=vim
export VISUAL=vim
export EDITOR=vim
export CSCOPE_EDITOR=vim
export TZ='America/Denver'

# Python cache directory
export PYTHONPYCACHEPREFIX="$HOME/.cache/cpython/"

# Swap escape and caps lock
if is_linux && [ -n "$DISPLAY" ] ; then
    if hash setxkbmap 2>/dev/null; then
        setxkbmap -option caps:escape
    else
        echo "Cannot make capslock escape"
    fi
fi

# Prompt coloring
PROMPT_COMMAND="set_bash_prompt;$PROMPT_COMMAND"
export PS2="$ "

# vim mode
set -o vi

# Use FZF for reverse search
# shellcheck disable=1090
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
