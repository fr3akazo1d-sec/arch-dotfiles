      #!/usr/bin/env bash
      
      # Get system information
      HOSTNAME=$(hostname)
      KERNEL=$(uname -r)
      UPTIME=$(uptime | sed 's/.*up \([^,]*\).*/\1/')
      DISTRO=$(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)
      
      # CPU Information
      CPU_MODEL=$(lscpu | grep "Model name" | sed 's/.*: *//')
      CPU_CORES=$(nproc)
      CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
      LOAD_AVG=$(cat /proc/loadavg | cut -d' ' -f1-3)
      
      # Memory Information
      MEMORY_TOTAL=$(free -h | awk '/^Mem:/ {print $2}')
      MEMORY_USED=$(free -h | awk '/^Mem:/ {print $3}')
      MEMORY_AVAILABLE=$(free -h | awk '/^Mem:/ {print $7}')
      MEMORY_PERCENT=$(free | awk '/^Mem:/ {printf "%.1f", $3/$2 * 100}')
      SWAP_USED=$(free -h | awk '/^Swap:/ {print $3}')
      SWAP_TOTAL=$(free -h | awk '/^Swap:/ {print $2}')
      
      # Storage Information
      DISK_USAGE=$(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')
      DISK_HOME=$(df -h /home 2>/dev/null | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}' || echo "N/A")
      
      # Network Information
      NETWORK_INTERFACE=$(ip route | grep default | awk '{print $5}' | head -1)
      IP_ADDRESS=$(ip addr show $NETWORK_INTERFACE 2>/dev/null | grep "inet " | awk '{print $2}' | cut -d/ -f1)
      GATEWAY=$(ip route | grep default | awk '{print $3}' | head -1)
      DNS_SERVERS=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}' | tr '\n' ', ' | sed 's/,$//')
      NETWORK_TYPE=$(iwconfig $NETWORK_INTERFACE 2>/dev/null | grep "ESSID" && echo "WiFi" || echo "Ethernet")
      WIFI_SSID=$(iwconfig $NETWORK_INTERFACE 2>/dev/null | grep ESSID | cut -d'"' -f2)
      WIFI_SIGNAL=$(iwconfig $NETWORK_INTERFACE 2>/dev/null | grep "Signal level" | awk '{print $4}' | cut -d'=' -f2)
      
      # Hardware Information
      GPU_INFO=$(lspci | grep -i vga | cut -d: -f3 | sed 's/^ *//')
      TEMP_CPU=$(sensors 2>/dev/null | grep -i "Package\|Core 0" | head -1 | awk '{print $3}' | tr -d '+°C' || echo "N/A")
      TEMP_GPU=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null || echo "N/A")
      
      # Processes and System
      PROCESS_COUNT=$(ps aux | wc -l)
      LOGGED_USERS=$(who | wc -l)
      
      # Network interfaces with traffic
      RX_BYTES=$(cat /sys/class/net/$NETWORK_INTERFACE/statistics/rx_bytes 2>/dev/null || echo 0)
      TX_BYTES=$(cat /sys/class/net/$NETWORK_INTERFACE/statistics/tx_bytes 2>/dev/null || echo 0)
      RX_MB=$(($RX_BYTES / 1024 / 1024))
      TX_MB=$(($TX_BYTES / 1024 / 1024))
      
      # Build network info string
      NETWORK_INFO="<b>Interface:</b> $NETWORK_INTERFACE ($NETWORK_TYPE)"
      if [ "$NETWORK_TYPE" = "WiFi" ] && [ ! -z "$WIFI_SSID" ]; then
        NETWORK_INFO="$NETWORK_INFO
<b>SSID:</b> $WIFI_SSID
<b>Signal:</b> $WIFI_SIGNAL"
      fi
      NETWORK_INFO="$NETWORK_INFO
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
      
      if [ "$TEMP_GPU" != "N/A" ]; then
        BODY="$BODY
<b>GPU Temp:</b> ${TEMP_GPU}°C"
      fi
      
      BODY="$BODY

<b>═══ MEMORY & STORAGE ═══</b>
<b>RAM:</b> $MEMORY_USED / $MEMORY_TOTAL (${MEMORY_PERCENT}%) | Free: $MEMORY_AVAILABLE
<b>Swap:</b> $SWAP_USED / $SWAP_TOTAL
<b>Root:</b> $DISK_USAGE"
      
      if [ "$DISK_HOME" != "N/A" ]; then
        BODY="$BODY
<b>Home:</b> $DISK_HOME"
      fi
      
      BODY="$BODY

<b>═══ NETWORK ═══</b>
$NETWORK_INFO

<b>═══ PROCESSES ═══</b>
<b>Total processes:</b> $PROCESS_COUNT"
      
      # Send comprehensive notification
      notify-send -t 15000 -i computer "$TITLE" "$BODY"
