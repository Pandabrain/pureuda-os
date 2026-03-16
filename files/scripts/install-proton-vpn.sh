#!/usr/bin/env bash
set -euo pipefail

# proton-vpn-daemon (dependency of proton-vpn-gnome-desktop) has a %posttrans scriptlet
# that fails when systemd is not running (PID 1), causing dnf to exit with code 1.
# We skip the scriptlets during the OCI build.

echo "Installing Proton VPN with scriptlets disabled..."
dnf install -y --setopt=tsflags=noscripts proton-vpn-gnome-desktop
