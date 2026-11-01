{ pkgs, ... }:

{
  programs.gnome-shell.extensions = [ { package = pkgs.gnomeExtensions.dash-to-dock; } ];

  dconf.settings."org/gnome/shell/extensions/dash-to-dock" = {
    isolate-workspaces = true;
    workspace-agnostic-urgent-windows = false;

    # Hide until the pointer reaches the screen edge, even without overlapping windows.
    manualhide = false;
    dock-fixed = false;
    autohide = true;
    intellihide = false;
    dock-position = "BOTTOM";
    show-mounts = false;
    show-trash = false;
  };
}
