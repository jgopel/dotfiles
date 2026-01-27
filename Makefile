.PHONY: all
all: quality

.PHONY: quality
quality:
	uv sync
	uv run pre-commit run --all-files

.PHONY: setup-nix
setup-nix:
	NIX_CONFIG="extra-experimental-features = nix-command flakes" nix run home-manager -- switch --flake .

.PHONY: bootstrap
bootstrap:
	./bootstrap-system.sh
