#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
cd $DIR
set -xe
virtualenv -p python2 env
env/bin/pip install --upgrade neovim
