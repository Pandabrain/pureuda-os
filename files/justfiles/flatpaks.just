# Install Flatpaks from the bluebuild recipe
install-flatpaks:
    #!/usr/bin/env bash
    set -e
    echo "📦 Adding Flathub repository..."
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

    echo "📥 Installing system-wide Flatpaks..."
    SYSTEM_FLATPAKS=(
        io.github.kolunmi.Bazaar
        com.discordapp.Discord
        org.jellyfin.JellyfinDesktop
        org.telegram.desktop
        io.github.flattool.Warehouse
        com.ranfdev.DistroShelf
        io.podman_desktop.PodmanDesktop
        org.freecad.FreeCAD
        com.bambulab.BambuStudio
        it.mijorus.gearlever
        app.zen_browser.zen
    )
    for pkg in "${SYSTEM_FLATPAKS[@]}"; do
        echo "   Installing $pkg..."
        flatpak install --system -y flathub "$pkg"
    done

    echo "✅ Flatpaks setup completed successfully!"
