#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DIR"

# make * process both hidden and regular files
shopt -s dotglob

mode="$1"

function symlink {
    if [ "$mode" != "--uninstall" ]; then
        ln -nsv "$PWD/$1" "$2"
    else
        rm -v "$2"
    fi
}

function title {
    echo ""
    echo == $@ ==
}

function link_files {
    src="$1"
    target="$2"
    glob="${3:-*}"
    prefix="$4"
    title "$src"
    cd "$src"
    for file in $glob; do
        symlink "$file" "$target/$prefix$file"
    done
    cd "$DIR"
}

link_files home "$HOME"
link_files config "$HOME/.config"
link_files home/.zprezto/runcoms "$HOME" "z*" "."
link_files "Library/Application Support" "$HOME/Library/Application Support"

title "scripts"
mkdir -pv "$HOME/scripts/redshift"
symlink redshift/redshift.sh "$HOME/scripts/redshift/redshift.sh"

title ".vim"
mkdir -pv "$HOME/.vim/autoload"
symlink vim-plug/plug.vim "$HOME/.vim/autoload/plug.vim"

title 'done'
