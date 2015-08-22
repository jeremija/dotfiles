#!/bin/bash

function install_oh_my_zsh {
    echo "installing oh-my-zsh..."
    if [ ! -d ~/.oh-my-zsh ]; then
        sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    else
        echo "zsh already installed"
    fi
}

function symlink {
    echo linking "$1" to "$2"
    ln -sr "$1" "$2"
}

function link_files {
    echo "processing home folder dotfiles..."
    for file in $(cat ./home_symlinks); do
        symlink "$file" "$HOME"
    done
}

function link_config {
    echo "processing .config directories..."
    mkdir -p ~/.config
    for dir in $(ls .config); do
        symlink ".config/$dir" "$HOME/.config"
    done
}

install_oh_my_zsh
link_files
link_config
