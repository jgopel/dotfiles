#!/bin/bash
set -euo pipefail

# Create an AppArmor profile that allows Chrome (installed via Nix) to use
# unprivileged user namespaces, which is required for Chrome's sandbox.

echo "Creating AppArmor profile for Chrome..."

sudo tee /etc/apparmor.d/chrome <<'EOF'
abi <abi/4.0>,
include <tunables/global>

profile chrome /nix/store/*-google-chrome-*/share/google/chrome/chrome flags=(unconfined) {
  userns,
  include if exists <local/chrome>
}
EOF

echo "Reloading AppArmor profiles..."
sudo systemctl reload apparmor

echo "Chrome AppArmor profile installed."
