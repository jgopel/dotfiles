#!/bin/bash
set -euo pipefail

# Upload the active NixOS system and its runtime closure using your Cachix credentials.
echo "Uploading the current NixOS system to jonathan.cachix.org..."
cachix push jonathan /run/current-system
