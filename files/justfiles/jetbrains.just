# Install JetBrains Toolbox
#
# Downloads, extracts and installs the JetBrains Toolbox to ~/.local/share/JetBrains/Toolbox/

# Then starts the Toolbox for the first time which creates its own desktop file and autostart entry.
install-jetbrains-toolbox:
    #!/usr/bin/env bash
    set -euo pipefail

    INSTALL_DIR="$HOME/.local/share/JetBrains/Toolbox"
    mkdir -p "$INSTALL_DIR"

    echo "🔍 Checking for the latest JetBrains Toolbox..."
    API_URL="https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release"
    URL=$(curl -sSfL "$API_URL" | grep -Po '"linux":\s*{"link":\s*"\K[^"]+' || echo "")

    if [[ -z "$URL" ]]; then
        echo "❌ Could not locate the download URL – the JetBrains API may have changed."
        exit 1
    fi

    echo "🔗 Download URL: $URL"
    echo "📦 Extracting Toolbox into $INSTALL_DIR ..."

    # Download and extract the tarball
    curl -sSfL "$URL" | tar -xz -C "$INSTALL_DIR" --strip-components=1

    EXECUTABLE="$INSTALL_DIR/jetbrains-toolbox"
    if [ -x "$EXECUTABLE" ]; then
        echo "🚀 Starting JetBrains Toolbox..."
        "$EXECUTABLE" > /dev/null 2>&1 &
        echo "✅ JetBrains Toolbox has been installed and started in the background."
        echo "   It will now create its own desktop file and autostart entry."
    else
        echo "❌ JetBrains Toolbox executable not found in $EXECUTABLE"
        exit 1
    fi
