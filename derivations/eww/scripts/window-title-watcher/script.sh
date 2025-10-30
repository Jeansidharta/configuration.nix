#!/usr/bin/env bash

IFS=$'\n'
niri msg --json event-stream | while read -r message; do
	if echo "$message" | jq -e '.WindowFocusChanged' > /dev/null ; then
		if echo "$message" | jq -e '.WindowFocusChanged.id' > /dev/null ; then
			niri msg --json focused-window | jq --raw-output .title
		else
			echo ''
		fi
	else
		echo "$message" | jq --raw-output '(.WindowOpenedOrChanged.window | select(.is_focused == true) | .title | select(. != null))'
	fi
done
