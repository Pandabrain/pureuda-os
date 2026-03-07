# Install snaps
install-snaps:
    #!/usr/bin/env bash
    if ! command -v snap &> /dev/null; then
        echo "❌ snap command not found. Please ensure snapd is installed and enabled."
        exit 1
    fi
    # Add your snaps here
    # Example: sudo snap install vlc
    # echo "🚀 Installing vlc..."
    # sudo snap install vlc
    echo "💡 No snaps configured for installation. Edit 'files/justfiles/snaps.just' to add some!"
