# Install Flutter SDK
install-flutter:
    #!/usr/bin/env bash
    set -e
    INSTALL_DIR="$HOME/develop/flutter"
    if [ -d "$INSTALL_DIR" ]; then
        if [ -f "$INSTALL_DIR/bin/flutter" ]; then
            CURRENT_VER=$("$INSTALL_DIR/bin/flutter" --version | head -n 1)
            echo "💡 Flutter is already installed in $INSTALL_DIR"
            echo "   Current version: $CURRENT_VER"
        else
            echo "Flutter directory exists but binary not found in $INSTALL_DIR"
        fi
        echo "Use 'ujust update-flutter' to update it."
        exit 0
    fi
    mkdir -p "$INSTALL_DIR"

    # Check for dependencies
    for cmd in git curl tar; do
        if ! command -v $cmd &> /dev/null; then
            echo "❌ Error: $cmd is not installed but is required."
            exit 1
        fi
    done

    echo "🚀 Fetching latest Flutter stable release..."
    RELEASES_JSON="https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json"
    TEMP_RELEASES_JSON=$(mktemp)
    if ! curl -sSfL "$RELEASES_JSON" -o "$TEMP_RELEASES_JSON"; then
        echo "❌ Failed to download release information from $RELEASES_JSON"
        exit 1
    fi
    ARCHIVE_PATH=$(grep -A 10 '"channel": "stable"' "$TEMP_RELEASES_JSON" | grep -Po '"archive":\s*"\K[^"]+' | head -n 1 || echo "")
    VERSION=$(grep -A 10 '"channel": "stable"' "$TEMP_RELEASES_JSON" | grep -Po '"version":\s*"\K[^"]+' | head -n 1 || echo "")
    rm -f "$TEMP_RELEASES_JSON"
    if [ -z "$ARCHIVE_PATH" ]; then
        echo "❌ Could not determine latest Flutter stable version."
        exit 1
    fi
    URL="https://storage.googleapis.com/flutter_infra_release/releases/${ARCHIVE_PATH}"
    echo "🔗 Latest stable release: $VERSION"
    echo "📥 Downloading and extracting Flutter..."
    curl -sSfL "$URL" | tar -xJ -C "$INSTALL_DIR" --strip-components=1

    echo "⚙️ Configuring PATH..."
    # Bash configuration
    if ! grep -q "develop/flutter/bin" ~/.bashrc; then
        {
            echo ''
            echo '# Flutter SDK'
            echo 'export PATH="$PATH:$HOME/develop/flutter/bin"'
            echo 'export FLUTTER_ROOT="$HOME/develop/flutter"'
            echo 'export FLUTTER_NO_ANALYTICS=1'
        } >> ~/.bashrc
        echo "✅ Added Flutter configuration to ~/.bashrc"
    fi

    # Fish configuration
    if [ -d ~/.config/fish ] || [ -f /usr/bin/fish ]; then
        mkdir -p ~/.config/fish/conf.d
        if [ ! -f ~/.config/fish/conf.d/flutter.fish ]; then
            {
                echo '# Flutter SDK'
                echo 'fish_add_path $HOME/develop/flutter/bin'
                echo 'set -gx FLUTTER_ROOT $HOME/develop/flutter'
                echo 'set -gx FLUTTER_NO_ANALYTICS 1'
            } > ~/.config/fish/conf.d/flutter.fish
            echo "✅ Created ~/.config/fish/conf.d/flutter.fish"
        fi
    fi

    # Zsh configuration
    if [ -f ~/.zshrc ]; then
        if ! grep -q "develop/flutter/bin" ~/.zshrc; then
            {
                echo ''
                echo '# Flutter SDK'
                echo 'export PATH="$PATH:$HOME/develop/flutter/bin"'
                echo 'export FLUTTER_ROOT="$HOME/develop/flutter"'
                echo 'export FLUTTER_NO_ANALYTICS=1'
            } >> ~/.zshrc
            echo "✅ Added Flutter configuration to ~/.zshrc"
        fi
    fi

    echo "🔄 Running flutter precache..."
    "$INSTALL_DIR/bin/flutter" precache

    echo "✅ Flutter installed successfully!"
    echo "Please restart your shell or source your config file."

# Update Flutter SDK
update-flutter:
    #!/usr/bin/env bash
    set -e
    INSTALL_DIR="$HOME/develop/flutter"
    if [ -f "$INSTALL_DIR/bin/flutter" ]; then
        PREV_VER=$("$INSTALL_DIR/bin/flutter" --version | head -n 1)
        echo "🆙 Updating Flutter..."
        echo "   Current version: $PREV_VER"
        "$INSTALL_DIR/bin/flutter" upgrade
        NEW_VER=$("$INSTALL_DIR/bin/flutter" --version | head -n 1)
        echo "✅ Flutter updated successfully!"
        echo "   New version: $NEW_VER"
    else
        echo "❌ Flutter not found in $INSTALL_DIR/bin/flutter"
        echo "Run 'ujust install-flutter' first."
        exit 1
    fi

# Remove Flutter SDK
remove-flutter:
    #!/usr/bin/env bash
    INSTALL_DIR="$HOME/develop/flutter"
    echo "🗑️ Removing Flutter..."

    if [ -d "$INSTALL_DIR" ]; then
        rm -rf "$INSTALL_DIR"
        echo "✅ Removed $INSTALL_DIR"
    else
        echo "💡 Flutter directory $INSTALL_DIR not found."
    fi

    # Remove from Bash
    if [ -f ~/.bashrc ]; then
        # Remove the configuration block (from # Flutter SDK to export FLUTTER_NO_ANALYTICS=1)
        # We also try to catch the empty line above it if possible
        sed -i '/# Flutter SDK/,/export FLUTTER_NO_ANALYTICS=1/d' ~/.bashrc
        echo "✅ Removed Flutter configuration from ~/.bashrc"
    fi

    # Remove from Fish
    if [ -f ~/.config/fish/conf.d/flutter.fish ]; then
        rm -f ~/.config/fish/conf.d/flutter.fish
        echo "✅ Removed ~/.config/fish/conf.d/flutter.fish"
    fi

    # Remove from Zsh
    if [ -f ~/.zshrc ]; then
        sed -i '/# Flutter SDK/,/export FLUTTER_NO_ANALYTICS=1/d' ~/.zshrc
        echo "✅ Removed Flutter configuration from ~/.zshrc"
    fi

    echo "✅ Flutter has been removed from your system."
    echo "Please restart your shell."
