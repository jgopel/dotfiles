#!/bin/bash

set -euo pipefail

BACKUP_DIR=~/.dotfiles-backup/$(date -u +'%Y-%m-%dT%H:%M:%S%z')

backup_and_replace() {
    [ -f "$1" ] && mv "$1" "$BACKUP_DIR"
    ln -s "$2" "$1"
}

mkdir -p "$BACKUP_DIR"

cd ~

# Detect OS
is_macos=false
is_linux=false
is_ubuntu=false
if [ "$(uname)" == "Darwin" ]; then
    is_macos=true
elif [ "$(uname -s)" == "Linux" ]; then
    is_linux=true
    linux_release=$(cat /etc/*-release | grep DISTRIB_ID | cut -c 12-)
    if [ "$linux_release" == "Ubuntu" ]; then
        is_ubuntu=true
    fi
fi

echo "Installing packages"
if [ "$is_macos" = true ]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew install "$(cat dotfiles/osx/packages)"
elif [ "$is_ubuntu" = true ]; then
    sudo apt-get -qq install --yes $(cat dotfiles/ubuntu/packages | tr '\n' ' ')
else
    echo "Package installation not supported on this platform"
    exit 1
fi

echo "Setting up shell - old files backed up in $BACKUP_DIR"
if [ "$is_macos" = true ]; then
    SHELLS_FILE=/etc/shells
    BREW_BASH_LOCATION=$(brew --prefix bash)/bin/bash
    sudo grep -qxF "$BREW_BASH_LOCATION" /etc/shells || echo "$BREW_BASH_LOCATION" | sudo tee -a $SHELLS_FILE
    chsh -s "$BREW_BASH_LOCATION"
fi
backup_and_replace .bashrc dotfiles/bash/.bashrc
backup_and_replace .bash_profiles dotfiles/bash/.bash_profiles
backup_and_replace .inputrc dotfiles/bash/.inputrc
backup_and_replace .editrc dotfiles/bash/.editrc

[ -d bin ] && mv bin "$BACKUP_DIR"
ln -s dotfiles/bin .

backup_and_replace .ctags dotfiles/ctags/.ctags

echo "Installing fonts"
if [ "$is_macos" = true ]; then
    cp dotfiles/fonts/* ~/Library/Fonts
elif [ "$is_linux" = true ]; then
    if which fc-cache > /dev/null; then
        mkdir -p ~/.fonts
        cp dotfiles/fonts/* ~/.fonts
        fc-cache -f
    fi
else
    echo "Font installation not supported on this platform"
    exit 1
fi

echo "Setting up git"
[ -f .gitconfig ] && mv .gitconfig "$BACKUP_DIR"
[ -f .gitignore_global ] && mv .gitignore_global "$BACKUP_DIR"
backup_and_replace .gitconfig dotfiles/git/.gitconfig
backup_and_replace .gitignore_global dotfiles/git/.gitignore_global

echo "Setting up tmux"
backup_and_replace .tmux.conf dotfiles/tmux/.tmux.conf

echo "Setting up vim"
backup_and_replace .vimrc dotfiles/vim/.vimrc
dotfiles/bin/setup-vim

echo "System ready for use"
