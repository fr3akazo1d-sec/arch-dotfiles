#!/usr/bin/env bash

# Collect VPN-related interfaces and emit JSON for Waybar.
wg_found=false
vpn_found=false
netbird_found=false
wg_output=""
vpn_output=""
netbird_output=""

# WireGuard
for wg_iface in $(ip -o link show | awk -F': ' '/wg[0-9]+/ {print $2}'); do
  wg_ip=$(ip -4 addr show "$wg_iface" | awk '/inet / {print $2}' | cut -d/ -f1)
  if [ -n "$wg_ip" ]; then
    wg_output+="WG($wg_iface): $wg_ip\n"
    wg_found=true
  fi
done

# OpenVPN (tun/tap)
for vpn_iface in $(ip -o link show | awk -F': ' '/tun[0-9]+|tap[0-9]+/ {print $2}'); do
  vpn_ip=$(ip -4 addr show "$vpn_iface" | awk '/inet / {print $2}' | cut -d/ -f1)
  if [ -n "$vpn_ip" ]; then
    vpn_output+="OVPN($vpn_iface): $vpn_ip\n"
    vpn_found=true
  fi
done

# netbird (wt interfaces)
for nb_iface in $(ip -o link show | awk -F': ' '/wt[0-9]+/ {print $2}'); do
  nb_ip=$(ip -4 addr show "$nb_iface" | awk '/inet / {print $2}' | cut -d/ -f1)
  if [ -n "$nb_ip" ]; then
    netbird_output+="NB($nb_iface): $nb_ip\n"
    netbird_found=true
  fi
done

if $wg_found || $vpn_found || $netbird_found; then
  tooltip=$(printf "%s%s%s" "$wg_output" "$vpn_output" "$netbird_output" | sed '/^$/d')
  text=""  # locked icon
  class="connected"
else
  tooltip="No VPN connected"
  text=""  # unlocked icon
  class="disconnected"
fi

# Emit JSON for Waybar custom module
printf '{"text":"%s","tooltip":"%s","class":["%s"]}\n' "$text" "$tooltip" "$class"
