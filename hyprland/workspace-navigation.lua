-- Keyboard and trackpad navigation should feel like the same bounded sequence:
-- skip gaps, never wrap, and make room at the right edge only when needed.
-- Keep Hyprland's native gestures for finger-following animation and
-- cancellation. Their boundary logic isn't exposed to Lua keybindings, so
-- mirror only those checks here and leave destination resolution to the
-- compositor.

hl.config({
  animations = { workspace_wraparound = false },
  -- Native swipes skip gaps and create workspaces only at the right edge.
  gestures = { workspace_swipe_create_new = true, workspace_swipe_use_r = false, workspace_swipe_invert = false },
})
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- m±1 skips gaps on this monitor but wraps, so allow it only with a neighbour.
-- At the right edge, r+1 creates a destination unless we're already empty.
local function adjacent_workspace(direction)
  local active = hl.get_active_workspace()
  if not active then
    return
  end
  for _, workspace in ipairs(hl.get_workspaces()) do
    if not workspace.special and workspace.monitor == active.monitor and (workspace.id - active.id) * direction > 0 then
      return direction < 0 and "m-1" or "m+1"
    end
  end
  if direction > 0 and active.windows > 0 then
    return "r+1"
  end
end

for key, direction in pairs({ H = -1, L = 1 }) do
  hl.bind("CTRL + ALT + " .. key, function()
    local target = adjacent_workspace(direction)
    if target then
      hl.dispatch(hl.dsp.focus({ workspace = target }))
    end
  end)
  hl.bind("CTRL + SHIFT + ALT + " .. key, function()
    local target = adjacent_workspace(direction)
    if target then
      hl.dispatch(hl.dsp.window.move({ workspace = target, follow = true }))
    end
  end)
end
