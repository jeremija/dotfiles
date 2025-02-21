#!/bin/bash

set -euo pipefail

arg="${1}" # example: 2%-

value=$(brightnessctl s "$arg" | grep -o '[0-9]\+%' | cut -d '%' -f 1)

notify-progress.sh brightness-control "$value" "Brightness" "Set to $value"
