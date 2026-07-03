#!/bin/bash

STATE_FILE="/tmp/sketchybar_network_speed"
ITEM_NAME="${NAME:-network}"

get_interface() {
  if /sbin/ifconfig en0 >/dev/null 2>&1; then
    echo "en0"
    return
  fi

  /sbin/ifconfig | /usr/bin/awk -F: '/^[a-z]/ {print $1}' | /usr/bin/head -n 1
}

get_bytes() {
  /usr/sbin/netstat -bI "$1" -n 2>/dev/null | /usr/bin/awk 'NR==2 {print $7, $10}'
}

format_speed() {
  local bytes_per_sec="$1"

  if [ -z "$bytes_per_sec" ] || [ "$bytes_per_sec" -lt 1024 ]; then
    printf '%dB/s' "${bytes_per_sec:-0}"
  elif [ "$bytes_per_sec" -lt 1048576 ]; then
    awk -v value="$bytes_per_sec" 'BEGIN {printf "%.0fKB/s", value / 1024}'
  else
    awk -v value="$bytes_per_sec" 'BEGIN {printf "%.1fMB/s", value / 1048576}'
  fi
}

iface="$(get_interface)"

if [ -z "$iface" ]; then
  /opt/homebrew/bin/sketchybar --set "$ITEM_NAME" label="--/--"
  exit 0
fi

current_bytes="$(get_bytes "$iface")"
if [ -z "$current_bytes" ]; then
  /opt/homebrew/bin/sketchybar --set "$ITEM_NAME" label="--/--"
  exit 0
fi

current_in="$(echo "$current_bytes" | /usr/bin/awk '{print $1}')"
current_out="$(echo "$current_bytes" | /usr/bin/awk '{print $2}')"
current_ts="$(/bin/date +%s)"

if [ ! -f "$STATE_FILE" ]; then
  printf '%s %s %s %s\n' "$iface" "$current_in" "$current_out" "$current_ts" > "$STATE_FILE"
  /opt/homebrew/bin/sketchybar --set "$ITEM_NAME" label="0KB/s 0KB/s"
  exit 0
fi

read -r prev_iface prev_in prev_out prev_ts < "$STATE_FILE"

printf '%s %s %s %s\n' "$iface" "$current_in" "$current_out" "$current_ts" > "$STATE_FILE"

if [ "$iface" != "$prev_iface" ] || [ -z "$prev_ts" ] || [ "$current_ts" -le "$prev_ts" ]; then
  /opt/homebrew/bin/sketchybar --set "$ITEM_NAME" label="0KB/s 0KB/s"
  exit 0
fi

interval=$((current_ts - prev_ts))
delta_in=$((current_in - prev_in))
delta_out=$((current_out - prev_out))

if [ "$delta_in" -lt 0 ]; then delta_in=0; fi
if [ "$delta_out" -lt 0 ]; then delta_out=0; fi

in_speed=$((delta_in / interval))
out_speed=$((delta_out / interval))

/opt/homebrew/bin/sketchybar --set "$ITEM_NAME" label="↓ $(format_speed "$in_speed") ↑ $(format_speed "$out_speed")"
