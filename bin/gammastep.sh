#!/bin/bash

DIR="$HOME"

if [ $# -lt 1 ]; then
  echo "Invalid number of arguments! Usage: $0 <red_increment> <bri_up_down>" 1>&2
  echo "  <red_increment>     increment of red value, pos or neg" 1>&2
  echo "  <increment>         increment of brightness, 0.1 - 1.0" 1>&2
  exit 1;
fi;

redshift_cmd="gammastep"

arg_two=$2
if [ "$arg_two" == "" ]; then
  arg_two="0"
fi

function save_for_i3_bar {
  mkdir -p "$XDG_RUNTIME_DIR/j4status-plugins/inotify"
  echo -n "$1°K $2" > "$XDG_RUNTIME_DIR/j4status-plugins/inotify/RED"
}

last_values=$(cat "$DIR/.redshift.last" || echo 6500 1.0)
last_red=$(echo $last_values | cut -d ' ' -f 1)
last_bri=$(echo $last_values | cut -d ' ' -f 2)

killall $redshift_cmd

if [ "$1" == "reread" ]; then
    $redshift_cmd -O $last_red -b $last_bri &
    save_for_i3_bar $last_red $last_bri;
    exit 0;
fi

new_red=$(($last_red + $1))

new_bri=$(echo "scale=2; $last_bri + $arg_two" | bc)

bri_too_big=$(echo "scale=2; $new_bri > 1.0" | bc)
bri_too_small=$(echo "scale=2; $new_bri < 0.1" | bc)
bri_equal=$(echo "scale=2; $new_bri == $last_bri" | bc)

if [ $bri_too_big -gt 0 ]; then
  new_bri=1.0
elif [ $bri_too_small -gt 0 ]; then
  new_bri=0.1
fi


# echo "new_red = $last_red + $1 = $new_red"
# echo "new_bri = $last_bri + $2 = $new_bri"

echo red $last_red $new_red
echo bri $last_bri $new_bri
if [ $last_red -eq $new_red ] && [ $bri_equal -eq 1 ]; then
  echo "No change -- resetting! Calling 'redshift -x'"
  echo 6500 1.0 > "$DIR/.redshift.last"
  save_for_i3_bar 6500 1.0
  exit 0;
fi;

echo "Calling 'redshift -P -O $new_red -b $new_bri'"
$redshift_cmd -P -O $new_red -b $new_bri &
if [ $? -eq 0 ]; then
  echo "Saving $new_red $new_bri to file..."
  echo $new_red $new_bri > "$DIR/.redshift.last"
  save_for_i3_bar $new_red $new_bri
fi
