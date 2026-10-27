-- Workspace IDs can have gaps, but number-row shortcuts should address the
-- positions the user sees in Noctalia's bar, not require memorizing those IDs.
-- Derive that ordering from live compositor state rather than keeping a second
-- workspace list or depending on shell IPC. This assumes the bar's policy of
-- showing occupied numbered workspaces plus the active one, in numeric order.

local function bar_workspace(position)
  local active = hl.get_active_workspace()
  local ids = {}
  for _, workspace in ipairs(hl.get_workspaces()) do
    if workspace.id > 0 and (workspace.windows > 0 or (active and workspace.id == active.id)) then
      table.insert(ids, workspace.id)
    end
  end
  table.sort(ids)
  return ids[position]
end

for position = 1, 10 do
  local key = "code:" .. (position + 9)
  hl.bind("SUPER + " .. key, function()
    local target = bar_workspace(position)
    if target then
      hl.dispatch(hl.dsp.focus({ workspace = target }))
    end
  end)
  hl.bind("SUPER + SHIFT + " .. key, function()
    local target = bar_workspace(position)
    if target then
      hl.dispatch(hl.dsp.window.move({ workspace = target, follow = true }))
    end
  end)
end
