#!/usr/bin/env bash

# Check OpenVPN (tun/tap interface) - optimized to reduce subprocess calls
while read -r iface ip; do
  [ -n "$ip" ] && {
    printf '{"text":"󰘂 VPN","tooltip":"OpenVPN\\n%s: %s","class":["connected"]}\n' "$iface" "$ip"
    exit 0
  }
done < <(ip -4 -o addr show | awk '/(tun[0-9]+|tap[0-9]+)/ {gsub(/\/.*/, "", $4); print $2, $4}')

# Not connected
printf '{"text":"","tooltip":"OpenVPN: Disconnected","class":["disconnected"]}\n'
