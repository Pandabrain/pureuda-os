#!/usr/bin/env bash
set -euo pipefail

# 1. Determine Fedora version
FEDORA_VERSION=$(rpm -E %fedora)
echo "🚀 Detected Fedora version: $FEDORA_VERSION"

# 2. Find the latest release RPM URL
# The directory structure is https://repo.protonvpn.com/fedora-<version>-stable/protonvpn-stable-release/
BASE_URL="https://repo.protonvpn.com/fedora-${FEDORA_VERSION}-stable/protonvpn-stable-release/"
echo "🔍 Searching for latest release RPM at $BASE_URL ..."

RPM_NAME=$(curl -sSf "$BASE_URL" | grep -Po 'href="\Kprotonvpn-stable-release-[^"]+\.noarch\.rpm' | sort -V | tail -n 1)

if [[ -z "$RPM_NAME" ]]; then
    echo "❌ Could not find the Proton VPN release RPM in the directory listing."
    exit 1
fi

URL="${BASE_URL}${RPM_NAME}"
echo "🔗 Found latest release RPM: $URL"

# 3. Install the repository package
echo "📦 Installing Proton VPN repository..."
dnf install -y "$URL"

# 4. Refresh and install the VPN app
echo "🔄 Refreshing dnf and installing Proton VPN..."
dnf check-update --refresh || true # check-update might return 100 if updates are available, which is fine
dnf install -y proton-vpn-gnome-desktop

echo "✅ Proton VPN installation completed successfully."
