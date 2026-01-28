#!/bin/bash
set -euo pipefail

# Create an AppArmor profile that allows Zoom (installed via Nix) to use
# unprivileged user namespaces, which is required for its sandbox.

echo "Creating AppArmor profile for Zoom..."

sudo tee /etc/apparmor.d/zoom << 'EOF'
abi <abi/4.0>,
include <tunables/global>

# Use default_allow flag - this allows the app to remain effectively unconfined
# but adds the userns rule to exempt from unprivileged_userns restriction
# See: https://ubuntu.com/blog/ubuntu-23-10-restricted-unprivileged-user-namespaces

# Nix store paths - using glob patterns for profile attachment
profile zoom /nix/store/*zoom*/bin/zoom flags=(default_allow) {
  userns,
  include if exists <local/zoom>
}

profile zoom-launcher /nix/store/*zoom*/opt/zoom/ZoomLauncher flags=(default_allow) {
  userns,
  include if exists <local/zoom-launcher>
}

profile zoom-main /nix/store/*zoom*/opt/zoom/zoom flags=(default_allow) {
  userns,
  include if exists <local/zoom-main>
}

profile zoom-webview /nix/store/*zoom*/opt/zoom/ZoomWebviewHost flags=(default_allow) {
  userns,
  include if exists <local/zoom-webview>
}

profile zoom-bwrap /nix/store/*bubblewrap*/bin/bwrap flags=(default_allow) {
  userns,
  include if exists <local/zoom-bwrap>
}

# FHS paths (inside bwrap mount namespace)
profile zoom-fhs-launcher /opt/zoom/ZoomLauncher flags=(default_allow) {
  userns,
  include if exists <local/zoom-fhs-launcher>
}

profile zoom-fhs-main /opt/zoom/zoom flags=(default_allow) {
  userns,
  include if exists <local/zoom-fhs-main>
}

profile zoom-fhs-webview /opt/zoom/ZoomWebviewHost flags=(default_allow) {
  userns,
  include if exists <local/zoom-fhs-webview>
}
EOF

echo "Reloading AppArmor profiles..."
sudo systemctl reload apparmor

echo "Zoom AppArmor profile installed."
