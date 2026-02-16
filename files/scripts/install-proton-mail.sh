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

# Final installation message
echo "✅ Proton Mail installation completed successfully."
