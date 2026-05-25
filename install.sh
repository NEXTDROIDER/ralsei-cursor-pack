#!/bin/bash

THEME_NAME="Ralsei"
FINAL_DIR="$HOME/.icons/$THEME_NAME/cursors"

echo "========================================="
echo "   $THEME_NAME Cursor Theme Installer"
echo "========================================="

# 1. Check and install system packages via pacman (python-pipx)
if ! command -v pipx &> /dev/null; then
    echo "📦 [System] pipx is not installed. Installing python-pipx via pacman..."
    echo "Please enter your sudo password to proceed:"
    sudo pacman -S --noconfirm python-pipx
else
    echo "✅ [System] pipx is already installed."
fi

# Ensure pipx paths are fully configured in the current shell session
export PATH="$HOME/.local/bin:$PATH"

# 2. Check and install win2xcur via pipx
if ! command -v win2xcur &> /dev/null; then
    echo "📦 [Python] win2xcur tool is not installed. Installing via pipx..."
    pipx install win2xcur
    # Force pipx to append binary folder to environment paths
    pipx ensurepath --force > /dev/null 2>&1
else
    echo "✅ [Python] win2xcur is already installed."
fi

# Double check if the tool is accessible now
if ! command -v win2xcur &> /dev/null; then
    echo "❌ Error: Failed to initialize win2xcur. Please restart your terminal and try again."
    exit 1
fi

# 3. Clean up any previous failed attempts
rm -rf "$HOME/.icons/$THEME_NAME"
mkdir -p "$FINAL_DIR"

if [ ! -f "conf.ini" ]; then
    echo "❌ Error: conf.ini file not found in the current directory!"
    exit 1
fi

# Clean the configuration file from Windows BOM markers
sed '1s/^\xEF\xBB\xBF//; 1s/^\xFF\xFE//; 1s/^\xFE\xFF//' conf.ini > conf_clean.ini

get_linux_name() {
    case "$1" in
        "Arrow")       echo "left_ptr" ;;
        "Wait")        echo "watch" ;;
        "AppStarting") echo "progress" ;;
        "Help")        echo "help" ;;
        "IBeam")       echo "xterm" ;;
        "Hand")        echo "hand2" ;;
        "Crosshair")   echo "cross" ;;
        "No")          echo "not-allowed" ;;
        "SizeAll")     echo "fleur" ;;
        "SizeWE")      echo "sb_h_double_arrow" ;;
        "SizeNS")      echo "sb_v_double_arrow" ;;
        "SizeNWSE")    echo "bd_double_arrow" ;;
        "SizeNESW")    echo "fd_double_arrow" ;;
        *)             echo "" ;;
    esac
}

current_section=""
echo "🚀 Starting cursor conversion..."

while IFS= read -r line || [ -n "$line" ]; do
    line=$(echo "$line" | tr -d '\r' | xargs)
    
    if [[ "$line" =~ ^\[(.*)\]$ ]]; then
        current_section="${BASH_REMATCH}"
    elif [[ "$line" =~ ^Path=(.*)$ ]] && [ -n "$current_section" ]; then
        file_name="${BASH_REMATCH}"
        linux_name=$(get_linux_name "$current_section")
        
        if [ -n "$linux_name" ]; then
            if [ -f "$file_name" ]; then
                TMP_OUT="tmp_out_$linux_name"
                mkdir -p "$TMP_OUT"
                
                win2xcur -o "$TMP_OUT" "$file_name" > /dev/null 2>&1
                
                GENERATED_FILE=$(find "$TMP_OUT" -type f | head -n 1)
                if [ -n "$GENERATED_FILE" ]; then
                    mv "$GENERATED_FILE" "$FINAL_DIR/$linux_name"
                    echo "➡️ Created cursor: $linux_name"
                fi
                
                rm -rf "$TMP_OUT"
            else
                echo "⚠️ File not found: $file_name"
            fi
        fi
    fi
done < conf_clean.ini

rm conf_clean.ini

# Create standard system symlinks (aliases)
cd "$FINAL_DIR" || exit
ln -sf left_ptr default
ln -sf left_ptr arrow
ln -sf watch pointer

# Generate index.theme
cat << EOF > "$HOME/.icons/$THEME_NAME/index.theme"
[Icon Theme]
Name=$THEME_NAME
Comment=Ralsei Deltarune Cursor Theme
Inherits=core
EOF

# 4. Auto-apply for GNOME Environment
if command -v gsettings &> /dev/null; then
    echo "🖥️ GNOME detected! Applying $THEME_NAME cursor theme..."
    gsettings set org.gnome.desktop.interface cursor-theme "$THEME_NAME"
    gsettings set org.gnome.desktop.interface cursor-size 27
fi

echo "========================================="
echo "✨ Success! The theme is fully installed."
echo "Location: ~/.icons/$THEME_NAME"
echo "========================================="

