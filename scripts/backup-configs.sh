#!/bin/bash
# Script to backup current dotfiles before installation

backup_dir="$HOME/config-backup-$(date +%Y%m%d-%H%M%S)"
echo "🔄 Creating backup directory: $backup_dir"
mkdir -p "$backup_dir"

# Backup important configuration directories
configs=(
    ".config/hypr"
    ".config/waybar"
    ".config/rofi" 
    ".config/swaync"
    ".config/ghostty"
    ".config/fish"
    ".config/wallpapers"
)

for config in "${configs[@]}"; do
    if [[ -e "$HOME/$config" ]]; then
        echo "📋 Backing up $config..."
        cp -r "$HOME/$config" "$backup_dir/"
    fi
done

echo "✅ Backup completed: $backup_dir"