# 🚀 Quick Installation Guide

## For Fresh Arch Linux Installation

### 1. Download the Repository
```bash
# Download the repository
curl -L https://github.com/fr3akazo1d-sec/arch-dotfiles/archive/main.zip -o arch-dotfiles.zip
unzip arch-dotfiles.zip
cd arch-dotfiles-main

# OR clone with git
git clone https://github.com/fr3akazo1d-sec/arch-dotfiles.git
cd arch-dotfiles
```

### 2. Run the Complete Setup
```bash
# Make the script executable
chmod +x complete-arch-setup.sh

# Run the installation (will ask for confirmation)
./complete-arch-setup.sh
```

### 3. Reboot and Enjoy
```bash
# Reboot your system
sudo reboot

# After reboot:
# 1. Select "Hyprland" at login screen
# 2. Press Super+Return to open terminal
# 3. Type 'fish' to start Fish shell
# 4. Type 'showall' to see all available functions
```

## What Gets Installed

### 🖥️ Desktop Environment
- **Hyprland** - Wayland compositor with tiling
- **Waybar** - Status bar with custom themes
- **Rofi** - Application launcher
- **SwayNC** - Notification center
- **Ghostty** - Terminal emulator

### 🐟 Shell & Tools
- **Fish Shell** with 90+ cybersecurity functions
- **Starship** prompt

### 🛡️ Cybersecurity Tools
- Network tools (nmap, wireshark, etc.)
- Organized workspace at `/opt/Cyber-Sec/`
- HackTheBox, TryHackMe, HackSmarter integration

### 📦 Package Management
- **Pacman** packages (base system)
- **AUR** packages via yay

## Key Shortcuts (After Installation)

| Shortcut | Action |
|----------|--------|
| `Super + Return` | Open terminal |
| `Super + D` | Application launcher |
| `Super + Q` | Close window |
| `Super + 1-9` | Switch workspaces |
| `Super + F` | Toggle fullscreen |

## Useful Fish Commands

```fish
showall     # Show all custom functions
htb         # HackTheBox workspace
thm         # TryHackMe workspace
cyberlist   # Browse security tools
myips       # Show network interfaces
reload      # Reload Fish config
```

## Updating Your Setup

```bash
# Update dotfiles
~/update-dotfiles.sh

# Update system packages
sudo pacman -Syu
yay -Syu

```

## Troubleshooting

### If Hyprland doesn't start
1. Check logs: `journalctl --user -xe`
2. Try starting manually: `Hyprland`
3. Check configuration: `hyprland --config ~/.config/hypr/hyprland.conf`

### If Fish functions don't work
1. Reload config: `source ~/.config/fish/config.fish`
2. Check file: `cat ~/.config/fish/config.fish`

### If services don't start
1. Enable manually: `systemctl --user enable service-name`
2. Check status: `systemctl --user status service-name`

## Getting Help

- 🐛 **Issues**: [GitHub Issues](https://github.com/fr3akazo1d-sec/arch-dotfiles/issues)
- 📖 **Wiki**: Check the repository wiki for detailed guides
- 💬 **Community**: Join discussions in GitHub Discussions