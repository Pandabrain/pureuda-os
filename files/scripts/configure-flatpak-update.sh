#!/usr/bin/env bash
set -exuo pipefail

# Configure autostart for Flatpak auto-update
echo "Configuring Flatpak auto-update autostart..."
mkdir -p /etc/xdg/autostart
cat <<EOF > /etc/xdg/autostart/flatpak-update.desktop
[Desktop Entry]
Name=Flatpak Auto-update
Comment=Update Flatpaks in the background
Exec=flatpak update -y
Type=Application
NoDisplay=true
X-GNOME-Autostart-enabled=true
X-GNOME-Autostart-Delay=30
EOF

echo "✅ Flatpak auto-update configured successfully."
