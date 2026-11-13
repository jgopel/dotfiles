all: quality

quality:
    prek run --all-files

setup-nix:
    NIX_CONFIG="extra-experimental-features = nix-command flakes" nix run home-manager -- switch --flake .

bootstrap:
    ./bootstrap-system.sh

nixos:
    sudo nixos-rebuild switch --flake . --option extra-sandbox-paths /var/cache/ccache
    @if ! ./cache-current-system.sh; then \
        echo "WARNING: NixOS cache upload failed; the system switch succeeded." >&2; \
    fi

home-manager:
    home-manager switch --flake .
