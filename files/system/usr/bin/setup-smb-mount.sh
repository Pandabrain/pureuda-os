#!/usr/bin/env bash
set -euo pipefail

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run with sudo or as root"
  exit 1
fi

# Function to escape path for systemd unit name
escape_path() {
    # Replace initial / with nothing, then replace / with -
    # systemd-escape is the proper way
    systemd-escape --path "$1"
}

# 1. Gather information
read -p "Enter server address (e.g., 192.168.1.100): " server_address
read -p "Enter share name: " share_name

default_mount_point="/var/mnt/$server_address/$share_name"
read -p "Enter local mount point [$default_mount_point]: " mount_point
mount_point=${mount_point:-$default_mount_point}

read -p "Enter username: " username

# Define credentials file path (stored safely)
# We use /etc/smb-credentials/ as a safe place
cred_dir="/etc/smb-credentials"
cred_file="$cred_dir/$username.cred"

# 2. Handle credentials
if [ -f "$cred_file" ]; then
    echo "Using existing credentials file: $cred_file"
else
    # Prompt for password (masked)
    read -s -p "Enter password for $username: " password
    echo "" # New line after masked input
    
    mkdir -p "$cred_dir"
    chmod 700 "$cred_dir"
    
    cat <<EOF > "$cred_file"
username=$username
password=$password
EOF
    chmod 600 "$cred_file"
    echo "Credentials stored safely in $cred_file"
fi

# 3. Create mount point directory
mkdir -p "$mount_point"

# 4. Create systemd mount unit
# systemd unit name must match the mount point path
unit_name=$(escape_path "$mount_point").mount
unit_path="/etc/systemd/system/$unit_name"

echo "Creating systemd mount unit: $unit_path"

cat <<EOF > "$unit_path"
[Unit]
Description=Mount SMB Share //${server_address}/${share_name} to ${mount_point}
After=network-online.target
Wants=network-online.target

[Mount]
What=//${server_address}/${share_name}
Where=${mount_point}
Type=cifs
Options=credentials=${cred_file},iocharset=utf8,rw,uid=1000,gid=1000,file_mode=0777,dir_mode=0777,vers=3.0,noserverino

[Install]
WantedBy=multi-user.target
EOF

# 5. Reload systemd and mount
echo "Reloading systemd and starting mount..."
systemctl daemon-reload
systemctl enable --now "$unit_name"

# 6. List contents of the mount point, so the user can see if it worked right away
echo "Contents of $mount_point: (if this shows nothing, the share is either empty or the mount was not setup correctly)"
ls -lh "$mount_point"

echo "SMB share successfully mounted at $mount_point"
