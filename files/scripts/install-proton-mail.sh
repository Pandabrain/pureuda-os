#!/usr/bin/env bash
set -exuo pipefail

echo "Fetching latest Proton Mail RPM URL..."
JSON_URL="https://proton.me/download/mail/linux/version.json"
TEMP_JSON=$(mktemp)
curl -sSfL "$JSON_URL" -o "$TEMP_JSON"
URL=$(grep -Po '"Url":\s*"\Khttps://[^"]+\.rpm' "$TEMP_JSON" | head -n 1 || echo "")
rm "$TEMP_JSON"

MOCKED=false
# Ensure restoration on exit
trap 'if [ "$MOCKED" = true ]; then mv -f /usr/bin/systemctl.real /usr/bin/systemctl; fi; rm -rf /tmp/mock-bin' EXIT

# Aggressive mock for systemctl to prevent failing scriptlets in container environment.
# We temporarily replace /usr/bin/systemctl because RPM scriptlets often ignore PATH.
if [ -x /usr/bin/systemctl ]; then
    echo "Creating systemctl mock..."
    mv /usr/bin/systemctl /usr/bin/systemctl.real
    cat <<EOF > /usr/bin/systemctl
#!/bin/bash
exit 0
EOF
    chmod +x /usr/bin/systemctl
    MOCKED=true
fi

# Also keep the PATH-based mock as a fallback
mkdir -p /tmp/mock-bin
cat <<EOF > /tmp/mock-bin/systemctl
#!/bin/bash
exit 0
EOF
chmod +x /tmp/mock-bin/systemctl
export PATH="/tmp/mock-bin:$PATH"

if [[ -z "$URL" ]]; then
    echo "❌ Could not locate the Proton Mail RPM download URL."
    exit 1
fi

echo "🔗 Downloading and installing Proton Mail from: $URL"
dnf install -y "$URL"

# Extract and install icons into standard hicolor theme paths
# This ensures that icons are available even in environments like COSMIC
workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT
cd "$workdir"

# Extract icons and desktop file from RPM
# Known: ./usr/share/pixmaps/proton-mail.png exists; try to fetch .desktop to get Icon basename
rpm2cpio "$URL" | cpio -idmv \
  "./usr/share/pixmaps/proton-mail.png" \
  "./usr/share/applications/proton-mail.desktop" \
  "./usr/lib/proton-mail/resources/assets/logo.svg" 2>/dev/null || true

install_root="/usr/share/icons/hicolor"
mkdir -p \
  "$install_root/scalable/apps" \
  "$install_root/512x512/apps" \
  "$install_root/256x256/apps" \
  "$install_root/128x128/apps"

# Determine icon basename from the .desktop file, fallback to proton-mail
ICON_BASENAME="proton-mail"
if [[ -f usr/share/applications/proton-mail.desktop ]]; then
  ICON_BASENAME=$(grep -Po '^Icon=\K.+' usr/share/applications/proton-mail.desktop | head -n 1 || echo "")
  # Strip any extension if present
  ICON_BASENAME=${ICON_BASENAME%.png}
  ICON_BASENAME=${ICON_BASENAME%.svg}
  if [[ -z "$ICON_BASENAME" ]]; then ICON_BASENAME="proton-mail"; fi
fi

# Prefer scalable SVG if present (future-proof)
if [[ -f usr/lib/proton-mail/resources/assets/logo.svg ]]; then
  install -m 0644 usr/lib/proton-mail/resources/assets/logo.svg "$install_root/scalable/apps/${ICON_BASENAME}.svg"
fi

# Install PNG into common sizes under the resolved icon name
if [[ -f usr/share/pixmaps/proton-mail.png ]]; then
  install -m 0644 usr/share/pixmaps/proton-mail.png "$install_root/512x512/apps/${ICON_BASENAME}.png"
  install -m 0644 usr/share/pixmaps/proton-mail.png "$install_root/256x256/apps/${ICON_BASENAME}.png"
  install -m 0644 usr/share/pixmaps/proton-mail.png "$install_root/128x128/apps/${ICON_BASENAME}.png"
  # Also provide legacy name in case desktops expect proton-mail specifically
  if [[ "$ICON_BASENAME" != "proton-mail" ]]; then
    install -m 0644 usr/share/pixmaps/proton-mail.png "$install_root/256x256/apps/proton-mail.png"
    install -m 0644 usr/share/pixmaps/proton-mail.png "$install_root/128x128/apps/proton-mail.png"
  fi
fi

# Try to update icon caches if tool is present
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  gtk-update-icon-cache -f /usr/share/icons/hicolor || true
fi
# Also try xdg cache refresh if available
if command -v xdg-icon-resource >/dev/null 2>&1; then
  xdg-icon-resource forceupdate --theme hicolor || true
fi

# Final installation message
echo "✅ Proton Mail installation and icon extraction completed successfully."
