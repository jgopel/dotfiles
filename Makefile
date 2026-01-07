.PHONY: all
all: quality

.PHONY: quality
quality:
	uv sync
	uv run pre-commit run --all-files

.PHONY: switch
switch:
	nix run home-manager -- switch --flake .

.PHONY: bootstrap
bootstrap:
	./bootstrap-system.sh
