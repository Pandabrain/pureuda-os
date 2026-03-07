# SMB mounting tasks
smb-mount:
    #!/usr/bin/env bash
    echo "This script will help you setup a systemd mount for an SMB share."
    echo "It requires root privileges and will prompt for sudo if needed."
    sudo /usr/bin/setup-smb-mount.sh
