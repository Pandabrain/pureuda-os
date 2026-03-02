#!/usr/bin/env bash
set -exuo pipefail

# This script resolves a multi-arch dependency conflict where the 'libfdk-aac' package 
# (typically from third-party repos like fedora-multimedia/negativo17) 
# obsoletes the standard 'fdk-aac-free' packages from Fedora repositories.
# This prevents Steam (i686) and its dependencies (pipewire-libs.i686) from installing.

if rpm -q libfdk-aac > /dev/null 2>&1; then
    echo "Found third-party libfdk-aac. Swapping with standard fdk-aac-free to resolve multi-arch conflicts..."
    # We use --allowerasing to ensure the swap happens smoothly
    dnf swap -y libfdk-aac fdk-aac-free --allowerasing
else
    echo "Third-party libfdk-aac not found. No swap needed."
fi
