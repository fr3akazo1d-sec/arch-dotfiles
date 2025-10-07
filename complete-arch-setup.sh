#!/bin/bash

# 🐧 Complete Arch Linux Desktop + Cybersecurity Setup
# Installs Hyprland, Waybar, Rofi, Ghostty, SwayNC + Fish + Cybersec tools
# Author: fr3akazo1d-sec
# Version: 2.0

set -e

# Colors and emojis
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

ROCKET="🚀"
GEAR="⚙️"
DESKTOP="🖥️"
FISH="🐟"
SHIELD="🛡️"
CHECK="✅"
WARN="⚠️"
ERROR="❌"
INFO="ℹ️"
HYPR="💎"

print_header() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════════╗"
    echo "║         🐧 Complete Arch Linux Desktop + Cybersec Setup 🔒      ║"
    echo "║      Hyprland + Waybar + Rofi + Ghostty + Fish + Nix + Tools    ║"
    echo "╚══════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

log() { echo -e "${GREEN}${CHECK}${NC} $1"; }
warn() { echo -e "${YELLOW}${WARN}${NC} $1"; }
error() { echo -e "${RED}${ERROR}${NC} $1"; exit 1; }
info() { echo -e "${BLUE}${INFO}${NC} $1"; }
step() { echo -e "\n${PURPLE}${GEAR}${NC} ${CYAN}$1${NC}"; }

# Configuration
DOTFILES_REPO="fr3akazo1d-sec/arch-dotfiles"
DOTFILES_DIR="$HOME/.dotfiles"

check_root() {
    if [[ $EUID -eq 0 ]]; then
        error "This script should NOT be run as root! Run as your regular user."
    fi
}

check_distro() {
    if [[ ! -f /etc/arch-release ]]; then
        error "This script is designed specifically for Arch Linux! 
        
Current system detected: $(lsb_release -d 2>/dev/null | cut -f2 || echo "Unknown Linux")

For other distributions, you'll need to:
1. Replace 'pacman' with your package manager (apt/dnf/zypper)
2. Map package names to your distro's repositories
3. Handle AUR packages differently (compile from source)
4. Adjust paths and service configurations

Consider creating a distro-specific version of this script."
    fi
}

# Setup Chaotic-AUR repository for faster AUR package installation
setup_chaotic_aur() {
    step "Setting up Chaotic-AUR repository for faster package installation"
    
    # Check if Chaotic-AUR is already configured
    if grep -q "\[chaotic-aur\]" /etc/pacman.conf; then
        info "Chaotic-AUR repository already configured"
        return 0
    fi
    
    info "Adding Chaotic-AUR keyring and mirrorlist..."
    
    # Add the primary key
    sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com || warn "Failed to receive key, continuing..."
    sudo pacman-key --lsign-key 3056513887B78AEB || warn "Failed to sign key, continuing..."
    
    # Install keyring and mirrorlist packages
    info "Installing Chaotic-AUR keyring and mirrorlist..."
    sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' || warn "Failed to install chaotic-keyring"
    sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' || warn "Failed to install chaotic-mirrorlist"
    
    # Add repository to pacman.conf
    info "Adding Chaotic-AUR repository to pacman.conf..."
    echo "" | sudo tee -a /etc/pacman.conf
    echo "[chaotic-aur]" | sudo tee -a /etc/pacman.conf
    echo "Include = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf
    
    log "Chaotic-AUR repository configured successfully"
}

# Setup Athena OS repository for cybersecurity tools
setup_athena_repo() {
    step "Setting up Athena OS repository for enhanced cybersecurity tools"
    
    # Check if Athena repository is already configured
    if grep -q "\[athena\]" /etc/pacman.conf; then
        info "Athena OS repository already configured"
        return 0
    fi
    
    info "Adding Athena OS repository and key..."
    
    # Download mirrorlist
    sudo curl -s https://raw.githubusercontent.com/Athena-OS/athena/main/packages/os-specific/system/athena-mirrorlist/athena-mirrorlist -o /etc/pacman.d/athena-mirrorlist || warn "Failed to download Athena mirrorlist"
    
    # Add Athena key (try multiple keyservers for reliability)
    if ! sudo pacman-key --recv-keys A3F78B994C2171D5 --keyserver keys.openpgp.org; then
        warn "Primary keyserver failed, trying alternative..."
        sudo pacman-key --recv-keys A3F78B994C2171D5 --keyserver keyserver.ubuntu.com || warn "Failed to receive Athena key"
    fi
    
    # Trust the key
    sudo pacman-key --lsign A3F78B994C2171D5 || warn "Failed to sign Athena key"
    
    # Add repository to pacman.conf
    info "Adding Athena OS repository to pacman.conf..."
    echo "" | sudo tee -a /etc/pacman.conf
    echo "[athena]" | sudo tee -a /etc/pacman.conf
    echo "SigLevel = Optional TrustedOnly" | sudo tee -a /etc/pacman.conf
    echo "Include = /etc/pacman.d/athena-mirrorlist" | sudo tee -a /etc/pacman.conf
    
    log "Athena OS repository configured successfully"
}

# Update system and install base packages
install_base_packages() {
    step "Updating system and installing base packages"
    
    # Full system update with new repositories
    sudo pacman -Syu --noconfirm
    
    # Essential packages
    local packages=(
        # Base system
        "base-devel"
        "git"
        "curl"
        "wget"
        "unzip"
        "p7zip"
        
        # Wayland/Hyprland ecosystem
        "hyprland"
        "xdg-desktop-portal-hyprland"
        "waybar"
        "rofi-wayland"
        "swaync"
        "swaylock-effects"
        "swayidle"
        "wl-clipboard"
        "grim"
        "slurp"
        "swappy"
        "hyprpaper"
        "hypridle"
        "hyprlock"
        
        # Audio
        "pipewire"
        "pipewire-alsa"
        "pipewire-pulse"
        "wireplumber"
        "pavucontrol"
        
        # Fonts
        "ttf-nerd-fonts-symbols-mono"
        "ttf-jetbrains-mono-nerd"
        "ttf-font-awesome"
        "noto-fonts"
        "noto-fonts-emoji"
        
        # Graphics and OpenGL support
        "mesa"
        "mesa-utils"
        "vulkan-tools"
        "libgl"
        "lib32-mesa"
        "xf86-video-intel"
        "xf86-video-amdgpu"
        "xf86-video-nouveau"
        
        # GTK themes and appearance
        "gtk2"
        "gtk3"
        "gtk4"
        "materia-gtk-theme"
        "papirus-icon-theme"
        "bibata-cursor-theme"
        "nwg-look"
        "lxappearance"
        
        # Terminal and shell
        "fish"
        "starship"
        "neovim"
        "kitty"
        "alacritty"
        
        # File management
        "thunar"
        "thunar-volman"
        "thunar-archive-plugin"
        
        # System tools
        "htop"
        "btop"
        "neofetch"
        "tree"
        "fzf"
        "bat"
        "exa"
        "ripgrep"
        "fd"
        
        # Network tools
        "networkmanager"
        "network-manager-applet"
        "bluez"
        "bluez-utils"
        "blueman"
        
        # Media
        "mpv"
        "imv"
        
        # Development
        "code"
        
        # Cybersecurity tools
        "nmap"
        "wireshark-qt"
        "tcpdump"
        "lsof"
        "burpsuite"
        
        # System utilities
        "brightnessctl"
        "playerctl"
        "polkit-kde-agent"
    )
    
    for package in "${packages[@]}"; do
        info "Installing $package..."
        sudo pacman -S --noconfirm "$package" || warn "Failed to install $package, continuing..."
    done
    
    log "Base packages installed successfully"
}

# Install enhanced cybersecurity tools from Athena repository
install_athena_tools() {
    step "Installing enhanced cybersecurity tools from Athena OS repository"
    
    # Popular Athena OS cybersecurity tools
    local athena_tools=(
        "metasploit"
        "john"
        "hashcat"
        "aircrack-ng"
        "nikto"
        "sqlmap"
        "gobuster"
        "ffuf"
        "wordlists"
        "seclists"
        "payloadsallthethings"
        "exploitdb"
        "sherlock-project"
        "social-engineer-toolkit"
    )
    
    info "Attempting to install enhanced cybersecurity tools from Athena repository..."
    
    for tool in "${athena_tools[@]}"; do
        info "Installing $tool..."
        # Try to install from Athena repository, continue if not available
        sudo pacman -S --noconfirm "$tool" 2>/dev/null || info "$tool not available in Athena repo, skipping..."
    done
    
    log "Athena cybersecurity tools installation completed"
}

# Install AUR helper and AUR packages
install_aur_packages() {
    step "Installing AUR helper and AUR packages"
    
    # Install AUR helper (paru preferred, yay fallback)
    if ! command -v paru &> /dev/null && ! command -v yay &> /dev/null; then
        info "Installing yay AUR helper first..."
        cd /tmp
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd ~
    fi
    
    # Install paru if not present (preferred AUR helper)
    if ! command -v paru &> /dev/null; then
        if command -v yay &> /dev/null; then
            info "Installing paru AUR helper using yay..."
            yay -S --noconfirm paru
        else
            info "Installing paru AUR helper from source..."
            cd /tmp
            git clone https://aur.archlinux.org/paru.git
            cd paru
            makepkg -si --noconfirm
            cd ~
        fi
    fi
    
    # AUR packages (try Chaotic-AUR first, then compile if needed)
    local aur_packages=(
        "ghostty-git"           # Terminal
        "hyprpicker"            # Color picker
        "wlogout"              # Logout menu
        "waybar-hyprland-git"  # Enhanced waybar
        "rofi-calc"            # Calculator for rofi
        "rofi-emoji"           # Emoji picker
        "visual-studio-code-bin"
        "discord"
        "spotify"
        "vivaldi"
        "bibata-cursor-theme-bin"  # Enhanced cursor theme
        "qt5ct"                    # Qt5 configuration tool
    )
    
    for package in "${aur_packages[@]}"; do
        info "Installing $package..."
        # Try pacman first (Chaotic-AUR), then fall back to paru
        if ! sudo pacman -S --noconfirm "$package" 2>/dev/null; then
            info "$package not available in Chaotic-AUR, compiling from AUR..."
            paru -S --noconfirm "$package" || warn "Failed to install $package"
        else
            info "$package installed from Chaotic-AUR (pre-compiled)"
        fi
    done
    
    log "AUR packages installed"
}

# Clone dotfiles repository
clone_dotfiles() {
    step "Cloning dotfiles repository"
    
    if [[ -d "$DOTFILES_DIR" ]]; then
        warn "Dotfiles directory already exists, updating..."
        cd "$DOTFILES_DIR"
        git pull
    else
        info "Cloning dotfiles repository..."
        git clone "https://github.com/$DOTFILES_REPO.git" "$DOTFILES_DIR"
    fi
    
    log "Dotfiles repository ready"
}

# Backup existing configurations
backup_configs() {
    step "Backing up existing configurations"
    
    local backup_dir="$HOME/config-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"
    
    # Backup directories to check
    local config_dirs=(
        ".config/hypr"
        ".config/waybar"
        ".config/rofi"
        ".config/swaync"
        ".config/fish"
        ".config/ghostty"
        ".config/wallpapers"
        ".config/starship.toml"
    )
    
    for config in "${config_dirs[@]}"; do
        if [[ -e "$HOME/$config" ]]; then
            info "Backing up $config..."
            cp -r "$HOME/$config" "$backup_dir/" 2>/dev/null || true
        fi
    done
    
    log "Configurations backed up to $backup_dir"
}

# Install dotfiles
install_dotfiles() {
    step "Installing dotfiles and configurations"
    
    cd "$DOTFILES_DIR"
    
    # Create necessary directories
    mkdir -p ~/.config/{hypr,waybar,rofi,swaync,fish,ghostty}
    
    # Copy configuration files
    info "Installing Hyprland configuration..."
    cp -r config/hypr/* ~/.config/hypr/ 2>/dev/null || true
    
    info "Installing Waybar configuration..."
    cp -r config/waybar/* ~/.config/waybar/ 2>/dev/null || true
    
    info "Installing Rofi configuration..."
    cp -r config/rofi/* ~/.config/rofi/ 2>/dev/null || true
    
    info "Installing SwayNC configuration..."
    cp -r config/swaync/* ~/.config/swaync/ 2>/dev/null || true
    
    info "Installing Fish configuration..."
    cp -r config/fish/* ~/.config/fish/ 2>/dev/null || true
    
    info "Installing Ghostty configuration..."
    cp -r config/ghostty/* ~/.config/ghostty/ 2>/dev/null || true
    
    # Starship configuration (if exists)
    if [[ -f config/starship.toml ]]; then
        info "Installing Starship configuration..."
        cp config/starship.toml ~/.config/
    fi
    
    # Copy wallpapers
    info "Installing wallpapers..."
    mkdir -p ~/.config/wallpapers
    mkdir -p ~/Pictures/Wallpapers
    cp -r wallpapers/* ~/.config/wallpapers/ 2>/dev/null || true
    cp -r wallpapers/* ~/Pictures/Wallpapers/ 2>/dev/null || true
    
    # Copy scripts
    info "Installing scripts..."
    mkdir -p ~/.local/bin
    cp -r scripts/* ~/.local/bin/ 2>/dev/null || true
    chmod +x ~/.local/bin/* 2>/dev/null || true
    
    log "Dotfiles installed successfully"
}

# Setup GTK themes and appearance
setup_gtk_themes() {
    step "Setting up GTK themes and appearance (Athena/HTB Dark Theme)"
    
    # Create GTK config directories
    mkdir -p ~/.config/gtk-3.0
    mkdir -p ~/.config/gtk-4.0
    
    info "Installing GTK theme configurations..."
    
    # Install GTK configurations
    if [[ -f "$DOTFILES_DIR/config/gtk/.gtkrc-2.0" ]]; then
        cp "$DOTFILES_DIR/config/gtk/.gtkrc-2.0" ~/
        cp "$DOTFILES_DIR/config/gtk/.gtkrc-2.0.mine" ~/ 2>/dev/null || true
    fi
    
    if [[ -f "$DOTFILES_DIR/config/gtk/gtk-3.0/settings.ini" ]]; then
        cp "$DOTFILES_DIR/config/gtk/gtk-3.0/settings.ini" ~/.config/gtk-3.0/
    fi
    
    if [[ -f "$DOTFILES_DIR/config/gtk/gtk-4.0/settings.ini" ]]; then
        cp "$DOTFILES_DIR/config/gtk/gtk-4.0/settings.ini" ~/.config/gtk-4.0/
    fi
    
    # Apply themes using gsettings (for immediate effect)
    info "Applying GTK themes..."
    gsettings set org.gnome.desktop.interface gtk-theme 'Materia-dark' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Classic' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface cursor-size 24 2>/dev/null || true
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
    
    # Set Qt theme to match GTK
    export QT_QPA_PLATFORMTHEME=gtk3
    echo 'export QT_QPA_PLATFORMTHEME=gtk3' >> ~/.profile 2>/dev/null || true
    
    log "GTK themes configured for Athena/HTB dark aesthetic"
}

# Setup Fish shell
setup_fish_shell() {
    step "Setting up Fish shell"
    
    # Add fish to shells and set as default
    if ! grep -q "$(which fish)" /etc/shells; then
        echo "$(which fish)" | sudo tee -a /etc/shells
    fi
    
    if [[ "$SHELL" != "$(which fish)" ]]; then
        info "Changing default shell to Fish..."
        chsh -s "$(which fish)"
        log "Default shell changed to Fish (takes effect on next login)"
    fi
}

# Install Nix and Home Manager
setup_nix() {
    step "Installing Nix package manager and Home Manager"
    
    if ! command -v nix &> /dev/null; then
        info "Installing Nix..."
        curl -L https://nixos.org/nix/install | sh
        . ~/.nix-profile/etc/profile.d/nix.sh
    fi
    
    # Setup Home Manager
    if ! command -v home-manager &> /dev/null; then
        info "Setting up Home Manager..."
        nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
        nix-channel --update
        nix-shell '<home-manager>' -A install
        
        # Copy Home Manager configuration
        mkdir -p ~/.config/home-manager
        cp "$DOTFILES_DIR/config/home-manager/home.nix" ~/.config/home-manager/ 2>/dev/null || true
    fi
    
    log "Nix and Home Manager setup completed"
}

# Create Cyber-Sec directory structure
create_cybersec_structure() {
    step "Creating Cyber-Sec directory structure"
    
    sudo mkdir -p /opt/Cyber-Sec/{tools,wordlists,payloads,configs,docs,research,hackthebox,tryhackme,hacksmarter}
    sudo chown -R "$USER:$USER" /opt/Cyber-Sec/
    chmod -R 755 /opt/Cyber-Sec/
    
    log "Cyber-Sec directory structure created"
}

# Enable system services
enable_services() {
    step "Enabling system services"
    
    # Enable NetworkManager
    sudo systemctl enable NetworkManager
    sudo systemctl start NetworkManager
    
    # Enable Bluetooth
    sudo systemctl enable bluetooth
    sudo systemctl start bluetooth
    
    # Enable audio
    systemctl --user enable pipewire pipewire-pulse wireplumber
    
    log "System services enabled"
}

# Create desktop session entry
create_session_entry() {
    step "Creating desktop session entry"
    
    sudo mkdir -p /usr/share/wayland-sessions
    
    cat << 'EOF' | sudo tee /usr/share/wayland-sessions/hyprland.desktop
[Desktop Entry]
Name=Hyprland
Comment=An intelligent dynamic tiling Wayland compositor
Exec=Hyprland
Type=Application
EOF
    
    log "Desktop session entry created"
}

# Setup development environment
setup_dev_environment() {
    step "Setting up development environment"
    
    # Create common directories
    mkdir -p ~/Projects ~/Tools ~/Scripts
    
    # Install common Python packages
    if command -v pip &> /dev/null; then
        info "Installing Python packages..."
        pip install --user --upgrade pip requests beautifulsoup4 pwntools
    fi
    
    # Setup Git (if not configured)
    if ! git config --global user.name &> /dev/null; then
        info "Setting up Git configuration..."
        echo "Enter your Git username:"
        read -r git_name
        echo "Enter your Git email:"
        read -r git_email
        git config --global user.name "$git_name"
        git config --global user.email "$git_email"
    fi
    
    log "Development environment setup completed"
}

# Final setup and cleanup
final_setup() {
    step "Performing final setup"
    
    # Apply Home Manager configuration
    if command -v home-manager &> /dev/null; then
        info "Applying Home Manager configuration..."
        home-manager switch || warn "Home Manager configuration failed"
    fi
    
    # Create update script
    cat > ~/update-dotfiles.sh << 'EOF'
#!/bin/bash
echo "🔄 Updating dotfiles..."
cd ~/.dotfiles
git pull
echo "📋 Copying configurations..."
cp -r config/hypr/* ~/.config/hypr/
cp -r config/waybar/* ~/.config/waybar/
cp -r config/rofi/* ~/.config/rofi/
cp -r config/swaync/* ~/.config/swaync/
cp -r config/fish/* ~/.config/fish/
cp -r config/ghostty/* ~/.config/ghostty/
# Copy starship config if it exists
if [[ -f config/starship.toml ]]; then
    cp config/starship.toml ~/.config/
fi
# Copy home-manager config
if [[ -f config/home-manager/home.nix ]]; then
    mkdir -p ~/.config/home-manager
    cp config/home-manager/home.nix ~/.config/home-manager/
fi
echo "✅ Dotfiles updated!"
echo "🔄 Restart Hyprland or reload configurations to apply changes"
EOF
    chmod +x ~/update-dotfiles.sh
    
    # Clean package cache
    sudo pacman -Sc --noconfirm
    paru -Sc --noconfirm
    
    log "Final setup completed"
}

# Print completion message
print_completion() {
    echo -e "\n${GREEN}"
    echo "╔══════════════════════════════════════════════════════════════════╗"
    echo "║                    🎉 SETUP COMPLETED! 🎉                       ║"
    echo "╚══════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo -e "${CYAN}${ROCKET} Your complete Arch Linux cybersecurity environment is ready!${NC}\n"
    
    echo -e "${YELLOW}What was installed:${NC}"
    echo -e "  ${HYPR} Hyprland with complete Wayland setup"
    echo -e "  ${DESKTOP} Waybar, Rofi, SwayNC, Ghostty terminal"
    echo -e "  ${FISH} Fish shell with 90+ cybersecurity functions"
    echo -e "  ${SHIELD} Complete cybersecurity toolkit with Athena OS tools"
    echo -e "  ${GEAR} Nix package manager with Home Manager"
    echo -e "  ${ROCKET} Chaotic-AUR + Athena OS repositories for enhanced packages"
    
    echo -e "\n${YELLOW}Next steps:${NC}"
    echo -e "  1. ${BLUE}Reboot your system${NC}"
    echo -e "  2. ${BLUE}Login and select 'Hyprland' session${NC}"
    echo -e "  3. ${BLUE}Press Super+Return${NC} to open Ghostty terminal"
    echo -e "  4. ${BLUE}Run 'fish'${NC} to start Fish shell with enhanced greeting"
    echo -e "  5. ${BLUE}Run 'rt'${NC} to check red team infrastructure status"
    
    echo -e "\n${GREEN}Key shortcuts (after reboot):${NC}"
    echo -e "  ${CYAN}Super + Return${NC}        - Open terminal (Ghostty)"
    echo -e "  ${CYAN}Super + D${NC}             - Application launcher (Rofi)"
    echo -e "  ${CYAN}Super + Q${NC}             - Close window"
    echo -e "  ${CYAN}Super + M${NC}             - Exit Hyprland"
    echo -e "  ${CYAN}Super + V${NC}             - Toggle floating"
    echo -e "  ${CYAN}Super + F${NC}             - Toggle fullscreen"
    echo -e "  ${CYAN}Super + 1-9${NC}           - Switch workspaces"
    
    echo -e "\n${PURPLE}Useful Fish commands:${NC}"
    echo -e "  ${CYAN}rt / redteam-status${NC}     - Red team infrastructure check"
    echo -e "  ${CYAN}sys / sys-status${NC}        - System resource monitoring" 
    echo -e "  ${CYAN}tools / tools-check${NC}     - Cybersec arsenal status"
    echo -e "  ${CYAN}net / net-recon${NC}         - Network reconnaissance"
    echo -e "  ${CYAN}cyberlist${NC}               - Browse all security functions"
    echo -e "  ${CYAN}~/update-dotfiles.sh${NC}    - Update configurations"
    
    echo -e "\n${PURPLE}Theme Configuration:${NC}"
    echo -e "  ${CYAN}GTK Theme${NC}               - Materia-dark (Athena/HTB aesthetic)"
    echo -e "  ${CYAN}Icon Theme${NC}              - Papirus-Dark"
    echo -e "  ${CYAN}Cursor Theme${NC}            - Bibata-Modern-Classic"
    echo -e "  ${CYAN}Ghostty Terminal${NC}        - Fr3akazo1d theme with OpenGL fallback"
    
    echo -e "\n${GREEN}Happy hacking with your enhanced cybersecurity workstation! 🏴‍☠️${NC}"
    echo -e "${CYAN}Repository: https://github.com/fr3akazo1d-sec/arch-dotfiles${NC}"
}

# Main execution

# Print completion message
print_completion() {
    echo -e "\n${GREEN}"
    echo "╔══════════════════════════════════════════════════════════════════╗"
    echo "║                    🎉 SETUP COMPLETED! 🎉                       ║"
    echo "╚══════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo -e "${CYAN}${ROCKET} Your complete Arch Linux environment is ready!${NC}\n"
    
    echo -e "${YELLOW}What was installed:${NC}"
    echo -e "  ${HYPR} Hyprland with complete Wayland setup"
    echo -e "  ${DESKTOP} Waybar, Rofi, SwayNC, Ghostty terminal"
    echo -e "  ${FISH} Fish shell with 90+ cybersecurity functions"
    echo -e "  ${SHIELD} Complete cybersecurity toolkit"
    echo -e "  ${GEAR} Nix package manager with Home Manager"
    
    echo -e "\n${YELLOW}Next steps:${NC}"
    echo -e "  1. ${BLUE}Reboot your system${NC}"
    echo -e "  2. ${BLUE}Login and select 'Hyprland' session${NC}"
    echo -e "  3. ${BLUE}Press Super+Return${NC} to open Ghostty terminal"
    echo -e "  4. ${BLUE}Run 'fish'${NC} to start Fish shell"
    echo -e "  5. ${BLUE}Run 'showall'${NC} to see all available functions"
    
    echo -e "\n${GREEN}Key shortcuts (after reboot):${NC}"
    echo -e "  ${CYAN}Super + Return${NC}        - Open terminal (Ghostty)"
    echo -e "  ${CYAN}Super + D${NC}             - Application launcher (Rofi)"
    echo -e "  ${CYAN}Super + Q${NC}             - Close window"
    echo -e "  ${CYAN}Super + M${NC}             - Exit Hyprland"
    echo -e "  ${CYAN}Super + V${NC}             - Toggle floating"
    echo -e "  ${CYAN}Super + F${NC}             - Toggle fullscreen"
    echo -e "  ${CYAN}Super + 1-9${NC}           - Switch workspaces"
    
    echo -e "\n${PURPLE}Useful commands:${NC}"
    echo -e "  ${CYAN}~/update-dotfiles.sh${NC}     - Update configurations"
    echo -e "  ${CYAN}cyberlist${NC}                - Browse security tools"
    echo -e "  ${CYAN}myips${NC}                    - Show network interfaces"
    echo -e "  ${CYAN}htb / thm / hs${NC}           - Quick access to learning platforms"
    
    echo -e "\n${GREEN}Happy hacking with your new desktop! 🏴‍☠️${NC}"
}

# Main execution
main() {
    print_header
    
    info "This will install a complete Arch Linux desktop environment with:"
    info "• Hyprland (Wayland compositor)"
    info "• Waybar (Status bar)"
    info "• Rofi (Application launcher)"
    info "• Ghostty (Terminal)"
    info "• SwayNC (Notification center)"
    info "• Fish shell + cybersecurity tools"
    info "• Nix package manager"
    info "• Complete dotfiles configuration"
    
    read -p "Continue with the complete setup? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        error "Setup cancelled by user"
    fi
    
    check_root
    check_distro
    setup_chaotic_aur
    setup_athena_repo
    install_base_packages
    install_athena_tools
    install_aur_packages
    clone_dotfiles
    backup_configs
    install_dotfiles
    setup_gtk_themes
    setup_fish_shell
    setup_nix
    create_cybersec_structure
    enable_services
    create_session_entry
    setup_dev_environment
    final_setup
    print_completion
}

main "$@"