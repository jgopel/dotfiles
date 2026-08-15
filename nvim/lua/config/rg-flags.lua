return {
  "--hidden",
  "--no-ignore",
  -- Exclude all dot directories, but keep dotfiles
  "--glob=!.*/",
  -- Rust
  "--glob=!target",
  -- C++
  "--glob=!build",
  "--glob=!build-*",
}
