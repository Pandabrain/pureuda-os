# Initialize snap support
initialize-snap:
    #!/usr/bin/env bash
    if ! command -v snap &> /dev/null; then
        echo "❌ snap command not found. Please ensure snapd is installed and enabled."
        exit 1
    fi

    APPS=("snapd" "snap-store")

    echo "🚀 The following snaps will be installed to initialize support:"
    for app in "${APPS[@]}"; do
        echo "  - $app"
    done

    read -p "❓ Do you want to proceed with the initialization? [y/N] " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "❌ Initialization cancelled."
        exit 0
    fi

    for app in "${APPS[@]}"; do
        echo "🚀 Installing $app..."
        sudo snap install "$app"
    done

    echo "🔧 Setting up snapd void directory..."
    sudo mkdir -p /var/lib/snapd/void
    sudo chmod 700 /var/lib/snapd/void
    
    echo "🔄 Restarting snapd..."
    sudo systemctl restart snapd
    echo "✅ Snap initialization complete."

# Install Proton snaps
install-proton-snaps:
    #!/usr/bin/env bash
    if [[ ! -d "/var/lib/snapd/void" ]]; then
        echo "❌ snap has not yet been initialized."
        echo "💡 Please first run blujust initialize-snap"
        exit 1
    fi

    APPS=("proton-mail" "proton-pass")

    echo "🚀 The following Proton snaps will be installed:"
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

# Install recommended snaps
install-recommended-snaps:
    #!/usr/bin/env bash
    if [[ ! -d "/var/lib/snapd/void" ]]; then
        echo "❌ snap has not yet been initialized."
        echo "💡 Please first run blujust initialize-snap"
        exit 1
    fi

    APPS=("termius-app")

    echo "🚀 The following recommended snaps will be installed:"
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
