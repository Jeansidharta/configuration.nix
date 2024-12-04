#!/usr/bin/env bash

# Expected first argument: "west" | "north" | "south" | "east"

# If the user is in monocle mode, focus the next/prev node. Otherwise, focus east/west/north/south nodes

if bspc query -T --desktop focused | grep monocle > /dev/null; then
	if [[ "$1" == "east.local" ]] || [[ "$1" == "south.local" ]]; then
		bspc node --focus next.local.leaf
	else
		bspc node --focus prev.local.leaf
	fi
else
	bspc node --focus "$1"
fi
