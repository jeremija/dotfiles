#!/bin/bash

DIR="$HOME"

if [ $# -ne 1 ]; then
  echo "Invalid number of arguments! Usage: $0 <increment>" 1>&2
  echo "  <increment>     can be positive or negative" 1>&2
  exit 1;
fi;

function save_for_i3_bar {
  echo -n "$1°K" > "$XDG_RUNTIME_DIR/j4status-plugins/inotify/RED"
}

last_val=$(cat "$DIR/.redshift.last" || echo 6500)

if [ "$1" == "reread" ]; then
    redshift -O $last_val;
    save_for_i3_bar $last_val;
    exit 0;
fi

new_val=$(($last_val + $1))
echo "new_val = $last_val + $1 = $new_val"

if [ $last_val -eq $new_val ]; then
  echo "No change -- resetting! Calling 'redshift -x'"
  redshift -x
  echo 6500 > "$DIR/.redshift.last"
  save_for_i3_bar 6500
  exit 0;
fi;

echo "Calling 'redshift -O $new_val'"
redshift -O $new_val
if [ $? -eq 0 ]; then
  echo "Saving $new_val to file..."
  echo $new_val > "$DIR/.redshift.last"
  save_for_i3_bar $new_val
fi
