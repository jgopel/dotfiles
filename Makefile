.PHONY: all
all: quality

.PHONY: quality
quality:
	uv sync
	uv run pre-commit run --all-files
