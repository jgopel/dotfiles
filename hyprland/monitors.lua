local monitor_generation = 0
-- A new event supersedes pending retries while dock outputs settle.
function reconcile_monitors()
  monitor_generation = monitor_generation + 1
  local generation = monitor_generation
  for _, delay in ipairs({ 1, 1000, 3000, 7000 }) do
    hl.timer(function()
      if generation == monitor_generation then
        hl.exec_cmd("@monitors@")
      end
    end, { timeout = delay, type = "oneshot" })
  end
end
for _, event in ipairs({
  "hyprland.start",
  "config.reloaded",
  "monitor.added",
  "monitor.removed",
  "monitor.layout_changed",
}) do
  hl.on(event, reconcile_monitors)
end
for _, state in ipairs({ "on", "off" }) do
  hl.bind("switch:" .. state .. ":Lid Switch", reconcile_monitors, { locked = true })
end
