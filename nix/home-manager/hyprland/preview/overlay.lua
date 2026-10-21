-- Never source the installed Home Manager configuration and its session hooks.
dofile(os.getenv("HYPRLAND_SHARED_CONFIG"))
hl.config({ misc = { disable_watchdog_warning = true } })

-- Add preview-only shortcuts here; use Ctrl+Alt instead of Super.
-- The outer compositor can intercept Super before the preview sees it.
hl.bind("CTRL + ALT + SHIFT + ESCAPE", hl.dsp.exit())
hl.on("hyprland.start", function()
  hl.exec_cmd("noctalia")
end)
