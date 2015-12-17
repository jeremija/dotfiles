#!/bin/bash

WIFI_IF=wlp3s0

function get_battery {
    echo "$(acpitool -B | grep 'Remaining' | sed 's/^ *//g' | cut -d ' ' -f 5,6)"
}

function get_wifi {
    iw=$(iwconfig $WIFI_IF)
    conn=$(echo $iw | grep -P -o 'ESSID:".*?"' | sed -r 's/^ESSID:\"(.*)\"$/\1/g')
    quality=$(echo $iw | grep -P -o "Link Quality=.*? " | sed 's/Link Quality=//g')
    quality=$((100 * $quality))

    if [ $quality -gt 80 ]; then
        bars="▂▄▆█"
    elif [ $quality -gt 55 ]; then
        bars="▂▄▆▁"
    elif [ $quality -gt 30 ]; then
        bars="▂▄▁▁"
    elif [ $quality -gt 5 ]; then
        bars="▂▁▁▁"
    else
        bars="▁▁▁▁"
    fi
    echo $conn $bars
}

function get_ip {
    echo $(ip r | grep $WIFI_IF | grep -o 'src .* metric'| \
        sed -r 's/src (.*) metric/\1/g')
}

function get_date {
    echo $(date +"%a %b %_d")
}

function get_datetime {
    echo $(date +"%a %Y-%m-%d %T")
}

function get_memory {
    mem=$(free | tail -n +2 | head -n +1 | sed 's/ \+/ /g')
    used=$(echo $mem | cut -d ' ' -f 3)
    total=$(echo $mem | cut -d ' ' -f 2)
    echo $(echo "scale = 2; $used/$total" | bc -l | sed 's/^\./0./g')
}

function get_load {
    echo $(uptime | sed 's/^.*: //g' | cut -d ',' -f 1)
}

function format_notification {
    echo "Date:    $(get_date)"
    echo "Battery: $(get_battery)"
    echo "Wi-Fi:   $(get_wifi)"
    echo "         $(get_ip)"
    echo "Memory:  $(get_memory)"
    echo "Load:    $(get_load)"
}

function format_bar {
    echo "%{r} $(get_wifi) |  $(get_memory) | $(get_load) | $(get_battery) | $(get_datetime)"
}

if [ "$1" == "--notify" ]; then
    notify-send $(date +"%H:%M:%S") "$(format_notification)"
elif [ "$1" == "--bar" ]; then
    echo -e "$(format_bar)"
else
    echo -e "$(format_notification)"
fi
