#!/bin/bash
set -euo pipefail

# Bootstrap script for privileged operations that Home Manager cannot perform.
# Run this once on a new system before running make switch.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

configure_google_drive_oauth() {
    local token_file="$HOME/.local/share/rclone/google-drive-token.json"
    local configure_token=false

    echo ""
    if [[ -f $token_file ]]; then
        read -p "A Google Drive OAuth token already exists. Re-authenticate? [y/N] " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            configure_token=true
        fi
    else
        read -p "Authenticate Google Drive now? [Y/n] " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            configure_token=true
        fi
    fi

    if [[ $configure_token != true ]]; then
        return
    fi

    echo "A browser will open for Google login. If it does not, open the URL printed by rclone."
    echo "Sign in to the Google account that this desktop should mount."

    nix --extra-experimental-features "nix-command flakes" \
        shell nixpkgs#rclone nixpkgs#jq \
        --command bash -s -- "$token_file" <<'OAUTH_SCRIPT'
set -euo pipefail

token_file=$1
token_dir=$(dirname "$token_file")
install -d -m 700 "$token_dir"

temp_dir=$(mktemp -d)
staged_token=$(mktemp "$token_dir/.google-drive-token.XXXXXX")
cleanup() {
    rm -rf "$temp_dir"
    rm -f "$staged_token"
}
trap cleanup EXIT

rclone --config "$temp_dir/rclone.conf" config create bootstrap drive \
    scope=drive config_is_local=true --no-output
rclone --config "$temp_dir/rclone.conf" config dump \
    | jq -cer ".bootstrap.token | fromjson" > "$staged_token"

chmod 600 "$staged_token"
mv -f "$staged_token" "$token_file"
OAUTH_SCRIPT

    echo "Google Drive OAuth token saved to $token_file"
}

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
    echo "Installing FUSE 3 for rclone mounts..."
    sudo apt-get install -y fuse3

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

    configure_google_drive_oauth

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

# Install Amp CLI (self-updating, outside Nix)
echo "Installing Amp CLI..."
curl -fsSL https://ampcode.com/install.sh | bash

echo ""
echo "=== Bootstrap Complete ==="
echo "NOTE: Log out and back in for docker group membership to take effect."
echo "Then run: make switch"
