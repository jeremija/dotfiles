#!/bin/sh

session=${session:-startplasma-x11}

case $session in
  startplasma-x11)
    export DESKTOP_SESSION=KDE
    ;;
  startxfce4)
    export DESKTOP_SESSION=xfce
    ;;
esac

export XDG_CURRENT_DESKTOP=$DESKTOP_SESSION

source ~/.xprofile

if [ "$session" == "bspwm" ]; then
    # run sxhkd (hotkeys for bspwm)
    sxhkd &
fi

exec $session
