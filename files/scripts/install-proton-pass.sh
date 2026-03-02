#!/usr/bin/env bash
set -exuo pipefail

echo "Fetching latest Proton Pass RPM URL..."
JSON_URL="https://proton.me/download/PassDesktop/linux/x64/version.json"
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
    echo "❌ Could not locate the Proton Pass RPM download URL."
    exit 1
fi

echo "🔗 Downloading and installing Proton Pass from: $URL"
dnf install -y "$URL"

# Extract and install icons into standard hicolor theme paths
# This ensures that icons are available even in environments like COSMIC
workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT
cd "$workdir"

# Extract icons from RPM
rpm2cpio "$URL" | cpio -idmv \
  "./usr/share/pixmaps/proton-pass.png" \
  "./usr/lib/proton-pass/resources/assets/logo.svg" 2>/dev/null || true

install_root="/usr/share/icons/hicolor"
mkdir -p \
  "$install_root/scalable/apps" \
  "$install_root/256x256/apps" \
  "$install_root/128x128/apps"

# Prefer scalable SVG if available
if [[ -f usr/lib/proton-pass/resources/assets/logo.svg ]]; then
  install -m 0644 usr/lib/proton-pass/resources/assets/logo.svg "$install_root/scalable/apps/proton-pass.svg"
fi
# Also drop the PNG in common sizes
if [[ -f usr/share/pixmaps/proton-pass.png ]]; then
  install -m 0644 usr/share/pixmaps/proton-pass.png "$install_root/256x256/apps/proton-pass.png"
  install -m 0644 usr/share/pixmaps/proton-pass.png "$install_root/128x128/apps/proton-pass.png"
fi

# Try to update icon caches if tool is present
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  gtk-update-icon-cache -f "$install_root" || true
fi

# Final installation message
echo "✅ Proton Pass installation and icon extraction completed successfully."
