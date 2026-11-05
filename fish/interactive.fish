alias ls 'ls -F --ignore-backups --color --group-directories-first --human-readable'
alias ll 'ls -l'
alias la 'LC_COLLATE=C ls -A'
alias lla 'la -l'
alias refresh 'source ~/.config/fish/config.fish'
alias tmux 'tmux -u'
alias sudol 'sudo -E'

# Add ~/bin to PATH
fish_add_path -g $HOME/bin

# et (eternal-terminal) completions - wraps ssh for host/user completions
complete -c et --wraps ssh

# Continuation prompt
set -g fish_prompt_pwd_dir_length 0
