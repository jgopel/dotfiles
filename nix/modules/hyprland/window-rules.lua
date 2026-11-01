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
