# Install suggested snaps
install-suggested-snaps:
    #!/usr/bin/env bash
    if ! command -v snap &> /dev/null; then
        echo "❌ snap command not found. Please ensure snapd is installed and enabled."
        exit 1
    fi

    APPS=("snap-store" "proton-mail" "proton-pass" "termius-app")

    echo "🚀 The following snaps will be installed:"
    for app in "${APPS[@]}"; do
        echo "  - $app"
    done

    read -p "❓ Do you want to proceed with the installation? [y/N] " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "❌ Installation cancelled."
        exit 0
    fi

    for app in "${APPS[@]}"; do
        echo "🚀 Installing $app..."
        sudo snap install "$app"
    done
