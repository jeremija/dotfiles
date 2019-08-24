#!/bin/bash

function resize () {
  x=$(( 82 * $1 + ($1 - 1) ))
  tmux resize -x $x
}

function move-pane() {
  target=$1

  win_exists=$(tmux list-windows -F '#I' | grep "^$target\$" | wc -l)
  panes=$(tmux list-panes -F '#D' | wc -l)

  if [ $win_exists -eq 1 ]; then
    tmux move-pane -t $target.
  elif [ $panes -eq 1 ]; then
    tmux move-window -t $target
  else
    tmux break-pane -t $target.
  fi
}

func=$1
shift
args=$@

if [ "$(type -t $func)" != 'function' ]; then
  echo "Argument '$func' is not a function" 1>&2
  exit 1
fi

$func $args
