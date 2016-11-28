#!/usr/bin/env bash
 
WINDOW_LIST=$(wmctrl -l | grep -v "\-1")
 
WINDOW_TITLES=$(echo "$WINDOW_LIST" | sed -r 's/([^ ]+ +){3}(.*)/\2/g')

WINDOW_SELECTION=$(zenity --entry --title="Choose a Window" --text="${WINDOW_TITLES}")
 
DESKTOP_NUMBER=$(echo "$WINDOW_LIST" | grep -m 1 ${WINDOW_SELECTION} | sed -r 's/^[^ ]+ +([^ ]+) .*/\1/g')
 
echo "Selection: ${WINDOW_SELECTION} Desktop: ${DESKTOP_NUMBER}"
 
xdotool search --desktop ${DESKTOP_NUMBER} --name ${WINDOW_SELECTION} windowactivate