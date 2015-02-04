#!/usr/bin/env bash

WINDOW_TITLES=$(wmctrl -l | grep -v "\-1" | sed -r 's/([^ ]+ +){3}(.*)/\2/g')

WINDOW_SELECTION=$(zenity --entry --title="Choose a Window" --text="${WINDOW_TITLES}")

DESKTOP_NUMBER=$(wmctrl -l | grep -v "\-1" |grep -m 1 ${WINDOW_SELECTION} | sed -r 's/^[^ ]+ +([^ ]+) .*/\1/g')

xdotool search --desktop ${DESKTOP_NUMBER} --name ${WINDOW_SELECTION} windowactivate