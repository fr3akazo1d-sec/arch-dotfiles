# 🐧 Arch Linux Dotfiles - Complete Desktop + Cybersecurity Setup

[![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)](https://archlinux.org/)
[![Hyprland](https://img.shields.io/badge/Hyprland-00D9FF?style=for-the-badge&logo=wayland&logoColor=white)](https://hyprland.org/)
[![Fish Shell](https://img.shields.io/badge/Fish_Shell-1E1E2E?style=for-the-badge&logo=fish&logoColor=white)](https://fishshell.com/)

A complete Arch Linux desktop environment with Hyprland + comprehensive cybersecurity tools. One script to rule them all! 🚀

![Desktop Preview](https://via.placeholder.com/800x400/1e1e2e/bd93f9?text=Your+Beautiful+Hyprland+Desktop)

## ✨ What's Included

### 🖥️ Desktop Environment
- **Hyprland** - Dynamic tiling Wayland compositor
- **Waybar** - Highly customizable status bar
- **Rofi** - Application launcher and dmenu replacement  
- **SwayNC** - Notification daemon for Wayland
- **Ghostty** - GPU-accelerated terminal emulator

### 🐟 Shell & Terminal
- **Fish Shell** with 90+ cybersecurity functions
- **Starship** prompt with custom cybersec theme
- Comprehensive aliases and shortcuts

### 🛡️ Cybersecurity Arsenal
- **Network Tools**: nmap, wireshark, tcpdump, burpsuite
- **Custom Functions**: Host management, tool organization
- **Learning Platforms**: HackTheBox, TryHackMe, HackSmarter integration
- **Directory Structure**: Organized `/opt/Cyber-Sec/` workspace

### 🎨 Customization
- Beautiful cyberpunk-themed configurations
- Custom wallpapers (Fr3akazo1d Tron theme included)
- Optimized keybindings
- Responsive layouts

## 🚀 One-Click Installation

### Fresh Arch Linux Installation
```bash
# Clone the repository
git clone https://github.com/fr3akazo1d-sec/arch-dotfiles.git
cd arch-dotfiles

# Run the complete setup (installs everything!)
./complete-arch-setup.sh
```

### Existing Arch System
```bash
# If you already have some components installed
./complete-arch-setup.sh
```

The script will:
1. ✅ Update your system
2. ✅ Install all desktop components (Hyprland, Waybar, etc.)
3. ✅ Setup Fish shell with cybersecurity functions
4. ✅ Copy all configuration files
5. ✅ Create cybersecurity workspace
6. ✅ Enable system services
7. ✅ Backup your existing configs

## 📁 Repository Structure

```
arch-dotfiles/
├── 📄 complete-arch-setup.sh      # Main installation script
├── 📁 config/
│   ├── 🎮 hypr/                   # Hyprland configuration
│   │   ├── hyprland.conf          # Main config
│   │   ├── keybinds.conf          # Keybindings
│   │   └── rules.conf             # Window rules
│   ├── 📊 waybar/                 # Waybar configuration
│   │   ├── config.json            # Main config
│   │   └── style.css              # Styling
│   ├── 🚀 rofi/                   # Rofi configuration
│   │   ├── config.rasi            # Main config
│   │   └── themes/                # Custom themes
│   ├── 🔔 swaync/                 # Notification config
│   ├── 🖥️ ghostty/               # Terminal config
│   ├── 🐟 fish/                   # Fish shell config
│   │   └── config.fish            # 90+ cybersec functions
│   └── ⭐ starship.toml           # Prompt config
├── 🖼️ wallpapers/                 # Custom wallpapers
├── 📝 scripts/                    # Utility scripts
└── 📚 README.md                   # This file
```

## ⚡ Key Features

### 🎯 Hyprland Configuration
- **Tiling Management**: Intelligent window tiling
- **Workspaces**: 10 workspaces with smooth animations
- **Keybinds**: Intuitive keyboard shortcuts
- **Effects**: Beautiful animations and blur effects

### 🐟 Fish Shell Functions
Over 90 custom functions including:

```fish
# Quick navigation
htb          # HackTheBox workspace
thm          # TryHackMe workspace  
hs           # HackSmarter workspace

# Network utilities
myips        # Show all network interfaces
addhost      # Add entry to /etc/hosts
rmhost       # Remove from /etc/hosts

# Cybersecurity tools
cyberget     # Install security tools by category
cyberlist    # Browse available tools
cyberupdate  # Update all tools

# System utilities
reload       # Reload Fish configuration
showall      # Display all custom functions
sysinfo      # Detailed system information
```

### 🛡️ Cybersecurity Workspace
Organized directory structure at `/opt/Cyber-Sec/`:
- 🔧 **tools/** - Security applications
- 📝 **wordlists/** - Password lists and dictionaries  
- 💥 **payloads/** - Exploitation payloads
- ⚙️ **configs/** - Tool configurations
- 📚 **docs/** - Documentation and notes
- 🔍 **research/** - Research materials
- 📦 **hackthebox/** - HTB learning materials
- 🎯 **tryhackme/** - THM challenges and walkthroughs
- 🧠 **hacksmarter/** - HackSmarter resources

## 🎮 Keybindings

| Shortcut | Action |
|----------|--------|
| `Super + Return` | Open terminal (Ghostty) |
| `Super + D` | Application launcher (Rofi) |
| `Super + Q` | Close window |
| `Super + M` | Exit Hyprland |
| `Super + V` | Toggle floating |
| `Super + F` | Toggle fullscreen |
| `Super + 1-9` | Switch workspaces |
| `Super + Shift + 1-9` | Move window to workspace |
| `Super + ←↑→↓` | Navigate windows |
| `Super + Shift + ←↑→↓` | Move windows |

## 🔧 Customization

### Adding Your Own Configurations
1. **Hyprland**: Edit `config/hypr/hyprland.conf`
2. **Waybar**: Modify `config/waybar/config.json`
3. **Fish**: Add functions to `config/fish/config.fish`
4. **Rofi**: Customize themes in `config/rofi/`

### Updating Dotfiles
```bash
# Run the update script (created during installation)
~/update-dotfiles.sh
```

### Adding Wallpapers
1. Add images to `wallpapers/` directory
2. Update Hyprland config to point to new wallpaper
3. Commit and push changes

## 🛠️ Manual Configuration Steps

### After Installation

1. **Reboot** your system
2. **Login** and select "Hyprland" session
3. **Terminal**: Press `Super + Return`
4. **Shell**: Type `fish` to start Fish shell
5. **Functions**: Run `showall` to see available commands

### Optional: HackTheBox/TryHackMe Setup
```fish
# Connect to VPN and start hacking!
htb           # Navigate to HackTheBox workspace
thm           # Navigate to TryHackMe workspace
cyberget      # Install additional tools as needed
```

## 📦 Package Management

### AUR Packages
Several AUR packages are automatically installed:
- `ghostty-git` - Modern terminal
- `hyprpicker` - Color picker
- `wlogout` - Logout menu
- `rofi-calc` - Calculator plugin

## 🔄 Updates & Maintenance

### Keeping Everything Fresh
```fish
# Update system packages
sudo pacman -Syu

# Update AUR packages  
yay -Syu

# Update dotfiles
~/update-dotfiles.sh

```

### Backup Your Configs
The installation script automatically creates backups in:
`~/config-backup-YYYYMMDD-HHMMSS/`

## 🤝 Contributing

1. **Fork** the repository
2. **Create** your feature branch (`git checkout -b feature/AmazingFeature`)
3. **Commit** your changes (`git commit -m 'Add some AmazingFeature'`)
4. **Push** to the branch (`git push origin feature/AmazingFeature`)
5. **Open** a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Hyprland** team for the amazing Wayland compositor
- **Fish Shell** community for the powerful shell
- **Arch Linux** community for the best rolling release distro
- **Cybersecurity** community for inspiration and tools

## 📞 Support

- 🐛 **Issues**: [GitHub Issues](https://github.com/fr3akazo1d-sec/arch-dotfiles/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/fr3akazo1d-sec/arch-dotfiles/discussions)
- 📧 **Contact**: Create an issue for support

---

<div align="center">

**Made with ❤️ for the cybersecurity community**

[![GitHub stars](https://img.shields.io/github/stars/fr3akazo1d-sec/arch-dotfiles?style=social)](https://github.com/fr3akazo1d-sec/arch-dotfiles/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/fr3akazo1d-sec/arch-dotfiles?style=social)](https://github.com/fr3akazo1d-sec/arch-dotfiles/network/members)

</div>