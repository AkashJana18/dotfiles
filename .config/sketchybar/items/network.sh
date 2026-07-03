#!/bin/bash

source "$CONFIG_DIR/icons.sh"

network=(
  icon="$WIFI_CONNECTED"
  label="--/--"
  label.font="$FONT:Heavy:12.0"
  updates=on
  update_freq=2
  mach_helper="$HELPER"
)

sketchybar --add item network right \
           --set network "${network[@]}"
