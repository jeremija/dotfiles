#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
cd $DIR
set -xe
python3 -m venv env
env/bin/pip install --upgrade neovim
