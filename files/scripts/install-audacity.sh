#!/usr/bin/env bash
set -exuo pipefail

echo "🚀 Installing Audacity..."

# 1. Get latest release information
API_URL="https://api.github.com/repos/audacity/audacity/releases/latest"
echo "🔍 Fetching release information from $API_URL ..."

# We use jq to extract assets_url and then fetch it
ASSETS_URL=$(curl -sSfL "$API_URL" | jq -r .assets_url)
ASSETS_JSON=$(curl -sSfL "$ASSETS_URL")

# 2. Find the best AppImage
# The name format is audacity-linux-<app-ver>-x64-<os-ver>.AppImage
# We filter for .AppImage assets, extract name and download URL, 
# sort by name (which includes the OS version at the end) and take the latest.
DOWNLOAD_URL=$(echo "$ASSETS_JSON" | jq -r '.[] | select(.name | endswith(".AppImage")) | select(.name | contains("x64")) | [.name, .browser_download_url] | @tsv' | sort -V | tail -n 1 | cut -f2)
FILENAME=$(echo "$ASSETS_JSON" | jq -r '.[] | select(.name | endswith(".AppImage")) | select(.name | contains("x64")) | .name' | sort -V | tail -n 1)

if [[ -z "$DOWNLOAD_URL" ]]; then
    echo "❌ Could not determine latest Audacity AppImage URL."
    exit 1
fi

echo "🔗 Latest release URL: $DOWNLOAD_URL"
echo "📦 Filename: $FILENAME"

# 3. Installation directory
INSTALL_DIR="/opt/audacity"
mkdir -p "$INSTALL_DIR"

# 4. Download
echo "📥 Downloading Audacity AppImage..."
curl -sSfLo "$INSTALL_DIR/audacity.AppImage" "$DOWNLOAD_URL"
chmod +x "$INSTALL_DIR/audacity.AppImage"

# 5. Create wrapper script
mkdir -p /usr/bin
cat > /usr/bin/audacity <<EOF
#!/bin/bash
# Force X11 to fix missing window decorations on Wayland
export GDK_BACKEND=x11
# Prevent AppImageLauncher from interfering with system-wide installation
export APPIMAGELAUNCHER_DISABLE=TRUE
# Use --appimage-extract-and-run for better compatibility and to avoid FUSE issues
exec "$INSTALL_DIR/audacity.AppImage" --appimage-extract-and-run "\$@"
EOF
chmod +x /usr/bin/audacity

# 6. Icon
echo "📥 Downloading Audacity icon..."
ICON_DIR="/usr/share/icons/hicolor/512x512/apps"
mkdir -p "$ICON_DIR"
# Using a known icon location from the audacity repository
curl -sSfLo "$ICON_DIR/audacity.png" "https://raw.githubusercontent.com/audacity/audacity/master/images/AudacityLogo.png"

# 7. Desktop Entry
echo "🖥️ Creating Desktop Entry..."
DESKTOP_FILE_LOCATION="/usr/share/applications"
mkdir -p "$DESKTOP_FILE_LOCATION"

cat > "$DESKTOP_FILE_LOCATION/audacity.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Audacity
GenericName=Audio Editor
Comment=Record and edit audio files
Icon=audacity
Exec=audacity %F
Terminal=false
Categories=AudioVideo;Audio;AudioVideoEditing;
MimeType=application/x-audacity-project;audio/basic;audio/midi;audio/mid;audio/x-aiff;audio/x-aifc;audio/x-wav;audio/x-mpeg;audio/x-mp2;audio/x-mp3;audio/x-mpga;audio/x-flac;audio/x-ogg;audio/x-vorbis;audio/x-speex;audio/x-ac3;audio/x-aac;audio/x-m4a;
Keywords=audio;sound;editor;recorder;mp3;ogg;flac;wav;
StartupWMClass=Audacity
EOF

echo "✅ Audacity installed successfully."
