#!/bin/bash
set -euo pipefail

# Create an AppArmor profile that allows Discord (installed via Nix) to use
# unprivileged user namespaces, which is required for Electron's sandbox.

echo "Creating AppArmor profile for Discord..."

sudo tee /etc/apparmor.d/discord << 'EOF'
abi <abi/4.0>,
include <tunables/global>

profile discord /nix/store/*-discord-*/opt/Discord/Discord flags=(unconfined) {
  userns,
  include if exists <local/discord>
}
EOF

echo "Reloading AppArmor profiles..."
sudo systemctl reload apparmor

echo "Discord AppArmor profile installed."
