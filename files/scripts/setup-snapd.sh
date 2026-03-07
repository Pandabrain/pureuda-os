#!/usr/bin/env bash

set -oue pipefail

# Enable classic snap support
if [ ! -L /snap ]; then
    ln -s /var/lib/snapd/snap /snap
fi
