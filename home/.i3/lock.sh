#!/bin/sh

# remember currently set dpms
dpms=$(xset q dpms | grep -E '(Standby|Suspend|Off): [0-9]+' | sed 's/[a-zA-Z: ]\+/ /g')

# set screen timeout
xset dpms 5 5 5

i3lock --nofork -c 004477

# disable screen timeout after unlocking
xset dpms ${dpms}
