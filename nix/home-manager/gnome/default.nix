{ pkgs, ... }:

{
  # Preserve the existing extension order after module merging.
  imports = [
    ./extensions/always-show-workspace-thumbnails.nix
    ./extensions/vitals.nix
    ./extensions/tactile.nix
  ];

  programs.gnome-shell = {
    enable = true;
    extensions = [ { package = pkgs.gnomeExtensions.appindicator; } ];
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      clock-format = "12h";
      show-battery-percentage = true;
    };

    "org/gnome/desktop/peripherals/touchpad".natural-scroll = false;

    "org/gnome/desktop/wm/keybindings" = {
      switch-applications = [ "<Super>Tab" ];
      switch-applications-backward = [ "<Shift><Super>Tab" ];
      switch-windows = [ "<Alt>Tab" ];
      switch-windows-backward = [ "<Shift><Alt>Tab" ];
    };

    "org/gnome/mutter".workspaces-only-on-primary = false;

    "org/gnome/shell/keybindings".show-screenshot-ui = [
      "Print"
      "<Super><Shift>s"
    ];

    "org/gnome/shell/window-switcher".current-workspace-only = true;

    "org/gnome/settings-daemon/plugins/power".sleep-inactive-ac-type = "nothing";

    "org/gnome/nautilus/preferences".sort-directories-first = true;

    "org/gtk/gtk4/settings/file-chooser".sort-directories-first = true;
    "org/gtk/settings/file-chooser".sort-directories-first = true;

    "org/gnome/settings-daemon/plugins/media-keys".custom-keybindings = [
      "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/ghostty/"
    ];
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/ghostty" = {
      binding = "<Control><Alt>t";
      command = "${pkgs.ghostty}/bin/ghostty";
      name = "Ghostty";
    };
  };
}
