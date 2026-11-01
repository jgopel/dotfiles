-- Personal window-management behavior; Noctalia owns the desktop shell.
local ipc = "@noctalia@ msg "
hl.env("XCURSOR_PATH", "@icons@")
hl.env("XCURSOR_THEME", "Adwaita")
hl.env("XCURSOR_SIZE", "24")

-- Default monitor settings
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 2 })

-- Default appearance settings
hl.config({
  general = {
    layout = "scrolling",
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
  input = {
    kb_layout = "us",
    follow_mouse = 1,
    touchpad = { natural_scroll = false, clickfinger_behavior = true },
  },
  cursor = { enable_hyprcursor = false },
  misc = { focus_on_activate = true },
  master = { new_status = "slave" },
})
hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "default", style = "slidevert" })

dofile("@workspace-layouts@")
dofile("@workspace-bar@")
dofile("@workspace-navigation@")
-- Must use require: the plugin checks package.loaded before enabling Apply.
-- This file is writable and owned by the plugin, not the Nix store.
require("hyprland-settings")

local half = 0.49
local total = half * 2
hl.config({
  scrolling = {
    explicit_column_widths = table.concat({ total / 3, half, total * 2 / 3, total }, ", "),
  },
})

-- Noctalia desktop shell surfaces formatting
hl.layer_rule({ match = { namespace = "^noctalia-.*$" }, no_anim = true, blur = true, ignore_alpha = 0.5 })
-- Make Noctalia windows float by default (ie: settings, etc)
hl.window_rule({ match = { class = "dev.noctalia.Noctalia" }, float = true, size = { 1080, 920 } })
-- Float incoming Slack invitations, not the main app or joined huddles.
hl.window_rule({
  match = { class = "^slack$", initial_title = "^Slack - Huddle Preview$" },
  float = true,
  -- NOTE: Have to set the size because there's some sort of refresh bug that I hate
  size = { 370, 540 },
})
-- Background terminal bells must not steal focus or switch workspaces.
hl.window_rule({ match = { class = "^com\\.mitchellh\\.ghostty$" }, focus_on_activate = false })

-- Keyboard shortcuts - largely stolen from Omarchy or Gnome muscle memory
local function by_layout(actions)
  return function()
    local action = actions[workspace_layout()] or actions.default
    if action then
      return hl.dispatch(action)
    end
  end
end

hl.bind("SUPER + SHIFT + RETURN", hl.dsp.layout("swapwithmaster master ignoremaster"))
hl.bind("SUPER + W", hl.dsp.window.close())
hl.bind("SUPER + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind("SUPER + S", hl.dsp.workspace.toggle_special("scratchpad"))
hl.bind("SUPER + ALT + S", hl.dsp.window.move({ workspace = "special:scratchpad", follow = false }))
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd(ipc .. "screenshot-region"))
for key, direction in pairs({ H = "l", J = "d", K = "u", L = "r" }) do
  hl.bind("SUPER + " .. key, hl.dsp.focus({ direction = direction }))
end
hl.bind(
  "SUPER + SHIFT + H",
  by_layout({
    scrolling = hl.dsp.layout("swapcol l"),
    default = hl.dsp.window.swap({ direction = "l" }),
  })
)
hl.bind(
  "SUPER + SHIFT + L",
  by_layout({
    scrolling = hl.dsp.layout("swapcol r"),
    default = hl.dsp.window.swap({ direction = "r" }),
  })
)
hl.bind("SUPER + SHIFT + J", hl.dsp.window.swap({ direction = "d" }))
hl.bind("SUPER + SHIFT + K", hl.dsp.window.swap({ direction = "u" }))
hl.bind("SUPER + CTRL + H", by_layout({ scrolling = hl.dsp.layout("consume_or_expel prev") }))
hl.bind("SUPER + CTRL + L", by_layout({ scrolling = hl.dsp.layout("consume_or_expel next") }))
hl.bind("SUPER + minus", by_layout({ scrolling = hl.dsp.layout("colresize -0.05") }))
hl.bind("SUPER + equal", by_layout({ scrolling = hl.dsp.layout("colresize +0.05") }))
hl.bind("SUPER + R", by_layout({ scrolling = hl.dsp.layout("colresize +conf") }))
hl.bind("SUPER + E", by_layout({ scrolling = hl.dsp.layout("colresize -conf") }))
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(ipc .. "volume-up"), { repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(ipc .. "volume-down"), { repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(ipc .. "volume-mute"))
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd(ipc .. "mic-mute"))
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd(ipc .. "media toggle"))
hl.bind("XF86AudioPause", hl.dsp.exec_cmd(ipc .. "media toggle"))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(ipc .. "brightness-up"), { repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(ipc .. "brightness-down"), { repeating = true })
hl.bind("XF86KbdLightOnOff", hl.dsp.exec_cmd(ipc .. "keyboard-backlight-toggle"))

hl.bind("CTRL + ALT + T", hl.dsp.exec_cmd("@terminal@"))
hl.bind("SUPER + T", hl.dsp.exec_cmd("@layouts@"))
hl.bind("SUPER + space", hl.dsp.exec_cmd(ipc .. "panel-toggle launcher"))
