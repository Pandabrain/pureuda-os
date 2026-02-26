#!/usr/bin/env bash
set -exuo pipefail

# ----------------------------------------------------------------------
# 1️⃣ Determine the latest Linux Toolbox tarball URL
# ----------------------------------------------------------------------
API_URL="https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release"
URL=$(curl -sSfL "$API_URL" |
      grep -Po '"linux":\s*{"link":\s*"\K[^"]+' || echo "")
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
curl -sSfL "$URL" |
    tar -xz -C "$INSTALL_ROOT" \
        --strip-components=1   # keep the whole directory layout

# ----------------------------------------------------------------------
# 4️⃣ Symlink the launcher into a standard bin directory
# ----------------------------------------------------------------------
# or I'd rather not, jetbrains creates a desktop file and autostart entry on its own, that's enough
#sudo ln -sf "$INSTALL_ROOT/jetbrains-toolbox" /usr/local/bin/jetbrains-toolbox

# ----------------------------------------------------------------------
# 5️⃣ Finish up
# ----------------------------------------------------------------------
echo "✅ JetBrains Toolbox installed to $INSTALL_ROOT"
