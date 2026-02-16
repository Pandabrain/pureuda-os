#!/usr/bin/env bash
set -exuo pipefail

echo "Fetching latest Proton Mail RPM URL..."
JSON_URL="https://proton.me/download/mail/linux/version.json"
TEMP_JSON=$(mktemp)
curl -sSfL "$JSON_URL" -o "$TEMP_JSON"
URL=$(grep -Po '"Url":\s*"\Khttps://[^"]+\.rpm' "$TEMP_JSON" | head -n 1 || echo "")
rm "$TEMP_JSON"

# Mock systemctl to prevent failing scriptlets in container environment
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

# Clean up mock
rm -rf /tmp/mock-bin
