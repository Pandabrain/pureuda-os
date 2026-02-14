#!/usr/bin/env bash
set -euo pipefail

# 1. Fetch latest download URL
URL=$(curl -s 'https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release' | grep -Po '"linux":\s*\{"link":\s*"\K[^"]+')

# 2. Extract binary to /usr/bin
# This makes it part of your immutable image
curl -L "$URL" | tar -xz -C /usr/bin --strip-components=1 --wildcards "*/jetbrains-toolbox"

# 3. Handle Autostart via /etc/profile.d/
# Instead of a .desktop file, we place a shell script in profile.d.
# This runs when you log in. It checks if the toolbox has already 
# initialized itself. If not, it launches it.
mkdir -p /etc/profile.d
cat <<EOF > /etc/profile.d/jetbrains-toolbox-start.sh
# Only run for interactive graphical sessions
if [ -n "\$DISPLAY" ] || [ -n "\$WAYLAND_DISPLAY" ]; then
    # If the user hasn't initialized the toolbox yet, start it.
    # Once it starts, it creates its own official .desktop file 
    # and handles its own future autostarts.
    if [ ! -f "\$HOME/.local/share/applications/jetbrains-toolbox.desktop" ]; then
        /usr/bin/jetbrains-toolbox --nosplash &
    fi
fi
EOF

echo "Binary installed to /usr/bin. Initialization script added to /etc/profile.d/."
