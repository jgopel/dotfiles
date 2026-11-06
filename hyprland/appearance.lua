hl.env("XCURSOR_PATH", "@icons@")
hl.env("XCURSOR_THEME", "Adwaita")
hl.env("XCURSOR_SIZE", "24")

hl.config({
  general = {
    gaps_in = 3,
    gaps_out = 7,
    border_size = 2,
    col = { active_border = "rgb(7aa2f7)", inactive_border = "rgb(414868)" },
  },
  decoration = {
    rounding = 0,
    rounding_power = 2,
    dim_inactive = true,
    dim_strength = 0.2,
    blur = { enabled = false },
    shadow = { enabled = false },
  },
  cursor = { enable_hyprcursor = false },
})
hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "default", style = "slidevert" })
