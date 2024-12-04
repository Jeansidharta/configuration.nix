#!/usr/bin/env bash

# Toggles border gaps, for better space usage

if [[ $(bspc config -d focused window_gap) == 0 ]]
then
	bspc config -d focused window_gap 30
	eww close top_bar_solid
	eww open top_bar_split
else
	bspc config -d focused window_gap 0
	eww close top_bar_split
	eww open top_bar_solid
fi
