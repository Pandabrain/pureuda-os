#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Installing Flutter SDK..."

# 1. Get latest stable version info
RELEASES_JSON="https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json"
echo "🔍 Fetching release information from $RELEASES_JSON ..."

# Use a temporary file to avoid curl error 23 (SIGPIPE) when the pipe is closed early by grep
TEMP_RELEASES_JSON=$(mktemp)
curl -sSf "$RELEASES_JSON" -o "$TEMP_RELEASES_JSON"

# Use grep to find the latest stable archive path
# We look for the first occurrence of "archive" after the "stable" channel indicator
ARCHIVE_PATH=$(grep -A 10 '"channel": "stable"' "$TEMP_RELEASES_JSON" | grep -m 1 '"archive":' | cut -d '"' -f 4)

rm "$TEMP_RELEASES_JSON"

if [[ -z "$ARCHIVE_PATH" ]]; then
    echo "❌ Could not determine latest Flutter stable version."
    exit 1
fi

URL="https://storage.googleapis.com/flutter_infra_release/releases/${ARCHIVE_PATH}"
echo "🔗 Latest stable release URL: $URL"

# 2. Install location
# Extracting to /opt will create /opt/flutter because the tarball has a 'flutter' root directory
INSTALL_ROOT="/opt"

# 3. Download and extract
echo "📦 Extracting Flutter into /opt/flutter ..."
# Ensure /opt exists
mkdir -p /opt
curl -sSfL "$URL" | tar -xJ -C "$INSTALL_ROOT"

# 4. Permissions
echo "🔐 Setting permissions..."
chmod -R 755 /opt/flutter

# 5. PATH configuration
echo "⚙️ Configuring system PATH..."
cat <<EOF > /etc/profile.d/flutter.sh
# Flutter SDK PATH
export PATH="\$PATH:/opt/flutter/bin"
EOF
chmod 644 /etc/profile.d/flutter.sh

# Fish PATH configuration
mkdir -p /etc/fish/conf.d
cat <<EOF > /etc/fish/conf.d/flutter.fish
# Flutter SDK PATH for fish
fish_add_path /opt/flutter/bin
EOF
chmod 644 /etc/fish/conf.d/flutter.fish

# 6. Precache and basic config
echo "🔄 Initializing Flutter (precache)..."
export PATH="$PATH:/opt/flutter/bin"

# We need to set HOME to a temporary location if it's not set or not writable during build
# But usually in container builds HOME is /root
export FLUTTER_ROOT="/opt/flutter"

# Disable analytics
flutter config --no-analytics

# Precache artifacts for Linux and common platforms
# This populates /opt/flutter/bin/cache which saves time for the user
flutter precache

echo "✅ Flutter SDK installed successfully to /opt/flutter"
