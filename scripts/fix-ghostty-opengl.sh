#!/bin/bash

# Ghostty OpenGL Troubleshooter
# Diagnoses and fixes common OpenGL context issues with Ghostty

echo "🔍 Ghostty OpenGL Troubleshooter"
echo "=================================="

# Check if Ghostty is installed
if ! command -v ghostty &> /dev/null; then
    echo "❌ Ghostty is not installed"
    exit 1
fi

echo "✅ Ghostty is installed"

# Check OpenGL support
echo ""
echo "🔧 Checking OpenGL support..."

if command -v glxinfo &> /dev/null; then
    echo "📊 OpenGL Information:"
    glxinfo | grep -E "(OpenGL vendor|OpenGL renderer|OpenGL version)"
    
    # Check if hardware acceleration is available
    if glxinfo | grep -q "direct rendering: Yes"; then
        echo "✅ Hardware acceleration available"
        HW_ACCEL=true
    else
        echo "⚠️  Hardware acceleration not available"
        HW_ACCEL=false
    fi
else
    echo "⚠️  mesa-utils not installed, installing..."
    sudo pacman -S --noconfirm mesa-utils
    HW_ACCEL=false
fi

echo ""
echo "🎯 Recommended Solutions:"

if [ "$HW_ACCEL" = false ]; then
    echo "1. 🔄 Use software renderer (slower but compatible)"
    echo "   Copy fallback config: cp ~/.config/ghostty/config-fallback ~/.config/ghostty/config"
    echo ""
    echo "2. 📦 Install additional graphics drivers:"
    echo "   sudo pacman -S mesa lib32-mesa vulkan-tools"
    echo ""
    echo "3. 🖥️  Check your graphics driver:"
    lspci | grep -E "(VGA|3D)"
fi

echo ""
echo "🛠️  Available Ghostty renderer options:"
echo "   renderer = auto     # Try hardware first, fallback to software"
echo "   renderer = opengl   # Force OpenGL (may fail)"
echo "   renderer = software # Force software rendering (always works)"

echo ""
echo "🔧 Quick Fix Commands:"
echo ""
echo "# Use fallback config (software rendering):"
echo "cp ~/.config/ghostty/config-fallback ~/.config/ghostty/config"
echo ""
echo "# Or edit main config to use software renderer:"
echo "echo 'renderer = software' >> ~/.config/ghostty/config"
echo ""
echo "# Test Ghostty:"
echo "ghostty"

echo ""
echo "📚 If issues persist, check: https://ghostty.org/docs/config/renderer"