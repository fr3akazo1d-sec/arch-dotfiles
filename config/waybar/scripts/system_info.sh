#!/usr/bin/env bash

# Get system information
HOSTNAME=$(hostname)
KERNEL=$(uname -r)
UPTIME=$(uptime -p | sed 's/^up //')
DISTRO=$(grep PRETTY_NAME /etc/os-release | cut -d'"' -f2)

# CPU Information
CPU_MODEL=$(lscpu | grep "Model name" | sed 's/.*: *//')
CPU_CORES=$(nproc)
LOAD_AVG=$(cut -d' ' -f1-3 /proc/loadavg)

# Fast CPU usage via /proc/stat (avoids slow top -bn1)
read -r _cpu u1 n1 s1 i1 w1 r1 x1 _rest < /proc/stat
sleep 0.5
read -r _cpu u2 n2 s2 i2 w2 r2 x2 _rest < /proc/stat
total1=$(( u1 + n1 + s1 + i1 + w1 + r1 + x1 ))
total2=$(( u2 + n2 + s2 + i2 + w2 + r2 + x2 ))
diff_total=$(( total2 - total1 ))
diff_idle=$(( i2 - i1 ))
if (( diff_total > 0 )); then
    CPU_USAGE=$(awk "BEGIN {printf \"%.1f\", (1 - $diff_idle/$diff_total) * 100}")
else
    CPU_USAGE="0.0"
fi

# Memory Information
MEMORY_TOTAL=$(free -h | awk '/^Mem:/ {print $2}')
MEMORY_USED=$(free -h  | awk '/^Mem:/ {print $3}')
MEMORY_AVAILABLE=$(free -h | awk '/^Mem:/ {print $7}')
MEMORY_PERCENT=$(free | awk '/^Mem:/ {printf "%.1f", $3/$2 * 100}')
SWAP_USED=$(free -h | awk '/^Swap:/ {print $3}')
SWAP_TOTAL=$(free -h | awk '/^Swap:/ {print $2}')

# Storage Information
DISK_USAGE=$(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')
DISK_HOME=$(df -h /home 2>/dev/null | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}' || echo "N/A")

# Network Information
NETWORK_INTERFACE=$(ip route show default 2>/dev/null | awk '{print $5}' | head -1)
IP_ADDRESS=$(ip -4 addr show "${NETWORK_INTERFACE}" 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1 | head -1)
GATEWAY=$(ip route show default 2>/dev/null | awk '{print $3}' | head -1)
DNS_SERVERS=$(grep '^nameserver' /etc/resolv.conf | awk '{print $2}' | tr '\n' ',' | sed 's/,$//')

# WiFi detection using iw (iwconfig is deprecated)
WIFI_SSID=$(iw dev "${NETWORK_INTERFACE}" info 2>/dev/null | awk '/ssid/ {print $2}')
WIFI_SIGNAL=$(iw dev "${NETWORK_INTERFACE}" station dump 2>/dev/null | awk '/signal:/ {print $2; exit}')
if [[ -n "$WIFI_SSID" ]]; then
    NETWORK_TYPE="WiFi"
else
    NETWORK_TYPE="Ethernet"
fi

# Hardware Information
GPU_INFO=$(lspci | grep -i vga | cut -d: -f3 | sed 's/^ *//')
TEMP_CPU=$(sensors 2>/dev/null | grep -m1 -i "Package\|Core 0" | awk '{print $3}' | tr -d '+°C' || echo "N/A")
TEMP_GPU=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null || echo "N/A")

# Processes and System
PROCESS_COUNT=$(ps -e --no-headers | wc -l)
LOGGED_USERS=$(who | wc -l)

# Network traffic counters
RX_BYTES=$(cat "/sys/class/net/${NETWORK_INTERFACE}/statistics/rx_bytes" 2>/dev/null || echo 0)
TX_BYTES=$(cat "/sys/class/net/${NETWORK_INTERFACE}/statistics/tx_bytes" 2>/dev/null || echo 0)
RX_MB=$(( RX_BYTES / 1024 / 1024 ))
TX_MB=$(( TX_BYTES / 1024 / 1024 ))

# Build network info string
NETWORK_INFO="<b>Interface:</b> ${NETWORK_INTERFACE} (${NETWORK_TYPE})"
if [[ "$NETWORK_TYPE" == "WiFi" && -n "$WIFI_SSID" ]]; then
    NETWORK_INFO="${NETWORK_INFO}
<b>SSID:</b> $WIFI_SSID
<b>Signal:</b> ${WIFI_SIGNAL} dBm"
fi
NETWORK_INFO="${NETWORK_INFO}
<b>IP Address:</b> $IP_ADDRESS
<b>Gateway:</b> $GATEWAY
<b>DNS:</b> $DNS_SERVERS
<b>Traffic:</b> ↓ ${RX_MB}MB ↑ ${TX_MB}MB"

# Create the comprehensive notification
TITLE="🔧 System Information - $HOSTNAME"
BODY="<b>═══ SYSTEM ═══</b>
<b>OS:</b> $DISTRO
<b>Kernel:</b> $KERNEL
<b>Uptime:</b> $UPTIME
<b>Users:</b> $LOGGED_USERS logged in

<b>═══ HARDWARE ═══</b>
<b>CPU:</b> $CPU_MODEL ($CPU_CORES cores)
<b>Usage:</b> ${CPU_USAGE}% | Load: $LOAD_AVG
<b>Temperature:</b> ${TEMP_CPU}°C

<b>GPU:</b> $GPU_INFO"

if [[ "$TEMP_GPU" != "N/A" ]]; then
    BODY="${BODY}
<b>GPU Temp:</b> ${TEMP_GPU}°C"
fi

BODY="${BODY}

<b>═══ MEMORY & STORAGE ═══</b>
<b>RAM:</b> $MEMORY_USED / $MEMORY_TOTAL (${MEMORY_PERCENT}%) | Free: $MEMORY_AVAILABLE
<b>Swap:</b> $SWAP_USED / $SWAP_TOTAL
<b>Root:</b> $DISK_USAGE"

if [[ "$DISK_HOME" != "N/A" ]]; then
    BODY="${BODY}
<b>Home:</b> $DISK_HOME"
fi

BODY="${BODY}

<b>═══ NETWORK ═══</b>
$NETWORK_INFO

<b>═══ PROCESSES ═══</b>
<b>Total processes:</b> $PROCESS_COUNT"

# Send comprehensive notification
notify-send -t 15000 -i computer "$TITLE" "$BODY"
