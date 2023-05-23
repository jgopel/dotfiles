# shellcheck shell=bash

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
    # shellcheck disable=1090
    . ~/.bashrc
else
    echo "$HOME/.bashrc not found"
fi

# User specific environment and startup programs

PATH=$PATH:$HOME/bin

export PATH
