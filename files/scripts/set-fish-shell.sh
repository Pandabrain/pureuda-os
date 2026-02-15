#!/usr/bin/env bash
set -euo pipefail

echo "Setting fish as the default shell for new users..."
sed -i 's/^SHELL=.*/SHELL=\/usr\/bin\/fish/' /etc/default/useradd

echo "Configuring Starship and disabling Fish greeting..."
mkdir -p /etc/fish/conf.d
echo 'starship init fish | source' > /etc/fish/conf.d/starship.fish
echo 'set -g fish_greeting' > /etc/fish/conf.d/disable-greeting.fish
