#!/bin/bash
set -euo pipefail

# Create an AppArmor profile that allows Slack (installed via Nix) to use
# unprivileged user namespaces, which is required for Electron's sandbox.

echo "Creating AppArmor profile for Slack..."

sudo tee /etc/apparmor.d/slack <<'EOF'
abi <abi/4.0>,
include <tunables/global>

profile slack /nix/store/*-slack-*/lib/slack/slack flags=(unconfined) {
  userns,
  include if exists <local/slack>
}
EOF

echo "Reloading AppArmor profiles..."
sudo systemctl reload apparmor

echo "Slack AppArmor profile installed."
