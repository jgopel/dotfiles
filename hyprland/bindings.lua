-- Keyboard shortcuts - largely stolen from Omarchy or Gnome muscle memory
local ipc = "@noctalia@ msg "

-- The workspace open on the monitor (it's never the scratch space)
local current_workspace = "e+0"

local function by_layout(actions)
  return function()
    local action = actions[workspace_layout()] or actions.default
    if action then
      return hl.dispatch(action)
    end
  end
end

local function by_workspace(actions)
  return function()
    local window = hl.get_active_window()
    local workspace = window and window.workspace
    local action = workspace and (actions[workspace.name] or actions.default)
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
hl.bind(
  "SUPER + ALT + S",
  by_workspace({
    ["special:scratchpad"] = hl.dsp.window.move({ workspace = current_workspace, follow = false }),
    default = hl.dsp.window.move({ workspace = "special:scratchpad", follow = false }),
  })
)
hl.bind(
  "SUPER + ALT + SHIFT + S",
  by_workspace({
    ["special:scratchpad"] = hl.dsp.window.move({ workspace = current_workspace, follow = true }),
    default = hl.dsp.window.move({ workspace = "special:scratchpad", follow = true }),
  })
)
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
hl.bind("SUPER + B", hl.dsp.exec_cmd(ipc .. "session lock"))
