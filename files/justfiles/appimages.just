# Install Joplin AppImage via gearlever
install-joplin-appimage:
    @echo "   This script will integrate an empty AppImage that only contains Metadata for the App. It will then setup update information via github and download the actual AppImage by triggering a GearLever update. If anything fails then the App will not work and you should can go to https://github.com/laurent22/joplin/releases and download the most recent version manually."
    @echo "🚀 Integrating Joplin Metadata into GearLever"
    gearlever --integrate /usr/bin/Joplin-3.4.13.AppImage
    @echo "📦 Setting update source for Joplin..."
    gearlever --set-update-source ~/AppImages/joplin.appimage --manager GithubUpdater repo_url=https://github.com/laurent22/joplin repo_filename=Joplin-*.AppImage allow_prereleases=false
    @echo "   Trigger download of actual AppImage"
    gearlever --update ~/AppImages/joplin.appimage -y --force
    @echo "✅ Joplin AppImage installation and configuration complete."

# Install OpenCloud Desktop AppImage via gearlever
install-opencloud-desktop-appimage:
    @echo "   This script will integrate an empty AppImage that only contains Metadata for the App. It will then setup update information via github and download the actual AppImage by triggering a GearLever update. If anything fails then the App will not work and you should can go to https://github.com/opencloud-eu/desktop/releases and download the most recent version manually."
    @echo "🚀 Integrating OpenCloud Desktop AppImage..."
    gearlever --integrate /usr/bin/OpenCloud_Desktop-v3.0.3-linux-gcc-x86_64.AppImage
    OpenCloud_Desktop-*-linux-gcc-x86_64.AppImage
    @echo "📦 Setting update source for OpenCloud Desktop..."
    gearlever --set-update-source ~/AppImages/opencloud_desktop_desktop_sync_client.appimage --manager GithubUpdater repo_url=https://github.com/opencloud-eu/desktop repo_filename=OpenCloud_Desktop-*-linux-gcc-x86_64.AppImage allow_prereleases=false
    @echo "   Trigger download of actual AppImage"
    gearlever --update ~/AppImages/opencloud_desktop_desktop_sync_client.appimage -y --force
    @echo "✅ OpenCloud Desktop AppImage installation and configuration complete."
