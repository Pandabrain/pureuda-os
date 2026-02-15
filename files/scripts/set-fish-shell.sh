#!/usr/bin/env bash
set -euo pipefail

echo "Setting fish as the default shell for new users..."
sed -i 's/^SHELL=.*/SHELL=\/usr\/bin\/fish/' /etc/default/useradd
