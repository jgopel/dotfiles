all: quality

quality:
    prek run --all-files

setup-nix:
    NIX_CONFIG="extra-experimental-features = nix-command flakes" nix run home-manager -- switch --flake .

bootstrap:
    ./bootstrap-system.sh

nixos:
    sudo nixos-rebuild switch --flake . --option extra-sandbox-paths /var/cache/ccache

nix-darwin:
    sudo darwin-rebuild switch --flake .

home-manager:
    home-manager switch --flake .
