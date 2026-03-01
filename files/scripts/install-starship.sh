#!/usr/bin/env bash
set -exuo pipefail

echo "Installing Starship..."
curl -sS https://starship.rs/install.sh | sh -s -- --yes
