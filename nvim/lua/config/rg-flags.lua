return {
  "--hidden",
  "--no-ignore",
  -- Generic
  "--glob=!.git",
  -- Nix
  "--glob=!.direnv",
  -- Rust
  "--glob=!target",
  -- Python
  "--glob=!.venv",
  "--glob=!.mypy_cache",
  "--glob=!.ruff_cache",
  "--glob=!.pytest_cache",
  -- C++
  "--glob=!build",
  "--glob=!build-*",
}
