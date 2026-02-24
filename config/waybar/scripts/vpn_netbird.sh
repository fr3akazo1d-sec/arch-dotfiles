#!/usr/bin/env bash

# Check Netbird (wt interface) - optimized to reduce subprocess calls
while read -r iface ip; do
  [ -n "$ip" ] && {
    printf '{"text":"󰛳 NB","tooltip":"Netbird\\n%s: %s","class":["connected"]}\n' "$iface" "$ip"
    exit 0
  }
done < <(ip -4 -o addr show | awk '/wt[0-9]+/ {gsub(/\/.*/, "", $4); print $2, $4}')

# Not connected
printf '{"text":"","tooltip":"Netbird: Disconnected","class":["disconnected"]}\n'
