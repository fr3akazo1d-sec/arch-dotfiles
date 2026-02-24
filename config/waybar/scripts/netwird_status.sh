#!/usr/bin/env bash

# Check if Netwird (wt interface) is connected
netwird_connected=false
netwird_ip=""

# Look for wt interfaces
for nw_iface in $(ip -o link show | awk -F': ' '/wt[0-9]+/ {print $2}' 2>/dev/null); do
  # Check if interface exists and has an IP (Netwird shows as UNKNOWN state but is functional)
  nw_ip=$(ip -4 addr show "$nw_iface" 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1)
  if [ -n "$nw_ip" ]; then
    # Double check if interface has LOWER_UP flag (indicates it's actually connected)
    if ip link show "$nw_iface" | grep -q "LOWER_UP" 2>/dev/null; then
      netwird_connected=true
      netwird_ip="$nw_ip"
      break
    fi
  fi
done

# Output status for waybar
if $netwird_connected; then
  echo "🔒 NW"
  echo "Netwird Connected: $netwird_ip"
else
  echo "🔓 NW"
  echo "Netwird: Disconnected"
fi