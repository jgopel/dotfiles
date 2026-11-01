-- Personal window-management behavior; Noctalia owns the desktop shell.

-- Default monitor settings
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 2 })

-- Input and window-management defaults
hl.config({
  general = { layout = "scrolling" },
  input = {
    kb_layout = "us",
    follow_mouse = 1,
    touchpad = { natural_scroll = false, clickfinger_behavior = true },
  },
  misc = { focus_on_activate = true },
  master = { new_status = "slave" },
})

dofile("@appearance@")
dofile("@workspace-layouts@")
dofile("@workspace-bar@")
dofile("@workspace-navigation@")

-- Must use require: the plugin checks package.loaded before enabling Apply.
-- This file is writable and owned by the plugin, not the Nix store.
require("hyprland-settings")

dofile("@scrolling@")
dofile("@window-rules@")
dofile("@bindings@")
