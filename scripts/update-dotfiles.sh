#!/bin/bash
# Script to update dotfiles from the repository

echo "🔄 Updating dotfiles from repository..."
cd ~/.dotfiles
git pull

echo "📋 Copying configurations..."

# Copy all configuration files
cp -r config/hypr/* ~/.config/hypr/
cp -r config/waybar/* ~/.config/waybar/
cp -r config/rofi/* ~/.config/rofi/
cp -r config/swaync/* ~/.config/swaync/
cp -r config/ghostty/* ~/.config/ghostty/
cp -r config/fish/* ~/.config/fish/

# Copy wallpapers
mkdir -p ~/.config/wallpapers
cp -r wallpapers/* ~/.config/wallpapers/

# Copy starship config if it exists
if [[ -f config/starship.toml ]]; then
    cp config/starship.toml ~/.config/
fi

# Copy scripts
cp -r scripts/* ~/.local/bin/
chmod +x ~/.local/bin/*

echo "✅ Dotfiles updated!"
echo "🔄 Restart Hyprland (Super+Shift+Q) or reload configurations to apply changes"

# Reload Fish configuration
if [[ "$SHELL" == *"fish"* ]]; then
    fish -c "source ~/.config/fish/config.fish"
fi