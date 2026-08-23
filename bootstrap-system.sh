#!/bin/bash
set -euo pipefail

# Bootstrap script for privileged operations that Home Manager cannot perform.
# Run this once on a new system before running make switch.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

setup_google_drive_cloud_project() (
    local default_project_id
    local project_id
    local gcloud_config_dir
    local auth_url
    local clients_url

    default_project_id="rclone-drive-$(date +%s)"
    read -p "Google Cloud project ID [$default_project_id]: " -r project_id
    project_id=${project_id:-$default_project_id}
    if [[ ! $project_id =~ ^[a-z][a-z0-9-]{4,28}[a-z0-9]$ ]]; then
        echo "Invalid project ID. Use 6-30 lowercase letters, digits, or hyphens; start with a letter." >&2
        return 1
    fi

    gcloud_config_dir=$(mktemp -d)
    trap 'rm -rf "$gcloud_config_dir"' EXIT
    export CLOUDSDK_CONFIG=$gcloud_config_dir

    echo "Sign in to the Google account that should own the OAuth client."
    nix --extra-experimental-features "nix-command flakes" \
        run nixpkgs#google-cloud-sdk -- auth login

    if ! nix --extra-experimental-features "nix-command flakes" \
        run nixpkgs#google-cloud-sdk -- projects describe "$project_id" >/dev/null 2>&1; then
        nix --extra-experimental-features "nix-command flakes" \
            run nixpkgs#google-cloud-sdk -- projects create "$project_id" --name="rclone Google Drive"
    fi
    nix --extra-experimental-features "nix-command flakes" \
        run nixpkgs#google-cloud-sdk -- services enable drive.googleapis.com --project="$project_id"

    auth_url="https://console.cloud.google.com/auth/overview?project=$project_id"
    clients_url="https://console.cloud.google.com/auth/clients?project=$project_id"

    echo ""
    echo "Finish the Google Auth Platform setup in the browser:"
    echo "  1. Configure the audience as External."
    echo "  2. Add the https://www.googleapis.com/auth/drive scope."
    echo "  3. Publish the app to In production so its refresh tokens do not expire after seven days."
    echo "Open: $auth_url"
    if command -v xdg-open >/dev/null; then
        xdg-open "$auth_url" >/dev/null 2>&1 || true
    fi
    read -p "Press Enter after publishing the app to In production... " -r

    echo "Create a Desktop app OAuth client and download its JSON credentials."
    echo "Open: $clients_url"
    if command -v xdg-open >/dev/null; then
        xdg-open "$clients_url" >/dev/null 2>&1 || true
    fi
)

configure_google_drive_oauth() {
    local secrets_dir="$HOME/.local/share/rclone"
    local client_id_file="$secrets_dir/google-drive-client-id"
    local client_secret_file="$secrets_dir/google-drive-client-secret"
    local token_file="$secrets_dir/google-drive-token.json"
    local credentials_json=""
    local import_credentials=false

    echo ""
    if [[ -f $client_id_file && -f $client_secret_file && -f $token_file ]]; then
        read -p "Google Drive OAuth is already configured. Reconfigure it? [y/N] " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return
        fi
    else
        read -p "Configure a private Google Drive OAuth client now? [Y/n] " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            return
        fi
    fi

    if [[ -f $client_id_file && -f $client_secret_file ]]; then
        read -p "Import a different Desktop OAuth client? [y/N] " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            import_credentials=true
        fi
    else
        import_credentials=true
    fi

    if [[ $import_credentials == true ]]; then
        read -p "Do you already have a downloaded Desktop OAuth client JSON file? [y/N] " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            setup_google_drive_cloud_project
        fi

        while [[ -z $credentials_json || ! -r $credentials_json ]]; do
            read -e -p "Path to the downloaded Desktop OAuth client JSON: " -r credentials_json
            credentials_json=${credentials_json/#\~/$HOME}
            if [[ ! -r $credentials_json ]]; then
                echo "Cannot read: $credentials_json" >&2
            fi
        done
    fi

    echo "A browser will open for Google login. If it does not, open the URL printed by rclone."
    echo "Sign in to the Google account that this desktop should mount."

    nix --extra-experimental-features "nix-command flakes" \
        shell nixpkgs#rclone nixpkgs#jq \
        --command bash -s -- \
        "$credentials_json" "$client_id_file" "$client_secret_file" "$token_file" <<'OAUTH_SCRIPT'
set -euo pipefail

credentials_json=$1
client_id_file=$2
client_secret_file=$3
token_file=$4
secrets_dir=$(dirname "$token_file")
install -d -m 700 "$secrets_dir"
umask 077

temp_dir=$(mktemp -d)
staged_client_id=""
staged_client_secret=""
staged_token=$(mktemp "$secrets_dir/.google-drive-token.XXXXXX")
cleanup() {
    rm -rf "$temp_dir"
    if [[ -n $staged_client_id ]]; then
        rm -f "$staged_client_id"
    fi
    if [[ -n $staged_client_secret ]]; then
        rm -f "$staged_client_secret"
    fi
    rm -f "$staged_token"
}
trap cleanup EXIT

if [[ -n $credentials_json ]]; then
    staged_client_id=$(mktemp "$secrets_dir/.google-drive-client-id.XXXXXX")
    staged_client_secret=$(mktemp "$secrets_dir/.google-drive-client-secret.XXXXXX")
    jq -er '.installed.client_id | strings | select(endswith(".apps.googleusercontent.com"))' \
        "$credentials_json" > "$staged_client_id"
    jq -er '.installed.client_secret | strings | select(length > 0)' \
        "$credentials_json" > "$staged_client_secret"
    client_id_source=$staged_client_id
    client_secret_source=$staged_client_secret
else
    client_id_source=$client_id_file
    client_secret_source=$client_secret_file
fi

if [[ ! -r $client_id_source || ! -r $client_secret_source ]]; then
    echo "Google Drive OAuth client credentials are missing." >&2
    exit 1
fi

client_id=$(<"$client_id_source")
client_secret=$(<"$client_secret_source")
if [[ ! $client_id =~ ^[A-Za-z0-9._-]+\.apps\.googleusercontent\.com$ ]]; then
    echo "The OAuth client JSON does not contain a valid Desktop client ID." >&2
    exit 1
fi
if [[ -z $client_secret || $client_secret == *$'\n'* ]]; then
    echo "The OAuth client JSON does not contain a valid client secret." >&2
    exit 1
fi

printf '[bootstrap]\ntype = drive\nscope = drive\nclient_id = %s\nclient_secret = %s\n' \
    "$client_id" "$client_secret" > "$temp_dir/rclone.conf"
rclone --config "$temp_dir/rclone.conf" config update bootstrap \
    config_is_local=true --no-output
rclone --config "$temp_dir/rclone.conf" config dump \
    | jq -cer ".bootstrap.token | fromjson" > "$staged_token"

chmod 600 "$staged_token"
if [[ -n $staged_client_id ]]; then
    chmod 600 "$staged_client_id" "$staged_client_secret"
    mv -f "$staged_client_id" "$client_id_file"
    mv -f "$staged_client_secret" "$client_secret_file"
fi
mv -f "$staged_token" "$token_file"
OAUTH_SCRIPT

    if [[ $import_credentials == true ]]; then
        echo "Google Drive OAuth client credentials imported."
        echo "Store the downloaded JSON in 1Password, then remove the downloaded copy."
    fi
    echo "Google Drive OAuth token saved to $token_file"
    echo "Apply Home Manager before restarting rclone so it injects the new client credentials."
}

if [[ ${1:-} == --google-drive ]]; then
    if [[ $EUID -eq 0 ]]; then
        echo "Error: Do not run this script as root." >&2
        exit 1
    fi
    configure_google_drive_oauth
    exit
fi

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

echo ""
echo "=== Bootstrap Complete ==="
echo "NOTE: Log out and back in for docker group membership to take effect."
echo "Then run: make switch"
