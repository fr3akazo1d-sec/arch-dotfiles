#!/usr/bin/env bash

# Check WireGuard (wg interface) - optimized to reduce subprocess calls
while read -r iface ip; do
  [ -n "$ip" ] && {
    printf '{"text":"󰚃 WG","tooltip":"WireGuard\\n%s: %s","class":["connected"]}\n' "$iface" "$ip"
    exit 0
  }
done < <(ip -4 -o addr show | awk '/wg[0-9]+/ {gsub(/\/.*/, "", $4); print $2, $4}')

# Not connected
printf '{"text":"","tooltip":"WireGuard: Disconnected","class":["disconnected"]}\n'
