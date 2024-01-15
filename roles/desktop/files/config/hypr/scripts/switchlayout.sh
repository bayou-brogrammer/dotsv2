#!/usr/bin/env sh

LAYOUT=$(hyprctl getoption general:layout -j | jq -r '.str')

echo $LAYOUT

if [ "$LAYOUT" = "dwindle" ]; then
    notif=" Layout set to master..."
    hyprctl keyword general:layout "master"
else
    notif=" Layout set to dwindle..."
    hyprctl keyword general:layout "dwindle"
fi

dunstify "t1" -a "$notif" -i "~/.config/dunst/icons/hyprdots.png" -r 91190 -t 2200
