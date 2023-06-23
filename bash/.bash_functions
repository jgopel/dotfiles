# Git branch prompt
set_bash_prompt() {
    PROMPT="[$GREEN\u$END_COLOR@$RED\h$END_COLOR $CYAN\w$END_COLOR] "
    if is_git_repository; then
        PROMPT="$PROMPT$YELLOW($(git_branch))$END_COLOR\n"
    fi
    if [ -n "${PIPENV_ACTIVE}" ]; then
        PROMPT="$PROMPT(pipenv) "
    fi
    if [ -n "${POETRY_ACTIVE}" ]; then
        PROMPT="$PROMPT(poetry) "
    fi

    export PS1="$PROMPT\$ "
}
is_git_repository() {
    git branch > /dev/null 2>&1
}
git_branch() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        return 0
    fi

    echo $(git branch 2>/dev/null | sed -n '/^\*/s/^\* //p')
}

include_if_exists() {
    if [ -f $1 ]; then
        . $1
        return 0
    elif [ "$2" = true ] ; then
        return 0
    else
        echo $1 not found
        return 1
    fi
}

is_linux() {
    [[ $OSTYPE == linux-gnu ]]
}

is_osx() {
    [[ $OSTYPE == darwin* ]]
}

# https://superuser.com/questions/39751/add-directory-to-path-if-its-not-already-there
pathappend() {
  for ARG in "$@"
  do
    if [ -d "$ARG" ] && [[ ":$PATH:" != *":$ARG:"* ]]; then
        PATH="${PATH:+"$PATH:"}$ARG"
    fi
  done
}
pathprepend() {
  for ((i=$#; i>0; i--));
  do
    ARG=${!i}
    if [ -d "$ARG" ] && [[ ":$PATH:" != *":$ARG:"* ]]; then
        PATH="$ARG${PATH:+":$PATH"}"
    fi
  done
}
