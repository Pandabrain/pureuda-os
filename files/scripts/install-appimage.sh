#!/usr/bin/env bash
set -exuo pipefail

# Generic AppImage installer for BlueBuild
# This script mimics Gear Lever's integration logic but for system-wide installation.

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <AppName> <AppImageURL> [IconURL]"
    exit 1
fi

APP_NAME=$1
APP_URL=$2
ICON_URL=${3:-}
APP_NAME_LOWER=$(echo "$APP_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

INSTALL_DIR="/opt/$APP_NAME_LOWER"
mkdir -p "$INSTALL_DIR"

APPIMAGE_PATH="$INSTALL_DIR/$APP_NAME_LOWER.AppImage"

echo "📥 Downloading $APP_NAME AppImage..."
curl -sSfLo "$APPIMAGE_PATH" "$APP_URL"
chmod +x "$APPIMAGE_PATH"

# Icon handling
ICON_DIR="/usr/share/icons/hicolor/512x512/apps"
mkdir -p "$ICON_DIR"
ICON_PATH="$ICON_DIR/$APP_NAME_LOWER.png"

if [[ -n "$ICON_URL" ]]; then
    echo "📥 Downloading icon from $ICON_URL..."
    curl -sSfLo "$ICON_PATH" "$ICON_URL"
else
    echo "🔍 Attempting to extract icon from AppImage..."
    # We use --appimage-extract to get the icon. 
    # Usually it's .DirIcon or a file in the root.
    TEMP_DIR=$(mktemp -d)
    pushd "$TEMP_DIR"
    # Extract only the icon if possible, but --appimage-extract usually extracts everything
    # We use a subshell to avoid FUSE issues if any, though --appimage-extract doesn't need FUSE.
    "$APPIMAGE_PATH" --appimage-extract ".DirIcon" || true
    if [[ -f "squashfs-root/.DirIcon" ]]; then
        mv "squashfs-root/.DirIcon" "$ICON_PATH"
    else
        # Fallback: extract everything and look for png/svg
        "$APPIMAGE_PATH" --appimage-extract "*.png" || true
        FOUND_ICON=$(find squashfs-root -name "*.png" | head -n 1 || echo "")
        if [[ -n "$FOUND_ICON" ]]; then
            mv "$FOUND_ICON" "$ICON_PATH"
        fi
    fi
    popd
    rm -rf "$TEMP_DIR"
fi

# Desktop Entry
echo "🖥️ Creating Desktop Entry..."
DESKTOP_DIR="/usr/share/applications"
mkdir -p "$DESKTOP_DIR"

cat <<EOF > "$DESKTOP_DIR/$APP_NAME_LOWER.desktop"
[Desktop Entry]
Name=$APP_NAME
Exec="$APPIMAGE_PATH" %u
Icon=$APP_NAME_LOWER
Type=Application
Categories=Utility;
Terminal=false
EOF

echo "✅ $APP_NAME integrated successfully."
