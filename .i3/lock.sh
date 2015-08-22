#!/bin/sh

# set screen timeout
xset dpms 5 5 5

i3lock --nofork -c 002222

# disable screen timeout after unlocking
xset dpms 0 0 0
