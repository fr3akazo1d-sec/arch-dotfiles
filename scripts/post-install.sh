#!/bin/bash
# Post-installation setup script

echo "🎉 Welcome to your new Arch Linux setup!"
echo "🔧 Running post-installation configuration..."

# Make sure user directories exist
mkdir -p ~/Pictures/Screenshots
mkdir -p ~/Documents/Scripts
mkdir -p ~/Downloads

# Set executable permissions for scripts
chmod +x ~/.local/bin/*

# Setup git if not configured
if ! git config --global user.name &> /dev/null; then
    echo "⚙️ Setting up Git configuration..."
    read -p "Enter your Git username: " git_name
    read -p "Enter your Git email: " git_email
    git config --global user.name "$git_name"
    git config --global user.email "$git_email"
    echo "✅ Git configured"
fi

# Enable user services
echo "🔧 Enabling user services..."
systemctl --user enable pipewire pipewire-pulse wireplumber

echo "✅ Post-installation setup completed!"
echo ""
echo "🚀 Next steps:"
echo "  1. Reboot your system"
echo "  2. Login and select 'Hyprland' session"
echo "  3. Press Super+Return to open terminal"
echo "  4. Run 'fish' to start Fish shell"
echo "  5. Type 'showall' to see available functions"
echo ""
echo "🎮 Key shortcuts:"
echo "  Super+Return  - Terminal"
echo "  Super+D       - App launcher"
echo "  Super+Q       - Close window"
echo "  Super+1-9     - Switch workspaces"