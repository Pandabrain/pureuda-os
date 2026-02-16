#!/usr/bin/env bash
set -exuo pipefail

FEDORA_VERSION=$(rpm -E %fedora)
REPO_RPM_URL="https://repo.protonvpn.com/fedora-${FEDORA_VERSION}-stable/protonvpn-stable-release/protonvpn-stable-release-1.0.3-1.noarch.rpm"

# Mock systemctl to prevent failing scriptlets in container environment
mkdir -p /tmp/mock-bin
cat <<EOF > /tmp/mock-bin/systemctl
#!/bin/bash
exit 0
EOF
chmod +x /tmp/mock-bin/systemctl
export PATH="/tmp/mock-bin:$PATH"

echo "🔗 Downloading Proton VPN repository configuration from: $REPO_RPM_URL"
dnf install -y "$REPO_RPM_URL"

echo "🔄 Refreshing dnf cache..."
dnf check-update --refresh || true

echo "📦 Installing Proton VPN..."
dnf install -y proton-vpn-gnome-desktop

# Clean up mock
rm -rf /tmp/mock-bin
