return {
  "--hidden",
  "--no-ignore",
  -- Exclude all dot directories, but keep dotfiles
  "--glob=*",
  "--glob=!.*/",
  "--glob=.github",
  "--glob=.github/**",
  -- Rust
  "--glob=!target",
  -- C++
  "--glob=!build",
  "--glob=!build-*",
}
