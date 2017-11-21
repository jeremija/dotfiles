#!/bin/bash

function resize () {
  x=$(( 82 * $1 + ($1 - 1) ))
  tmux resize -x $x
}

func=$1
shift
args=$@

if [ "$(type -t $func)" != 'function' ]; then
  echo "Argument '$func' is not a function" 1>&2
  exit 1
fi

$func $args
