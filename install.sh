#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR

# make * process both hidden and regular files
shopt -s dotglob

function symlink {
    # echo linking "$1" to "$2"
    ln -sv "$PWD/$1" "$2"
}

function delete_symlink {
    echo unlinking "$1"
    unlink "$1"
}

function link_files {
    echo "processing home folder dotfiles..."
    cd home
    for file in *; do
        if [ "$1" == "unlink" ]; then
            delete_symlink "$HOME/$file"
        else
            symlink "$file" "$HOME"
        fi
    done
    cd ..
}

function link_config {
    echo "processing .config directories..."
    mkdir -p ~/.config
    cd config
    for dir in *; do
        if [ "$1" == "unlink" ]; then
            delete_symlink "$HOME/.config/$dir"
        else
            symlink "$dir" "$HOME/.config"
        fi
    done
    cd ..
}

function link_app_support {
    echo "processing Library/Application Support (mac-only)..."
    cd Library/Application\ Support
    for dir in *; do
        if [ "$1" == "unlink" ]; then
            delete_symlink "$HOME/Library/Application Support/$dir"
        else
            symlink "$dir" "$HOME/Library/Application Support"
        fi
    done
    cd ../..
}

function link_zprezto {
    echo "processing zprezto..."
    for rcfile in "${HOME}"/.zprezto/runcoms/z*; do
        if [ "$1" == "unlink" ]; then
	    delete_symlink "${HOME}/.$(basename ${rcfile})"
        else
            ln -sv "${rcfile}" "${HOME}/.$(basename ${rcfile})"
        fi
    done
}

function install_dotfiles {
    link_files
    link_config
    link_zprezto
    link_app_support

    mkdir -p "$HOME/scripts/redshift"
    mkdir -p "$HOME/.vim/autoload"
    symlink ./vim-plug/plug.vim "$HOME/.vim/autoload/plug.vim"
    symlink ./redshift/redshift.sh "$HOME/scripts/redshift"
}

function uninstall_dotfiles {
    link_zprezto unlink
    link_files unlink
    link_config unlink
    link_app_support unlink
    delete_symlink "$HOME/.vim/autoload/plug.vim"
    delete_symlink "$HOME/scripts/redshift/redshift.sh"
}

if [ "$1" == "--uninstall" ]; then
    uninstall_dotfiles
else
    install_dotfiles
fi
