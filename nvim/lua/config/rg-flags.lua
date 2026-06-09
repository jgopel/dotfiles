return {
  "--hidden",
  "--no-ignore",
  -- Generic
  "--glob=!.git",
  -- Rust
  "--glob=!target",
  -- Python
  "--glob=!.venv",
  "--glob=!.mypy_cache",
  "--glob=!.ruff_cache",
  -- C++
  "--glob=!build",
  "--glob=!build-*",
}
