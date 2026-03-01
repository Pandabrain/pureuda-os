#!/usr/bin/env bash
set -exuo pipefail

echo "Downloading and installing steam-using-gamescope-guide helper scripts..."

TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

curl -L https://github.com/shahnawazshahin/steam-using-gamescope-guide/archive/refs/heads/main.tar.gz -o repo.tar.gz
tar -xzf repo.tar.gz --strip-components=1

# Create a steamos-polkit-helpers folder under /usr/bin:
mkdir -p /usr/bin/steamos-polkit-helpers

# gamescope-session:
chmod 755 ./usr/bin/gamescope-session
cp ./usr/bin/gamescope-session /usr/bin/gamescope-session

# jupiter-biosupdate:
chmod 755 ./usr/bin/jupiter-biosupdate
chmod 755 ./usr/bin/steamos-polkit-helpers/jupiter-biosupdate
cp ./usr/bin/jupiter-biosupdate /usr/bin/jupiter-biosupdate
cp ./usr/bin/steamos-polkit-helpers/jupiter-biosupdate /usr/bin/steamos-polkit-helpers/jupiter-biosupdate

# steamos-select-branch:
chmod 755 ./usr/bin/steamos-select-branch
cp ./usr/bin/steamos-select-branch /usr/bin/steamos-select-branch

# steamos-session-select:
chmod 755 ./usr/bin/steamos-session-select
cp ./usr/bin/steamos-session-select /usr/bin/steamos-session-select

# steamos-update:
chmod 755 ./usr/bin/steamos-update
chmod 755 ./usr/bin/steamos-polkit-helpers/steamos-update
cp ./usr/bin/steamos-update /usr/bin/steamos-update
cp ./usr/bin/steamos-polkit-helpers/steamos-update /usr/bin/steamos-polkit-helpers/steamos-update

# steamos-set-timezone:
chmod 755 ./usr/bin/steamos-polkit-helpers/steamos-set-timezone
cp ./usr/bin/steamos-polkit-helpers/steamos-set-timezone /usr/bin/steamos-polkit-helpers/steamos-set-timezone

# steam.desktop:
mkdir -p /usr/share/wayland-sessions/
chmod 644 ./usr/share/wayland-sessions/steam.desktop
cp ./usr/share/wayland-sessions/steam.desktop /usr/share/wayland-sessions/steam.desktop

cd /
rm -rf "$TEMP_DIR"

echo "✅ Helper scripts installation completed successfully."
