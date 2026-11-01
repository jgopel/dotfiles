{
  den.aspects.firefox.homeManager = {
    programs.firefox = {
      enable = true;
      policies.Preferences."widget.gtk.native-emoji-dialog" = {
        # Keep Ctrl+. available for 1Password in every profile.
        Value = false;
        Status = "locked";
      };
    };

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "application/vnd.mozilla.xul+xml" = "firefox.desktop";
        "application/xhtml+xml" = "firefox.desktop";
        "text/html" = "firefox.desktop";
        "text/xml" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
      };
    };
  };
}
