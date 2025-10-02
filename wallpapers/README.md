# Wallpapers Directory

This directory contains wallpapers used by your Hyprland setup.

## Installation Location

Wallpapers are installed to:
- `~/.config/wallpapers/` - Primary location (matches your setup)
- `~/Pictures/Wallpapers/` - Secondary location for compatibility

## Adding Wallpapers

1. Copy your wallpaper files (jpg, png) to this directory
2. Update your Hyprland configuration to use them:
   ```conf
   exec-once = hyprpaper
   ```
3. Configure hyprpaper in `~/.config/hypr/hyprpaper.conf`:
   ```conf
   preload = ~/.config/wallpapers/your-wallpaper.jpg
   wallpaper = ,~/.config/wallpapers/your-wallpaper.jpg
   ```

## Recommended Wallpapers

- Cyberpunk themes
- Dark abstract patterns  
- Matrix-style imagery
- Neon/synthwave aesthetics

## Sources

Popular wallpaper sources:
- [Wallhaven](https://wallhaven.cc)
- [Unsplash](https://unsplash.com)
- [Reddit /r/wallpapers](https://reddit.com/r/wallpapers)
- [DeviantArt](https://deviantart.com)