#!/usr/bin/env bash

IFS=$'\n'
niri msg --json event-stream | while read -r batata; do
	if echo "$batata" | jq -e '.WindowFocusChanged.id | select(. != null)' > /dev/null ; then
		niri msg --json focused-window | jq --raw-output .title
	else
		echo "$batata" | jq --raw-output '(.WindowOpenedOrChanged.window | select(.is_focused == true) | .title | select(. != null))'
	fi
done
