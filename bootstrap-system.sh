#!/bin/bash
set -euo pipefail

# Bootstrap script for privileged operations that Home Manager cannot perform.
# Run this once on a new system before running make switch.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Bootstrap System ==="
echo "This script configures binary caches, installs Docker, and adds the current user to the docker group."
echo "Requires sudo privileges."
echo ""

# Add nix-community binary cache for pre-built packages (e.g., neovim-nightly)
echo "Adding nix-community binary cache..."
if ! grep -q "nix-community.cachix.org" /etc/nix/nix.conf 2>/dev/null; then
    sudo tee -a /etc/nix/nix.conf > /dev/null <<'EOF'
extra-substituters = https://nix-community.cachix.org
extra-trusted-public-keys = nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=
EOF
    sudo systemctl restart nix-daemon
fi

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    echo "Error: Do not run this script as root. It will use sudo when needed."
    exit 1
fi

# Install Docker prerequisites
echo "Installing prerequisites..."
sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg

# Add Docker's official GPG key
echo "Adding Docker GPG key..."
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc > /dev/null
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository
echo "Adding Docker repository..."
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
echo "Installing Docker..."
sudo apt-get update
sudo apt-get install -y \
    containerd.io \
    docker-buildx-plugin \
    docker-ce \
    docker-ce-cli \
    docker-compose-plugin

# Add current user to docker group
echo "Adding $USER to docker group..."
sudo usermod -aG docker "$USER"

# Enable and start Docker service
echo "Enabling Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

# Install Amp CLI (self-updating, outside Nix)
echo "Installing Amp CLI..."
curl -fsSL https://ampcode.com/install.sh | bash

# Install nix garbage collection
echo "Installing nix garbage collection..."
sudo cp "${SCRIPT_DIR}/scripts/nix-gc" /etc/cron.daily/nix-gc
sudo chmod +x /etc/cron.daily/nix-gc

# Install docker garbage collection
echo "Installing docker garbage collection..."
sudo cp "${SCRIPT_DIR}/scripts/docker-gc" /etc/cron.daily/docker-gc
sudo chmod +x /etc/cron.daily/docker-gc

# Desktop-specific setup
echo ""
read -p "Is this a desktop system? [y/N] " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Configuring AppArmor for desktop applications..."
    "${SCRIPT_DIR}/scripts/disable_app_armor_discord.sh"
    "${SCRIPT_DIR}/scripts/disable_app_armor_slack.sh"
    "${SCRIPT_DIR}/scripts/disable_app_armor_signal.sh"
fi

echo ""
echo "=== Bootstrap Complete ==="
echo "NOTE: Log out and back in for docker group membership to take effect."
echo "Then run: make switch"
