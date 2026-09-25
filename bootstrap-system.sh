#!/bin/bash
set -euo pipefail

# Bootstrap system prerequisites, activate Home Manager, then set the login shell.
# Run this as your regular user after installing Nix and adding a host configuration.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Bootstrap System ==="
echo "This script configures binary caches, installs Docker, activates Home Manager, and configures Fish as the login shell."
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

# Add Numtide binary cache for pre-built LLM agents
echo "Adding Numtide LLM agent binary cache..."
if ! grep -q "cache.numtide.com" /etc/nix/nix.conf 2>/dev/null; then
    sudo tee -a /etc/nix/nix.conf > /dev/null <<'EOF'
extra-substituters = https://cache.numtide.com
extra-trusted-public-keys = niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=
EOF
    sudo systemctl restart nix-daemon
fi

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    echo "Error: Do not run this script as root. It will use sudo when needed."
    exit 1
fi

# Install Docker prerequisites and make for the Home Manager setup target.
echo "Installing prerequisites..."
sudo apt-get update
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    make

# Add Docker's official GPG key
echo "Adding Docker GPG key..."
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc > /dev/null
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository
echo "Adding Docker repository..."
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(# shellcheck source=/dev/null
. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
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

# Server-specific setup
echo ""
read -p "Is this a server system? [y/N] " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Enabling lingering for user systemd services..."
    sudo loginctl enable-linger "$USER"

    echo "Installing Eternal Terminal server..."
    sudo add-apt-repository -y ppa:jgmath2000/et
    sudo apt-get update
    sudo apt-get install -y et
    sudo systemctl enable --now et
fi

# Desktop-specific setup
echo ""
read -p "Is this a desktop system? [y/N] " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    read -p "Is this a Nascent desktop system? [y/N] " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Install Tailscale and configure it to accept subnet routes for NFS access.
        echo "Installing Tailscale..."
        if ! dpkg-query -W -f='${Status}' tailscale 2>/dev/null | grep -q "install ok installed"; then
            curl -fsSL https://tailscale.com/install.sh | sh
        fi

        echo "Enabling Tailscale service..."
        sudo systemctl enable --now tailscaled

        echo "Configuring Tailscale to accept advertised routes for NFS access..."
        if sudo tailscale status >/dev/null 2>&1; then
            sudo tailscale set --accept-routes=true
        else
            sudo tailscale up --accept-routes=true
        fi
    fi

    echo "Installing OpenRazer for Razer peripheral support..."
    sudo add-apt-repository -y ppa:openrazer/stable
    sudo apt-get update
    sudo apt-get install -y openrazer-meta
    sudo gpasswd -a "$USER" plugdev

    echo "Configuring AppArmor for desktop applications..."
    "${SCRIPT_DIR}/scripts/disable_app_armor_chrome.sh"
    "${SCRIPT_DIR}/scripts/disable_app_armor_discord.sh"
    "${SCRIPT_DIR}/scripts/disable_app_armor_slack.sh"
    "${SCRIPT_DIR}/scripts/disable_app_armor_signal.sh"
fi

# Activate as the current user before selecting Home Manager's Fish as the shell.
echo "Activating Home Manager..."
make -C "$SCRIPT_DIR" setup-nix

# Keep the profile path so the login shell follows Home Manager upgrades.
FISH_SHELL="$HOME/.nix-profile/bin/fish"
if [[ ! -x "$FISH_SHELL" ]]; then
    echo "Error: Home Manager did not install an executable Fish at $FISH_SHELL."
    exit 1
fi

echo "Configuring Fish as the login shell..."
if ! grep -Fxq "$FISH_SHELL" /etc/shells; then
    printf '%s\n' "$FISH_SHELL" | sudo tee -a /etc/shells > /dev/null
fi
if [[ "$(getent passwd "$USER" | cut -d: -f7)" != "$FISH_SHELL" ]]; then
    sudo chsh -s "$FISH_SHELL" "$USER"
fi

echo ""
echo "=== Bootstrap Complete ==="
echo "NOTE: Log out and back in for docker group membership and login shell changes to take effect."
