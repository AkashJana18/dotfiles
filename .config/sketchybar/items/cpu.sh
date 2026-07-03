#!/bin/bash

cpu_top=(
  label.font="$FONT:Semibold:7"
  label=CPU
  icon.drawing=off
  width=0
  padding_left=8
  padding_right=10
  y_offset=6
  background.drawing=off
)

cpu_percent=(
  label.font="$FONT:Heavy:12"
  label=CPU
  y_offset=-4
  padding_left=0
  padding_right=6
  width=40
  icon.drawing=off
  update_freq=4
  mach_helper="$HELPER"
  background.drawing=off
)

cpu_sys=(
  width=0
  graph.color=$RED
  graph.fill_color=$RED
  label.drawing=off
  icon.drawing=off
  background.height=26
  background.drawing=off
  background.color=$TRANSPARENT
)

cpu_user=(
  graph.color=$BLUE
  label.drawing=off
  icon.drawing=off
  background.height=26
  background.drawing=off
  background.color=$TRANSPARENT
  background.border_width=0
  
)

cpu_bracket=(
  background.color=$BACKGROUND_1
  background.border_color=$BACKGROUND_2
  background.height=30
  background.corner_radius=2
  blur_radius=50
)

sketchybar --add item cpu.top left              \
           --set cpu.top "${cpu_top[@]}"         \
                                                 \
           --add item cpu.percent left          \
           --set cpu.percent "${cpu_percent[@]}" \
                                                 \
           --add graph cpu.sys left 75          \
           --set cpu.sys "${cpu_sys[@]}"         \
                                                 \
           --add graph cpu.user left 75         \
           --set cpu.user "${cpu_user[@]}"

sketchybar --add bracket cpu.bracket cpu.top cpu.percent cpu.sys cpu.user \
           --set cpu.bracket "${cpu_bracket[@]}"
