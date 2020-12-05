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
mkdir -pv "$HOME/bin"
link_files bin "$HOME/bin"
mkdir -pv "$HOME/.config"
link_files config "$HOME/.config"
link_files home/.zprezto/runcoms "$HOME" "z*" "."
link_files "Library/Application Support" "$HOME/Library/Application Support"

title "Not setting up python virtualenvs for neovim"
echo
echo "if you wish to install them in manually, run:"
echo
echo    \$HOME/.config/nvim/python2/setup.sh
echo    \$HOME/.config/nvim/python3/setup.sh
echo
echo "Note that python2 is deprecated."
echo "On linux it is preferred to install python-neovim."

title 'done'
