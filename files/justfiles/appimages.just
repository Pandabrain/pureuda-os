#To create metadata AppImages:
#
# Download an AppImage (e.g. https://github.com/opencloud-eu/desktop/releases)
# Download appimagetool (for creating the appimage after unpacking and changing it) from https://github.com/AppImage/appimagetool/releases
#
# make AppImage you want to unpackk executable
#chmod +x ./OpenCloud_Desktop-v3.0.3-linux-gcc-x86_64.AppImage
#
# extract the AppImage
#./OpenCloud_Desktop-v3.0.3-linux-gcc-x86_64.AppImage --appimage-extract
#
# go into the extracted folder "squashfs-root" and edit the file "AppRun" to something like the following to avoid it crashing if someone attempts to open the fake AppImage:
#
##!/bin/bash
#echo "This is a skeleton AppImage for GearLever integration."
#echo "Please use GearLever to update/download the full version."
#echo "Or download the newest version manually from https://github.com/opencloud-eu/desktop/releases"
#echo "To add update capability to gearlever, set update source to Github, repo url to https://github.com/opencloud-eu/desktop and repo filename to OpenCloud_Desktop-*-linux-gcc-x86_64.AppImage
#exit 0
#
# open the .desktop file and look for a X-AppImage-Version= entry. Make the version lower than the most recent one so it can trigger an update.
# it is better to reduce the patch version number rather then the build number because the build number does not seem to be used on github (in this example), so gearlever might think that 3.0.3.1 is the same as 3.0.3.2.
#X-AppImage-Version=3.0.2.2073
#
#delete all the folders except "squashfs-root/usr/share/icons/" and all files but the following: "AppRun, <appname>.desktop, <appname>.png and .DirIcon". So you should be left with those four files and the usr folder"
#
#repack the AppImage with appimagetool. I integrated appimagetool with gearlever, you may need to adjust the path to the appimagetool and/or make it executable if you did not use gearlever.
# adjust the ARCH variable if you are targeting a different architecture. Adjust the version of the new AppImage to whatever you set it to in the .desktop file. GearLever may deduct the version number from the filename if it fails to read it from the .desktop file.
#ARCH=x86_64 ~/AppImages/appimagetool.appimage squashfs-root OpenCloud_Desktop-v3.0.2-linux-gcc-x86_64.AppImage
#

# Install Joplin AppImage via gearlever
install-joplin-appimage:
    @echo "   This script will integrate an empty AppImage that only contains Metadata for the App. It will then setup update information via github and download the actual AppImage by triggering a GearLever update. If anything fails then the App will not work and you should can go to https://github.com/laurent22/joplin/releases and download the most recent version manually."
    @echo "🚀 Integrating Joplin Metadata into GearLever"
    flatpak run it.mijorus.gearlever --integrate /usr/bin/Joplin-3.5.12.AppImage
    @echo "📦 Setting update source for Joplin..."
    flatpak run it.mijorus.gearlever --set-update-source ~/AppImages/joplin.appimage --manager GithubUpdater repo_url=https://github.com/laurent22/joplin repo_filename=Joplin-*.AppImage allow_prereleases=false
    @echo "   Trigger download of actual AppImage"
    flatpak run it.mijorus.gearlever --update ~/AppImages/joplin.appimage -y --force
    @echo "✅ Joplin AppImage installation and configuration complete."

# Install OpenCloud Desktop AppImage via gearlever
install-opencloud-desktop-appimage:
    @echo "   This script will integrate an empty AppImage that only contains Metadata for the App. It will then setup update information via github and download the actual AppImage by triggering a GearLever update. If anything fails then the App will not work and you should can go to https://github.com/opencloud-eu/desktop/releases and download the most recent version manually."
    @echo "🚀 Integrating OpenCloud Desktop AppImage..."
    flatpak run it.mijorus.gearlever --integrate /usr/bin/OpenCloud_Desktop-v3.0.2-linux-gcc-x86_64.AppImage
    OpenCloud_Desktop-*-linux-gcc-x86_64.AppImage
    @echo "📦 Setting update source for OpenCloud Desktop..."
    flatpak run it.mijorus.gearlever --set-update-source ~/AppImages/opencloud_desktop_desktop_sync_client.appimage --manager GithubUpdater repo_url=https://github.com/opencloud-eu/desktop repo_filename=OpenCloud_Desktop-*-linux-gcc-x86_64.AppImage allow_prereleases=false
    @echo "   Trigger download of actual AppImage"
    flatpak run it.mijorus.gearlever --update ~/AppImages/opencloud_desktop_desktop_sync_client.appimage -y --force
    @echo "✅ OpenCloud Desktop AppImage installation and configuration complete."
