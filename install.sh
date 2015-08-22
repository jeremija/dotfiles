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

function delete_symlink {
    echo unlinking "$1"
    unlink "$1"
}

function link_files {
    echo "processing home folder dotfiles..."
    for file in $(cat ./home_symlinks); do
        if [ "$1" == "unlink" ]; then
            delete_symlink "$HOME/$file"
        else
            symlink "$file" "$HOME"
        fi
    done
}

function link_config {
    echo "processing .config directories..."
    mkdir -p ~/.config
    for dir in $(ls .config); do
        if [ "$1" == "unlink" ]; then
            delete_symlink "$HOME/.config/$dir"
        else
            symlink ".config/$dir" "$HOME/.config"
        fi
    done
}

function install_dotfiles {
    install_oh_my_zsh
    link_files
    link_config
}

function uninstall_dotfiles {
    link_files "unlink"
    link_config "unlink"
}

if [ "$1" == "--uninstall" ]; then
    uninstall_dotfiles
else
    install_dotfiles
fi
