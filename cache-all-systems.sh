#!/bin/bash
set -euo pipefail

# Build the selected NixOS systems without activating them, then upload their closures.
# Run as your regular user with Nix, Cachix write credentials, and sudo available.

SYSTEMS=(
    XPS-17-9720
    ThinkPad-X1-Carbon-Gen-12
)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ $EUID -eq 0 ]]; then
    echo "Error: Do not run this script as root. It will use sudo when needed." >&2
    exit 1
fi

# Resolve Nix before sudo replaces PATH with its system-only secure_path.
NIX_BIN="$(command -v nix)"

# Keep cache trust and credentials local to this run, including on failure.
umask 077
CACHE_DIR=$(mktemp -d /tmp/cache-all-systems.XXXXXXXX)
trap 'rm -rf -- "$CACHE_DIR"' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
mkdir -p "$CACHE_DIR/nix"
touch "$CACHE_DIR/nix/nix.conf"

# Preserve credentials for other caches when selecting the temporary netrc.
NETRC_FILE=$(sudo "$NIX_BIN" --extra-experimental-features nix-command config show netrc-file)
if sudo test -f "$NETRC_FILE"; then
    # Read as root, but deliberately create the private copy as this user.
    # shellcheck disable=SC2024
    sudo cat "$NETRC_FILE" >"$CACHE_DIR/nix/netrc"
fi

# Let Cachix read its own credentials (including CACHIX_AUTH_TOKEN) and key.
# Only its generated Nix configuration is redirected; its input config is not.
CACHIX_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/cachix/cachix.dhall"
XDG_CONFIG_HOME="$CACHE_DIR" cachix \
    --config "$CACHIX_CONFIG" \
    use jonathan --mode user-nixconf
# Add to the builder's caches and keys instead of replacing them.
sed -i \
    -e 's/^substituters =/extra-substituters =/' \
    -e 's/^trusted-public-keys =/extra-trusted-public-keys =/' \
    "$CACHE_DIR/nix/nix.conf"

# The XPS kernel uses ccache inside the Nix build sandbox.
sudo install -d -m 0770 -o root -g nixbld /var/cache/ccache

for host in "${SYSTEMS[@]}"; do
    echo "Building NixOS for ${host}..."
    # Reuse the ignored result symlink to keep the closure rooted until uploaded.
    sudo env NIX_USER_CONF_FILES="$CACHE_DIR/nix/nix.conf" "$NIX_BIN" build \
        --extra-experimental-features 'nix-command flakes' \
        "${SCRIPT_DIR}#nixosConfigurations.${host}.config.system.build.toplevel" \
        --option extra-sandbox-paths /var/cache/ccache \
        --out-link "${SCRIPT_DIR}/result"

    echo "Uploading ${host} to jonathan.cachix.org..."
    cachix push jonathan "${SCRIPT_DIR}/result"
done
