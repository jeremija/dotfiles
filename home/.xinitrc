#!/bin/sh

source ~/.xprofile

session=${session:-i3}

if [ "$session" == "bspwm" ]; then
    # run sxhkd (hotkeys for bspwm)
    sxhkd &
fi

exec $session
