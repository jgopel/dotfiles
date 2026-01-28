#!/bin/bash
set -euo pipefail

# Create an AppArmor profile that allows Signal (installed via Nix) to use
# unprivileged user namespaces, which is required for Electron's sandbox.

echo "Creating AppArmor profile for Signal..."

sudo tee /etc/apparmor.d/signal << 'EOF'
abi <abi/4.0>,
include <tunables/global>

profile signal /nix/store/*-electron-*/libexec/electron/electron flags=(unconfined) {
  userns,
  include if exists <local/signal>
}
EOF

echo "Reloading AppArmor profiles..."
sudo systemctl reload apparmor

echo "Signal AppArmor profile installed."
