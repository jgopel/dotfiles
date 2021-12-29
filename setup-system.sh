#!/bin/bash -x

set -euo pipefail

BACKUP_DIR=~/.dotfiles-backup/$(date --iso-8601=seconds)

mkdir -p $BACKUP_DIR

cd ~

[ -f .bashrc ] && mv .bashrc $BACKUP_DIR
[ -f .bash_profile ] && mv .bash_profile $BACKUP_DIR
ln -s dotfiles/bash/.bashrc
ln -s dotfiles/bash/.bash_profile

[ -d bin ] && mv bin $BACKUP_DIR
ln -s dotfiles/bin

[ -f .ctags ] && mv .ctags $BACKUP_DIR
ln -s dotfiles/ctags/.ctags

if [ "$(uname)" == "Darwin" ]; then
    # TODO: Support MacOS
    exit 1
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    mkdir -p .fonts
    cp dotfiles/fonts/* .fonts
    fc-cache -f -v
fi

[ -f .gitconfig ] && mv .gitconfig $BACKUP_DIR
[ -f .gitignore_global ] && mv .gitignore_global $BACKUP_DIR
ln -s dotfiles/git/.gitconfig
ln -s dotfiles/git/.gitignore_global


[ -f .tmux.conf ] && mv .tmux.conf $BACKUP_DIR
ln -s dotfiles/tmux/.tmux.conf

[ -f .vimrc ] && mv .vimrc $BACKUP_DIR
ln -s dotfiles/vim/.vimrc
dotfiles/bin/setup-vim
