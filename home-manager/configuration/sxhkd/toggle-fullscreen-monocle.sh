#!/usr/bin/env bash

# Expected first argument: "monocle" | "fullscreen"

# If the user is in monocle mode or in fullscreen mode, go back to tiled mode.
# Otherwise, go to monocle/fullscreen mode, as specified by the first argument.

if bspc query -T --desktop focused | grep "$(echo -e "monocle\n\"state\":\"fullscreen\"")" > /dev/null; then
	bspc desktop --layout tiled
	bspc node --state tiled
	# eww close top_bar_solid
	# eww open top_bar_split
else
	if [[ "$1" == "monocle" ]]; then
		bspc desktop --layout monocle
		# eww close top_bar_split
		# eww open top_bar_solid
	else
		bspc node --state fullscreen
		# eww close top_bar_split
		# eww open top_bar_solid
	fi
fi
