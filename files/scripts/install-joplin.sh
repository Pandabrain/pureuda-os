#!/usr/bin/env bash
set -exuo pipefail

# This script installs Joplin system-wide in a BlueBuild image.
# It is adapted from the official Joplin Linux installation script.

#-----------------------------------------------------
# Helper: Version Comparison
#-----------------------------------------------------
compareVersions() {
  V_MAJOR1=$(echo "$1"|cut -d. -f1)
  V_MAJOR2=$(echo "$2"|cut -d. -f1)

  if [[ $V_MAJOR1 -lt $V_MAJOR2 ]] ; then
    echo -1
    return
  elif [[ $V_MAJOR1 -gt $V_MAJOR2 ]] ; then
    echo 1
    return
  fi

  V_MINOR1=$(echo "$1"|cut -d. -f2)
  V_MINOR2=$(echo "$2"|cut -d. -f2)

  if [[ $V_MINOR1 -lt $V_MINOR2 ]] ; then
    echo -1
    return
  elif [[ $V_MINOR1 -gt $V_MINOR2 ]] ; then
    echo 1
    return
  fi

  V_PATCH1=$(echo "$1"|cut -d. -f3)
  V_PATCH2=$(echo "$2"|cut -d. -f3)

  if [[ $V_PATCH1 -lt $V_PATCH2 ]] ; then
    echo -1
  elif [[ $V_PATCH1 -gt $V_PATCH2 ]] ; then
    echo 1
  else
    echo 0
  fi
}

#-----------------------------------------------------
# START
#-----------------------------------------------------
echo "🚀 Starting Joplin installation..."

# 1. Get the latest version to download
echo "🔍 Checking for latest Joplin version..."
TEMP_JSON=$(mktemp)
curl -sSfL "https://api.github.com/repos/laurent22/joplin/releases/latest" -o "$TEMP_JSON"
RELEASE_VERSION=$(grep -Po '"tag_name": ?"v\K.*?(?=")' "$TEMP_JSON" || echo "")
rm "$TEMP_JSON"

if [[ -z "$RELEASE_VERSION" ]]; then
    echo "❌ Could not determine latest Joplin version."
    exit 1
fi
echo "📦 Latest version is $RELEASE_VERSION"

# 2. Setup installation directory
INSTALL_DIR="/opt/joplin"
mkdir -p "$INSTALL_DIR"

# 3. Download Joplin AppImage
echo "📥 Downloading Joplin AppImage..."
# We use DOWNLOAD_TYPE="New" as per the original script for a fresh install
curl -sSfLo "$INSTALL_DIR/Joplin.AppImage" "https://objects.joplinusercontent.com/v${RELEASE_VERSION}/Joplin-${RELEASE_VERSION}.AppImage?source=LinuxInstallScript&type=New"
chmod +x "$INSTALL_DIR/Joplin.AppImage"

# 4. Download and install icon
echo "📥 Downloading Joplin icon..."
ICON_DIR="/usr/share/icons/hicolor/512x512/apps"
mkdir -p "$ICON_DIR"
curl -sSfLo "$ICON_DIR/joplin.png" "https://joplinapp.org/images/Icon512.png"

# 5. Create Desktop Entry
echo "🖥️ Creating Desktop Entry..."
DESKTOP_FILE_LOCATION="/usr/share/applications"
mkdir -p "$DESKTOP_FILE_LOCATION"

# Determine StartupWMClass based on version (logic from original script)
# Only later versions of Joplin default to Wayland
# IS_WAYLAND_BY_DEFAULT returns 1 if RELEASE_VERSION > 3.5.6
IS_WAYLAND_BY_DEFAULT=$(compareVersions "$RELEASE_VERSION" "3.5.6")

STARTUP_WM_CLASS="Joplin"
# On modern Fedora/Aurora, Wayland is default.
# We'll assume Wayland if the version supports it and it's not explicitly X11.
# Since we can't detect the session type at build time, we follow the script's logic
# but prefer the modern class if the version is high enough.
if [[ "$IS_WAYLAND_BY_DEFAULT" == "1" ]]; then
    STARTUP_WM_CLASS="@joplin/app-desktop"
fi

cat > "$DESKTOP_FILE_LOCATION/joplin.desktop" <<EOF
[Desktop Entry]
Encoding=UTF-8
Name=Joplin
Comment=Joplin for Desktop
Exec=env APPIMAGELAUNCHER_DISABLE=TRUE "$INSTALL_DIR/Joplin.AppImage" %u
Icon=joplin
StartupWMClass=${STARTUP_WM_CLASS}
Type=Application
Categories=Office;
MimeType=x-scheme-handler/joplin;
X-GNOME-SingleWindow=true
SingleMainWindow=true
EOF

echo "✅ Joplin installation completed successfully."
