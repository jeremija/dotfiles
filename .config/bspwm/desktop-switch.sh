#!/bin/bash

desktops=$(bspc query --desktops)

function get_desktops {
    index=0
    for desktop in $desktops; do
        index=$(($index + 1))
        window_ids=$(bspc query --windows --desktop "$desktop")

        if [ "$window_ids" == "" ]; then
            win_count=0
        else
            win_count=$(echo -e "$window_ids" | wc -l)
        fi

        if [ $win_count -gt 1 ]; then
            label="($win_count windows)"
        elif [ $win_count -gt 0 ]; then
            name=$(ps -o comm= -p $(xprop -id $window_ids _NET_WM_PID | \
                sed -r 's/.* = (.*)/\1/g'))
            label=$(xtitle "$window_ids")
            label="$name - $label"
        else
            label=""
        fi

        echo $index. $label
    done
}

function get_current_desktop {
    current_desktop="$(bspc query -D -d)"
    index=-1
    for desktop in $desktops; do
        index=$(($index + 1))
        if [ "$desktop" == "$current_desktop" ]; then
            echo $index
            break
        fi
    done
}

function show_desktop_switcher {
    current_desktop=$(get_current_desktop)
    next_desktop=$(echo -n "$(get_desktops)" | \
        rofi -dmenu -p "desktop:" -l $current_desktop)
    if [ $? -ne 0 ]; then
        return 1
    fi
    bspc desktop -f "^$next_desktop"
}

show_desktop_switcher
