{ config, pkgs, ... }:

{
  programs.waybar.enable = true;

  # Create the system info script
  home.file.".config/waybar/scripts/system_info.sh" = {
    text = ''
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
<b>Traffic:</b> ↓ ''${RX_MB}MB ↑ ''${TX_MB}MB"
      
      # Create the comprehensive notification
      TITLE="🔧 System Information - $HOSTNAME"
      BODY="<b>═══ SYSTEM ═══</b>
<b>OS:</b> $DISTRO
<b>Kernel:</b> $KERNEL
<b>Uptime:</b> $UPTIME
<b>Users:</b> $LOGGED_USERS logged in

<b>═══ HARDWARE ═══</b>
<b>CPU:</b> $CPU_MODEL ($CPU_CORES cores)
<b>Usage:</b> ''${CPU_USAGE}% | Load: $LOAD_AVG
<b>Temperature:</b> ''${TEMP_CPU}°C

<b>GPU:</b> $GPU_INFO"
      
      if [ "$TEMP_GPU" != "N/A" ]; then
        BODY="$BODY
<b>GPU Temp:</b> ''${TEMP_GPU}°C"
      fi
      
      BODY="$BODY

<b>═══ MEMORY & STORAGE ═══</b>
<b>RAM:</b> $MEMORY_USED / $MEMORY_TOTAL (''${MEMORY_PERCENT}%) | Free: $MEMORY_AVAILABLE
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
    '';
    executable = true;
  };

  home.file.".config/waybar/config".text = ''
{
  "layer": "top",
  "position": "top",
  "height": 34,
  "spacing": 8,

  "modules-left": [ "custom/f_logo", "hyprland/workspaces", "hyprland/window" ],
  "modules-center": [ "mpris", "cpu", "memory", "temperature", "disk" ],
  "modules-right": [
    "custom/vpn-ip",
    "network",
    "pulseaudio",
    "bluetooth",
    "custom/notifications",
    "battery",
    "clock#time",
    "clock#date",
    "tray",
    "custom/exit"
  ],

  "mpris": {
    "format": " {status_icon} ",
    "format-paused": " {status_icon} ",
    "format-stopped": " -- ",
    "player-icons": {
      "spotify": "SPT",
      "firefox": "FFX",
      "default": "MUS"
    },
    "status-icons": {
      "playing": "PLAY",
      "paused": "PAUSE"
    },
    "tooltip-format": "{artist} - {title}\n{album} | {player}",
    "on-click": "playerctl play-pause",
    "on-scroll-up": "playerctl next",
    "on-scroll-down": "playerctl previous",
    "interval": 1,
    "min-length": 6,
    "max-length": 10
  },

  "cpu": {
    "interval": 2,
    "format": "󰻠 {usage}%",
    "format-alt": "󰻠 {avg_frequency}GHz",
    "tooltip-format": "CPU Usage: {usage}%\nAvg Frequency: {avg_frequency}GHz\nLoad: {load}",
    "states": {
      "warning": 70,
      "critical": 90
    }
  },

  "memory": {
    "interval": 5,
    "format": "󰍛 {}%",
    "format-alt": "󰍛 {used:0.1f}G",
    "tooltip-format": "RAM: {used:0.1f}G / {total:0.1f}G ({percentage}%)\nSwap: {swapUsed:0.1f}G / {swapTotal:0.1f}G",
    "states": {
      "warning": 70,
      "critical": 90
    }
  },

  "temperature": {
    "interval": 4,
    "critical-threshold": 80,
    "format": "{icon} {temperatureC}°C",
    "format-icons": ["󱃃", "󰔏", "󱃂"],
    "tooltip-format": "Temperature: {temperatureC}°C"
  },

  "disk": {
    "interval": 30,
    "format": "󰋊 {percentage_used}%",
    "format-alt": "󰋊 {free}",
    "path": "/",
    "tooltip-format": "Disk Usage\nUsed: {used} / {total} ({percentage_used}%)\nFree: {free}",
    "states": {
      "warning": 70,
      "critical": 90
    }
  },

  "custom/f_logo": {
    "format": "<span foreground='#00fff7'>F</span><span foreground='#ff003c'>!</span>",
    "tooltip": "fr3akazo1d — Command Center\\nClick for detailed system info",
    "interval": 86400,
    "markup": true,
    "on-click": "~/.config/waybar/scripts/system_info.sh"
  },

  "hyprland/window": {
    "format": "{}",
    "max-length": 60,
    "empty-window-text": "Desktop"
  },

  "hyprland/workspaces": {
    "on-click": "activate",
    "format": "{name}",
    "persistent-workspaces": { "*": 5 },
    "sort-by-number": true
  },

  "window": {
    "max-length": 80,
    "separate-outputs": false,
    "format": "{title}",
    "rewrite": {
      "(.*) — Mozilla Firefox": "  $1",
      "(.*) — Ghostty": "  $1"
    }
  },

  "bluetooth": {
    "format": " {status}",
    "format-disabled": " Off",
    "format-off": " Off",
    "format-no-controller": " No Controller",
    "interval": 30,
    "on-click": "blueman-manager"
  },

  "custom/exit": {
    "format": "",
    "on-click": "rofi -show menu -modi 'menu:rofi-power-menu'",
    "tooltip-format": "Left: Power menu Right: Lock screen"
  },

  "network": {
    "interval": 2,
    "format-wifi": "  {signalStrength}%",
    "format-ethernet": "󰈁 {bandwidthDownBytes}",
    "format-disconnected": "󰖪",
    "format-linked": "󰈁 No IP",
    "tooltip-format-wifi": "SSID: {essid}\nSignal: {signalStrength}% ({signaldBm} dBm)\nFreq: {frequency}MHz\nIP: {ipaddr}/{cidr}\nGateway: {gwaddr}\n↓ {bandwidthDownBytes} ↑ {bandwidthUpBytes}",
    "tooltip-format-ethernet": "Interface: {ifname}\nIP: {ipaddr}/{cidr}\nGateway: {gwaddr}\n↓ {bandwidthDownBytes} ↑ {bandwidthUpBytes}",
    "tooltip-format-disconnected": "Network Offline",
    "on-click": "nm-connection-editor"
  },

  "pulseaudio": {
    "format": "{icon}  {volume}%",
    "format-bluetooth": "{volume}% {icon} {format_source}",
    "format-bluetooth-muted": " {icon} {format_source}",
    "format-muted": " {format_source}",
    "format-source": "{volume}% ",
    "format-source-muted": "",
    "format-icons": {
      "headphone": " ",
      "hands-free": " ",
      "headset": " ",
      "phone": " ",
      "portable": " ",
      "car": " ",
      "default": ["", "", ""]
    },
    "on-click": "pavucontrol"
  },

  "battery": {
    "format": "{icon} {capacity}%",
    "format-charging": " {capacity}%",
    "format-plugged": " {capacity}%",
    "format-alt": "{time}",
    "format-icons": ["", "", "", "", ""],
    "interval": 5
  },

  "clock#time": {
    "interval": 1,
    "format": "󰥔 {:%H:%M:%S}",
    "tooltip-format": "<tt><small>{calendar}</small></tt>",
    "calendar": {
      "mode": "month",
      "on-scroll": 1,
      "format": {
        "months": "<span color='#00fff7'><b>{}</b></span>",
        "days": "<span color='#ffffff'><b>{}</b></span>",
        "weekdays": "<span color='#00fff7'><b>{}</b></span>",
        "today": "<span color='#ff003c'><b><u>{}</u></b></span>"
      }
    },
    "actions": {
      "on-click-right": "mode",
      "on-scroll-up": "shift_up",
      "on-scroll-down": "shift_down"
    }
  },

  "clock#date": {
    "interval": 60,
    "format": "󰃭 {:%d·%b}",
    "format-alt": "󰃭 {:%A, %d %B %Y}",
    "tooltip-format": "<tt><small>{calendar}</small></tt>",
    "calendar": {
      "mode": "month",
      "format": {
        "months": "<span color='#00fff7'><b>{}</b></span>",
        "days": "<span color='#ffffff'><b>{}</b></span>",
        "weekdays": "<span color='#00fff7'><b>{}</b></span>",
        "today": "<span color='#ff003c'><b><u>{}</u></b></span>"
      }
    }
  },

  "custom/vpn-ip": {
    "exec": "~/.config/waybar/scripts/vpn_ip.sh",
    "interval": 10,
    "return-type": "text",
    "tooltip": true
  },

  "custom/notifications": {
    "format": "󰂚",
    "tooltip": "Click to open notifications",
    "on-click": "swaync-client -t -sw"
  },

  "tray": {
    "icon-size": 10,
    "spacing": 2
  }
}
  '';

  home.file.".config/waybar/style.css".text = ''
/* ===== HACKER TERMINAL THEME v2.0 ===== */
/* [!] fr3akazo1d command center */
* {
  font-family: "JetBrainsMono Nerd Font", "FiraCode Nerd Font", "Hack Nerd Font", monospace;
  font-size: 9pt;
  color: #dce9ff;
  font-weight: 500;
}

window#waybar {
  background: transparent;
  background-image: 
    repeating-linear-gradient(
      to bottom,
      rgba(0,0,0,0.0) 0px,
      rgba(0,255,247,0.03) 1px,
      rgba(0,0,0,0.0) 2px
    ),
    repeating-linear-gradient(
      90deg,
      rgba(0,255,247,0.01) 0px,
      rgba(0,0,0,0.0) 1px,
      rgba(0,0,0,0.0) 4px
    );
  border: none;
  padding: 0;
}

/* === MACBOOK NOTCH DESIGN === */
.modules-left {
  background: linear-gradient(180deg, 
    rgba(10,15,25,0.92), 
    rgba(20,28,40,0.85)
  );
  border: 1px solid rgba(0,255,247,0.4);
  border-top: none;
  border-left: none;
  border-bottom-right-radius: 16px;
  padding: 4px 12px 4px 8px;
  margin-right: 8px;
  box-shadow: 
    inset 0 -1px 0 rgba(0,255,247,0.15),
    0 2px 12px rgba(0,255,247,0.25);
}

.modules-center {
  background: linear-gradient(180deg, 
    rgba(8,12,20,0.95), 
    rgba(15,22,35,0.92)
  );
  border: 1px solid rgba(0,255,247,0.5);
  border-top: none;
  border-bottom-left-radius: 20px;
  border-bottom-right-radius: 20px;
  padding: 6px 16px;
  box-shadow: 
    inset 0 1px 0 rgba(0,255,247,0.2),
    0 4px 20px rgba(0,255,247,0.4),
    0 8px 32px rgba(0,255,247,0.15);
}

.modules-right {
  background: linear-gradient(180deg, 
    rgba(10,15,25,0.92), 
    rgba(20,28,40,0.85)
  );
  border: 1px solid rgba(0,255,247,0.4);
  border-top: none;
  border-right: none;
  border-bottom-left-radius: 16px;
  padding: 4px 8px 4px 12px;
  margin-left: 8px;
  box-shadow: 
    inset 0 -1px 0 rgba(0,255,247,0.15),
    0 2px 12px rgba(0,255,247,0.25);
}

/* === TERMINAL MODULE STYLING === */
#workspaces, #window, #tray,
#custom-f_logo, #custom-wg,
#network, #pulseaudio, #cpu, #memory, #temperature, #battery, #disk,
#mpris, #clock, #clock.time, #clock.date {
  background: transparent;
  border: none;
  border-radius: 0;
  box-shadow: none;
  padding: 2px 6px;
  margin: 0 6px;
  transition: all 0.1s cubic-bezier(0.4, 0, 0.2, 1);
}

/* Clear separators between modules */
#custom-vpn-ip, #network, #pulseaudio, #bluetooth, 
#custom-notifications, #battery,
#mpris, #cpu, #memory, #temperature {
  border-right: 1px solid rgba(0,255,247,0.25);
  padding-right: 8px;
  margin-right: 8px;
}

/* No separators on last items or grouped clocks */
#window, #disk, #tray {
  border-right: 0px;
}

#clock.time, #clock.date {
  border-right: 0px;
}

/* === CLOCK TERMINAL GROUPING === */
#clock.time { 
  margin-right: 0px;
  border-right: 1px solid rgba(0,255,247,0.25);
  border-top-right-radius: 0;
  border-bottom-right-radius: 0;
  font-family: "Hack Nerd Font Mono", monospace;
  letter-spacing: 0.5px;
  padding-right: 8px;
  margin-right: 0px;
}
#clock.date { 
  margin-left: 0px;
  border-left: none;
  border-right: none;
  border-top-left-radius: 0;
  border-bottom-left-radius: 0;
  color: #93a4c3;
  font-variant: small-caps;
  padding-left: 8px;
}

/* === BRAND SIGNATURE === */
#custom-f_logo {
  font-weight: 900;
  letter-spacing: -0.5px;
  font-size: 10.5pt;
  padding: 2px 10px;
  text-shadow:
    0 0 4px rgba(0,255,247,0.9),
    0 0 10px rgba(0,255,247,0.6),
    0 0 16px rgba(255,0,60,0.4),
    2px 0 0 rgba(0,255,247,0.1),
    -2px 0 0 rgba(255,0,60,0.1);
}

/* === SYSTEM MONITOR MODULES (NOTCH) === */
#cpu, #memory, #temperature {
  font-family: "Hack Nerd Font Mono", "JetBrainsMono Nerd Font", monospace;
  font-size: 8.5pt;
  font-weight: 700;
  letter-spacing: -0.3px;
  background: transparent;
  border: none;
  border-right: 1px solid rgba(0,255,247,0.2);
  padding: 2px 8px;
  margin: 0 4px;
}

#disk {
  font-family: "Hack Nerd Font Mono", "JetBrainsMono Nerd Font", monospace;
  font-size: 8.5pt;
  font-weight: 700;
  letter-spacing: -0.3px;
  background: transparent;
  border: none;
  padding: 2px 8px;
  margin: 0 4px;
}

/* === RGB SPLIT GLITCH TEXT === */
#window, #network, #pulseaudio, #battery, #clock.time {
  text-shadow:
    1px 0 0 rgba(0,255,247,0.25),
   -1px 0 0 rgba(255,0,60,0.25),
    0 0 4px rgba(0,255,247,0.15);
}

/* === WORKSPACE BUTTONS === */
#workspaces button {
  background: rgba(12,18,28, 0.88);
  color: #7a8fa8;
  border: 1px solid rgba(0,255,247,0.25);
  border-left: 2px solid rgba(0,255,247,0.35);
  border-radius: 3px;
  padding: 1px 5px;
  margin: 0 2px;
  font-size: 8pt;
  font-weight: 600;
  font-family: "Hack Nerd Font Mono", monospace;
  transition: all 0.2s ease;
}

#workspaces button:hover { 
  color: #dce9ff; 
  background: rgba(15,22,32, 0.95);
  border-color: rgba(0,255,247,0.5);
  box-shadow: 0 0 8px rgba(0,255,247,0.4);
}

#workspaces button.active {
  color: #00fff7; 
  background: rgba(0,255,247,0.08);
  border-color: rgba(0,255,247,0.6);
  border-left: 2px solid #00fff7;
  box-shadow: 
    inset 0 0 8px rgba(0,255,247,0.15),
    0 0 10px rgba(0,255,247,0.45);
  text-shadow: 0 0 6px rgba(0,255,247,0.6);
}

#workspaces button.urgent {
  color: #ff003c; 
  background: rgba(255,0,60,0.08);
  border-color: rgba(255,0,60,0.7);
  border-left: 2px solid #ff003c;
  box-shadow: 0 0 10px rgba(255,0,60,0.5);
}

/* === SYSTEM TRAY === */
#tray { 
  padding: 0 6px; 
  background: rgba(8,12,20,0.92);
}
#tray * { 
  -gtk-icon-transform: scale(0.88); 
}
#tray > .needs-attention { 
  color: #ff003c;
}

/* === STATUS ALERTS === */
#network.disconnected, #custom-wg.down, #battery.critical,
#cpu.critical, #memory.critical, #disk.critical {
  color: #ff003c;
  border-color: rgba(255,0,60,0.65);
  border-left: 2px solid #ff003c;
  box-shadow: 
    inset 0 0 8px rgba(255,0,60,0.15),
    0 0 10px rgba(255,0,60,0.5), 
    0 0 20px rgba(255,0,60,0.2);
}

/* === WARNING STATES === */
#cpu.warning, #memory.warning, #disk.warning {
  color: #ffaa00;
  border-color: rgba(255,170,0,0.6);
  border-left: 2px solid #ffaa00;
  box-shadow: 
    inset 0 0 6px rgba(255,170,0,0.12),
    0 0 8px rgba(255,170,0,0.45);
}

/* === MONITOR NORMAL STATE === */
#cpu, #memory, #disk {
  color: #00fff7;
  text-shadow: 
    0 0 5px rgba(0,255,247,0.5),
    0 0 1px rgba(0,255,247,0.8);
}

/* === TEMPERATURE DISPLAY === */
#temperature {
  font-weight: 700;
  font-family: "Hack Nerd Font Mono", monospace;
}

#temperature.critical {
  color: #ff003c;
  border-color: rgba(255,0,60,0.75);
  border-left: 2px solid #ff003c;
  box-shadow: 
    inset 0 0 8px rgba(255,0,60,0.15),
    0 0 12px rgba(255,0,60,0.6);
}

/* === POWER/EXIT BUTTON === */
#custom-exit {
  background: transparent;
  border: none;
  border-radius: 0;
  box-shadow: none;
  padding: 2px 8px;
  font-size: 10pt;
  margin: 0 6px;
  color: #ff6b8a;
  transition: all 0.1s ease;
}

#custom-exit:hover {
  background: rgba(255,0,60,0.08);
  border-radius: 6px;
  color: #ff003c;
  box-shadow: 0 0 12px rgba(255,0,60,0.5);
}

/* === BLUETOOTH === */
#bluetooth {
  background: transparent;
  border-top: none;
  border-left: none;
  border-bottom: none;
  border-radius: 0;
  box-shadow: none;
  padding: 2px 8px;
  margin: 0 6px;
  color: #00fff7;
  font-weight: 600;
}

#bluetooth.off,
#bluetooth.disabled,
#bluetooth.no-controller {
  color: #ff5555;
}

#bluetooth:hover {
  background: rgba(0,255,247,0.06);
  border-radius: 6px;
  color: #ffffff;
  box-shadow: 0 0 12px rgba(0,255,247,0.4);
}

/* === TOOLTIP HACKER TERMINAL === */
tooltip {
  background: rgba(8,12,20,0.98);
  color: #dce9ff;
  border: 1px solid rgba(0,255,247,0.7);
  border-left: 3px solid #00fff7;
  border-bottom: 2px solid rgba(0,255,247,0.5);
  border-radius: 4px;
  box-shadow: 
    inset 0 1px 0 rgba(0,255,247,0.2),
    0 0 16px rgba(0,255,247,0.5), 
    0 0 32px rgba(0,255,247,0.2);
  font-family: "Hack Nerd Font Mono", "JetBrainsMono Nerd Font", monospace;
  font-size: 8.5pt;
  padding: 10px 14px;
  background-image: repeating-linear-gradient(
    to bottom,
    rgba(0,0,0,0.0) 0px,
    rgba(0,255,247,0.02) 1px,
    rgba(0,0,0,0.0) 2px
  );
}

tooltip * {
  color: #dce9ff;
}

/* === VPN IP MODULE === */
#custom-vpn-ip {
  background: transparent;
  border-top: none;
  border-left: none;
  border-bottom: none;
  border-radius: 0;
  box-shadow: none;
  padding: 2px 8px;
  margin: 0 6px;
  color: #00fff7;
  font-weight: 600;
  font-family: "Hack Nerd Font Mono", "JetBrainsMono Nerd Font", monospace;
  font-size: 8.5pt;
  transition: all 0.1s ease;
}

#custom-vpn-ip:hover {
  background: rgba(0,255,247,0.06);
  border-radius: 6px;
  color: #ffffff;
  box-shadow: 0 0 12px rgba(0,255,247,0.4);
}

/* === NOTIFICATIONS === */
#custom-notifications {
  background: transparent;
  border-top: none;
  border-left: none;
  border-bottom: none;
  border-radius: 0;
  box-shadow: none;
  padding: 2px 8px;
  margin: 0 6px;
  color: #00fff7;
  font-weight: 600;
  font-family: "JetBrainsMono Nerd Font", monospace;
  font-size: 9pt;
  transition: all 0.1s ease;
}

#custom-notifications:hover {
  background: rgba(0,255,247,0.06);
  border-radius: 6px;
  color: #ffffff;
  box-shadow: 0 0 12px rgba(0,255,247,0.4);
}

/* === ENHANCED HOVER INTERACTIONS === */
#cpu:hover, #memory:hover, #temperature:hover, #disk:hover,
#mpris:hover {
  background: rgba(0,255,247,0.08);
  border-radius: 6px;
  box-shadow: 
    inset 0 0 12px rgba(0,255,247,0.15),
    0 0 16px rgba(0,255,247,0.5);
}

#network:hover, #battery:hover, #pulseaudio:hover,
#bluetooth:hover, #custom-notifications:hover, #custom-vpn-ip:hover {
  background: rgba(0,255,247,0.06);
  border-radius: 6px;
  box-shadow: 0 0 12px rgba(0,255,247,0.4);
}

/* === WINDOW TITLE MODULE === */
#window {
  font-weight: 600;
  font-family: "JetBrainsMono Nerd Font", monospace;
  font-size: 9pt;
  padding: 2px 12px;
  color: #b8c9e8;
}

#window:hover {
  color: #00fff7;
  text-shadow: 0 0 8px rgba(0,255,247,0.6);
}

/* === MEDIA PLAYER (NOTCH) === */
#mpris {
  font-weight: 700;
  font-family: "Hack Nerd Font Mono", "JetBrainsMono Nerd Font", monospace;
  font-size: 8pt;
  color: #b8c9e8;
  padding: 2px 12px;
  min-width: 50px;
  background: transparent;
  border: none;
  border-right: 1px solid rgba(0,255,247,0.2);
  margin: 0 4px;
}

#mpris.playing {
  color: #00fff7;
  text-shadow: 0 0 8px rgba(0,255,247,0.6);
}

#mpris.paused {
  color: #ffaa00;
  text-shadow: 0 0 6px rgba(255,170,0,0.5);
}

#mpris.stopped {
  color: #5a6a82;
  font-size: 10pt;
  letter-spacing: 0px;
}

/* === NETWORK & BATTERY === */
#network, #battery {
  font-weight: 600;
  font-family: "JetBrainsMono Nerd Font", monospace;
}

#network.disconnected {
  font-weight: 700;
}

#battery.charging {
  color: #00fff7;
  border-left: 2px solid #00fff7;
  box-shadow: 
    inset 0 0 6px rgba(0,255,247,0.1),
    0 0 8px rgba(0,255,247,0.4);
}

/* === PULSEAUDIO === */
#pulseaudio {
  font-weight: 600;
  font-family: "JetBrainsMono Nerd Font", monospace;
}

#pulseaudio.muted {
  color: #ff6b8a;
  border-left: 2px solid rgba(255,0,60,0.5);
}

  '';
}
