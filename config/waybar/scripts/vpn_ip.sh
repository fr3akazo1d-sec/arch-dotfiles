#!/usr/bin/env bash

wg_found=false
vpn_found=false
wg_output=""
vpn_output=""

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

if ! $wg_found && ! $vpn_found; then
  echo "No VPN connected"
else
  # Remove trailing newline and print
  echo -e "${wg_output}${vpn_output}" | sed '/^$/d'
fi
