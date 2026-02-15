#!/usr/bin/env bash
set -euo pipefail

echo "Fetching latest Proton Mail RPM URL..."
JSON_URL="https://proton.me/download/mail/linux/version.json"
URL=$(curl -sSf "$JSON_URL" | grep -Po '"Url":\s*"\Khttps://[^"]+\.rpm' | head -n 1)

if [[ -z "$URL" ]]; then
    echo "❌ Could not locate the Proton Mail RPM download URL."
    exit 1
fi

echo "🔗 Downloading and installing Proton Mail from: $URL"
dnf install -y "$URL"
