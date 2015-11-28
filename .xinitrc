# set defaults
export EDITOR=vim
export VISUAL=vim
export SUDO_EDITOR=$EDITOR
export TERMINAL=termite
export BROWSER=google-chrome-unstable
export QT_STYLE_OVERRIDE=GTK+
export XDG_CONFIG_HOME="$HOME/.config"
export $(dbus-launch)

# read .Xresources file
xrdb -m ~/.Xresources
xmodmap ~/.Xmodmap

# set default mouse cursor
xsetroot -cursor_name left_ptr
# mouse sensitivity
xset m 5 1
# keyboard repeat rate
xset r rate 200 100
# disable touchpad
xinput set-int-prop "SynPS/2 Synaptics TouchPad" "Device Enabled" 8 0
# set scroll with right mouse button, instead of the first
xinput set-prop "TPPS/2 IBM TrackPoint" "libinput Button Scrolling Button" 3
# enable network manager and bluetooth applets
nm-applet &
blueman-applet &
# compositing manager
compton --backend glx &

# disable screen blanking
xset dpms 0 0 0
xset s off

# restore wallpaper
nitrogen --restore

# start daemons for monitor and volume keys
xfce4-volumed-pulse

# gnome-keyring-daemon
# eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh,gpg)
eval $(ssh-agent)
export SSH_AUTH_SOCK

~/scripts/redshift/redshift.sh reread

# run xbindkeys
xbindkeys

session=${session-i3}

if [ "$session" == "bspwm" ]; then
    # run sxhkd (hotkeys for bspwm)
    sxhkd &
fi

exec $session
