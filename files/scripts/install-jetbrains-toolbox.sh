#!/usr/bin/env bash
set -euo pipefail

# ----------------------------------------------------------------------
# 1️⃣ Determine the latest Linux Toolbox tarball URL
# ----------------------------------------------------------------------
API_URL="https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release"
URL=$(curl -sSf "$API_URL" |
      grep -Po '"linux":\s*{"link":\s*"\K[^"]+')
if [[ -z "$URL" ]]; then
    echo "❌ Could not locate the download URL – the JetBrains API may have changed."
    exit 1
fi
echo "🔗 Download URL: $URL"

# ----------------------------------------------------------------------
# 2️⃣ Install location (root‑owned, but outside /usr/bin)
# ----------------------------------------------------------------------
INSTALL_ROOT="/opt/jetbrains-toolbox"
mkdir -p "$INSTALL_ROOT"

# ----------------------------------------------------------------------
# 3️⃣ Stream the tarball and extract the full tree
# ----------------------------------------------------------------------
echo "📦 Extracting Toolbox into $INSTALL_ROOT ..."
curl -L "$URL" |
    tar -xz -C "$INSTALL_ROOT" \
        --strip-components=1   # keep the whole directory layout

# ----------------------------------------------------------------------
# 4️⃣ Symlink the launcher into a standard bin directory
# ----------------------------------------------------------------------
# or I'd rather not, jetbrains creates a desktop file and autostart entry on its own, that's enough
#sudo ln -sf "$INSTALL_ROOT/jetbrains-toolbox" /usr/local/bin/jetbrains-toolbox

# ----------------------------------------------------------------------
# 5️⃣ Autostart helper – placed in /etc/profile.d/
# ----------------------------------------------------------------------
AUTOSTART_SCRIPT="/etc/profile.d/jetbrains-toolbox-start.sh"
tee "$AUTOSTART_SCRIPT" > /dev/null <<'EOF'
# JetBrains Toolbox autostart (runs once per login session)
if [[ -n "$DISPLAY" || -n "$WAYLAND_DISPLAY" ]]; then
    # Only launch if the official desktop file hasn't been created yet
    if [[ ! -f "$HOME/.local/share/applications/jetbrains-toolbox.desktop" ]]; then
        /opt/jetbrains-toolbox/bin/jetbrains-toolbox --nosplash &
    fi
fi
EOF

# Ensure the script is executable (profile.d scripts are sourced, not executed)
chmod 644 "$AUTOSTART_SCRIPT"

# ----------------------------------------------------------------------
# 6️⃣ Finish up
# ----------------------------------------------------------------------
echo "✅ JetBrains Toolbox installed to $INSTALL_ROOT"
echo "   Launcher symlink: /usr/local/bin/jetbrains-toolbox"
echo "   Autostart hook: $AUTOSTART_SCRIPT"
echo "You may need to log out/in (or source /etc/profile) for the autostart to take effect."
