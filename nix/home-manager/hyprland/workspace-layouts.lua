-- Different tasks need different layouts without changing every workspace.
-- Noctalia supplies the chooser; the compositor owns each workspace's
-- selection so layout-aware shortcuts and the chooser share one source of
-- truth. Lua is recreated on reload, but Hyprland's layout trees survive.
-- Persist only the preset choices for this compositor instance: reloads must
-- preserve manual resizing, while a new login should start with defaults
-- rather than old choices.

local layouts = {}
local presets = {
  ["two-column"] = { engine = "master", orientation = "left", ratio = 2 / 3 },
  ["three-column"] = { engine = "master", orientation = "center", ratio = 1 / 3 },
  scrolling = { engine = "scrolling" },
}

local runtime = os.getenv("XDG_RUNTIME_DIR")
local instance = os.getenv("HYPRLAND_INSTANCE_SIGNATURE")
local layout_path = runtime and instance and (runtime .. "/hypr/" .. instance .. "/workspace-layouts")

local function save_layouts()
  if not layout_path then
    return
  end
  local file = assert(io.open(layout_path .. ".tmp", "w"))
  for id, selected in pairs(layouts) do
    file:write(id, " ", selected.name, "\n")
  end
  file:close()
  assert(os.rename(layout_path .. ".tmp", layout_path))
end

local function layout_rule(id, preset)
  return hl.workspace_rule({
    workspace = id > 0 and tostring(id) or hl.get_workspace(id).name,
    layout = preset.engine,
    layout_opts = { orientation = preset.orientation },
  })
end

local saved = layout_path and io.open(layout_path, "r")
if saved then
  for line in saved:lines() do
    local id, name = line:match("^(%-?%d+) ([%w%-]+)$")
    id = tonumber(id)
    if id and presets[name] and hl.get_workspace(id) then
      layouts[id] = { name = name, rule = layout_rule(id, presets[name]) }
    end
  end
  saved:close()
end

function set_workspace_layout(name)
  local preset = assert(presets[name], "Unknown layout preset")
  local workspace = hl.get_active_special_workspace() or hl.get_active_workspace()
  if not workspace then
    return
  end
  local previous = layouts[workspace.id]
  if previous then
    previous.rule:set_enabled(false)
  end
  layouts[workspace.id] = { name = name, rule = layout_rule(workspace.id, preset) }
  save_layouts()
  -- 0.56 workspace rules don't schedule a layout refresh themselves.
  hl.config({ general = { layout = hl.get_config("general.layout") } })
  hl.exec_scheduled_prop_refresh_immediately()
  if preset.orientation and workspace.windows > 0 then
    hl.dispatch(hl.dsp.layout("orientation" .. preset.orientation))
  end
  if preset.ratio and workspace.windows > 0 then
    hl.dispatch(hl.dsp.layout("mfact exact " .. preset.ratio))
  end
end

function workspace_layout()
  local workspace = hl.get_active_special_workspace() or hl.get_active_workspace()
  if not workspace then
    return nil
  end
  local selected = layouts[workspace.id]
  return selected and selected.name or workspace.tiled_layout
end

hl.on("workspace.removed", function(workspace)
  local selected = layouts[workspace.id]
  if selected then
    selected.rule:set_enabled(false)
    layouts[workspace.id] = nil
    save_layouts()
  end
end)

hl.config({
  scrolling = { fullscreen_on_one_column = false, column_width = 0.5, wrap_swapcol = false },
})
