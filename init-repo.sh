#!/bin/bash
# Initialize GitHub repository for arch-dotfiles

cd ~/arch-dotfiles

# Initialize git repository
git init

# Create .gitignore
cat > .gitignore << 'EOF'
# Ignore sensitive files
*.log
*.tmp
*~

# Ignore cache directories
.cache/
cache/

# Ignore personal wallpapers (optional)
# wallpapers/personal/

# Ignore generated files
*.pid
*.lock

# OS generated files
.DS_Store
Thumbs.db

# Editor files
.vscode/
*.swp
*.swo
EOF

# Add all files
git add .

# Initial commit
git commit -m "🚀 Initial commit: Complete Arch Linux dotfiles

✨ Features:
- 🖥️ Hyprland configuration with tiling window management
- 📊 Waybar status bar with custom styling  
- 🚀 Rofi application launcher with themes
- 🔔 SwayNC notification center
- 🖥️ Ghostty terminal configuration
- 🐟 Fish shell with 90+ cybersecurity functions
- 🛡️ Complete cybersecurity toolkit integration
- 📦 HackTheBox, TryHackMe, HackSmarter support
- 🔧 Automated installation scripts
- 📚 Comprehensive documentation

Ready for one-click Arch Linux setup! 🎉"

echo "✅ Repository initialized!"
echo ""
echo "🔧 Next steps:"
echo "  1. Create a repository on GitHub named 'arch-dotfiles'"
echo "  2. Run: git remote add origin https://github.com/YOUR-USERNAME/arch-dotfiles.git"
echo "  3. Run: git branch -M main"
echo "  4. Run: git push -u origin main"
echo ""
echo "🌟 Your dotfiles are ready to be shared with the world!"