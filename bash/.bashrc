# .bashrc
set +x
PROMPT_COMMAND=""

# Determine where this script actually lives
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

# Pull in handy-dandy bash functions
if [[ -f $DIR/.bash_functions ]]; then
    . $DIR/.bash_functions
else
    echo "$DIR/.bash_functions not found"
fi

# Do includes
include_if_exists /etc/bashrc true
include_if_exists $DIR/.bash_aliases
include_if_exists $DIR/.terminal_colors
include_if_exists $DIR/.bashrc_$(hostname -s) 

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

# Swap escape and caps lock
if is_linux && [ -n "$DISPLAY" ] ; then
    if hash setxkbmap 2>/dev/null; then
        setxkbmap -option caps:swapescape
    else
        echo "Cannot swap escape and caps"
    fi
fi

# Prompt coloring
PROMPT_COMMAND="set_bash_prompt;$PROMPT_COMMAND"
export PS2="$ "

PATH="/Users/jonathan/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/Users/jonathan/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/Users/jonathan/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/Users/jonathan/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/Users/jonathan/perl5"; export PERL_MM_OPT;

# vim mode
set -o vi

