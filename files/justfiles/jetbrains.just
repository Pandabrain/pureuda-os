# Initialize JetBrains Toolbox

# Starting the Toolbox for the first time creates its own desktop file and autostart entry.
initialize-jetbrains-toolbox:
    #!/usr/bin/env bash
    if [ -x "/opt/jetbrains-toolbox/bin/jetbrains-toolbox" ]; then
        echo "🚀 Starting JetBrains Toolbox..."
        "/opt/jetbrains-toolbox/jetbrains-toolbox" > /dev/null 2>&1 &
        echo "✅ JetBrains Toolbox has been started in the background."
        echo "   It will now create its own desktop file and autostart entry."
    else
        echo "❌ JetBrains Toolbox not found in /opt/jetbrains-toolbox/jetbrains-toolbox"
        echo "-- Please report this to the system maintainer. --"
        exit 1
    fi
