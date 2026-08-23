.PHONY: all
all: quality

.PHONY: quality
quality:
	prek run --all-files

.PHONY: setup-nix
setup-nix:
	NIX_CONFIG="extra-experimental-features = nix-command flakes" nix run home-manager -- switch --flake .

.PHONY: bootstrap
bootstrap:
	./bootstrap-system.sh

.PHONY: nixos
nixos:
	sudo nixos-rebuild switch --flake .

.PHONY: home-manager
home-manager:
	home-manager switch --flake .
