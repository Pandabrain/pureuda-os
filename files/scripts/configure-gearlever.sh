#!/usr/bin/env bash
set -exuo pipefail

echo "Configuring Gear Lever alias..."

# Add alias for bash
# /etc/bashrc is sourced by all bash shells
if [ -f /etc/bashrc ]; then
    echo "alias gearlever='flatpak run it.mijorus.gearlever'" >> /etc/bashrc
fi

# Also add to /etc/profile.d for better compatibility
cat <<EOF > /etc/profile.d/gearlever.sh
alias gearlever='flatpak run it.mijorus.gearlever'
EOF

# Add alias for fish
mkdir -p /etc/fish/conf.d
cat <<EOF > /etc/fish/conf.d/gearlever.fish
alias gearlever="flatpak run it.mijorus.gearlever"
EOF

# Configure autostart for update fetching
echo "Configuring Gear Lever update fetcher autostart..."
mkdir -p /etc/xdg/autostart
cat <<EOF > /etc/xdg/autostart/it.mijorus.gearlever.update-fetcher.desktop
[Desktop Entry]
Name=Gear Lever Update Fetcher
Comment=Fetch AppImage updates in the background
Exec=flatpak run it.mijorus.gearlever --fetch-updates
Type=Application
NoDisplay=true
X-GNOME-Autostart-enabled=true
EOF

echo "✅ Gear Lever configured successfully."
