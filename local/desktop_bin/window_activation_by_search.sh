#!/bin/bash -x

WINDOW_LIST="$(wmctrl -l | grep -vE "([^ ]+ +){3}(Desktop$|xfce4-panel|rainlendar)")"

WINDOW_LIST_WITH_NUM="$(awk 'BEGIN{OFS=" "; col1=1}{print col1,$0; col1+=1}' <<<"${WINDOW_LIST}")"

WINDOW_TITLES="$(sed -r 's/([0-9]+) ([^ ]+ +){3}(.*)/\1 \3/g' <<<"${WINDOW_LIST_WITH_NUM}")"

WINDOW_SELECTION=$(zenity --entry --title="Choose a Window" --text="${WINDOW_TITLES}")

if [[ "${WINDOW_SELECTION}" =~ ^[0-9]+$ ]]; then
	# If the user's input was a number we assume that they identified the window by ID
	WIN_ID=$(grep -E "^${WINDOW_SELECTION} " <<<"${WINDOW_LIST_WITH_NUM}" | sed -r 's/^[^ ]+ +([^ ]+).*/\1/g')
else
	WIN_ID=$(grep -im 1 "${WINDOW_SELECTION}" <<<"${WINDOW_LIST}" | sed -r 's/^([^ ]+).*/\1/g')
fi

echo "Selection: ${WIN_ID}"

xdotool windowactivate "$(printf "%d" "${WIN_ID}")"
