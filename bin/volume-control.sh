#!/bin/bash

set -euo pipefail

arg="${1}" # example: toggle-mute, -2 or +2
is_mute="0"

if [[ "$arg" == "toggle-mute" ]]; then
  pulsemixer --toggle-mute
  is_mute=$(pulsemixer --get-mute)
else
  pulsemixer --unmute --change-volume "$arg"
fi

if [[ "$is_mute" == "1" ]]; then
  notify-progress.sh volume-control "0" "Volume" "Muted"
else
  value=$(pulsemixer --get-volume | cut -d ' ' -f 1)
  notify-progress.sh volume-control "$value" "Volume" "Set to $value"
fi
