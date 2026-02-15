#!/usr/bin/env bash
set -euo pipefail

echo "Fetching latest Proton Mail RPM URL..."
JSON_URL="https://proton.me/download/mail/linux/version.json"
URL=$(curl -sSf "$JSON_URL" | grep -Po '"Url":\s*"\Khttps://[^"]+\.rpm' | head -n 1)

## Mock systemctl to prevent failing scriptlets in container environment
#mkdir -p /tmp/mock-bin
#cat <<EOF > /tmp/mock-bin/systemctl
##!/bin/bash
#exit 0
#EOF
#chmod +x /tmp/mock-bin/systemctl
#export PATH="/tmp/mock-bin:$PATH"

if [[ -z "$URL" ]]; then
    echo "❌ Could not locate the Proton Mail RPM download URL."
    exit 1
fi

echo "🔗 Downloading and installing Proton Mail from: $URL"
dnf install -y "$URL"

# Clean up mock
rm -rf /tmp/mock-bin
