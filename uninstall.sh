#!/bin/bash

THEME_NAME="Ralsei"

echo "Starting uninstallation of $THEME_NAME cursor theme..."

# 1. Reset GNOME cursor settings to defaults
if command -v gsettings &> /dev/null; then
    echo "Resetting GNOME cursor theme and size..."
    gsettings reset org.gnome.desktop.interface cursor-theme
    gsettings reset org.gnome.desktop.interface cursor-size
fi

# 2. Remove the cursor theme directory
if [ -d "$HOME/.icons/$THEME_NAME" ]; then
    echo "Removing theme directory from ~/.icons..."
    rm -rf "$HOME/.icons/$THEME_NAME"
fi

# 3. Clean up .Xresources configuration if it exists
if [ -f "$HOME/.Xresources" ]; then
    echo "Cleaning up ~/.Xresources..."
    # Remove lines containing the theme name or cursor size
    sed -i "/Xcursor.theme: $THEME_NAME/d" "$HOME/.Xresources"
    sed -i "/Xcursor.size:/d" "$HOME/.Xresources"
    
    # Reload Xresources to apply changes immediately
    if command -v xrdb &> /dev/null; then
        xrdb -merge ~/.Xresources
    fi
fi

echo "✨ Uninstallation complete! System defaults have been restored."
