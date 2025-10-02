#!/usr/bin/env bash

# Get all connected monitors
monitors=$(hyprctl monitors -j | jq -r '.[].name')

# Launch cmatrix panel on each monitor
for monitor in $monitors; do
    kitty  +kitten panel \
          --edge=background \
          -o font_size=10 \
          cmatrix -C blue &
done
