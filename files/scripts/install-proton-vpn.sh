#!/usr/bin/env bash
set -exuo pipefail

FEDORA_VERSION=$(rpm -E %fedora)
REPO_RPM_URL="https://repo.protonvpn.com/fedora-${FEDORA_VERSION}-stable/protonvpn-stable-release/protonvpn-stable-release-1.0.3-1.noarch.rpm"

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

echo "🔗 Downloading Proton VPN repository configuration from: $REPO_RPM_URL"
dnf install -y "$REPO_RPM_URL"

echo "🔄 Refreshing dnf cache..."
dnf check-update --refresh || true

echo "📦 Installing Proton VPN..."
dnf install -y proton-vpn-gnome-desktop

# Final installation message
echo "✅ Proton VPN installation completed successfully."
