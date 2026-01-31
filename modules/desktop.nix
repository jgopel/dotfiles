{ config, pkgs, nixgl, ... }:

let
  dotfilesDir = builtins.toString ./..;

  wrap = config.lib.nixGL.wrap;

  wrappedChrome = wrap pkgs.google-chrome;
  wrappedDiscord = wrap pkgs.discord;
  wrappedFirefox = wrap pkgs.firefox;
  wrappedGhostty = wrap pkgs.ghostty;
  wrappedSignal = wrap pkgs.signal-desktop;
  wrappedSlack = wrap pkgs.slack;

  # Zoom's bwrap sandbox breaks desktop integration on non-NixOS systems
  # because it replaces /usr/share with Nix FHS content, hiding host gsettings schemas.
  # We override buildFHSEnv to inject extra bwrap args for host schema access.
  zoomWithFixes = pkgs.zoom-us.override {
    buildFHSEnv = args: pkgs.buildFHSEnv (args // {
      extraBwrapArgs = (args.extraBwrapArgs or []) ++ [
        "--ro-bind /usr/share/glib-2.0/schemas /usr/share/glib-2.0/schemas"
        "--setenv GSETTINGS_SCHEMA_DIR /usr/share/glib-2.0/schemas"
        "--setenv QT_XCB_GL_INTEGRATION none"
      ];
    });
  };

  wrappedZoom = wrap zoomWithFixes;
in
{
  targets.genericLinux.nixGL.packages = nixgl.packages;

  home.packages = with pkgs; [
    dropbox
    hack-font
    keepassxc
    polychromatic
    wrappedChrome
    wrappedDiscord
    wrappedFirefox
    wrappedGhostty
    wrappedSignal
    wrappedSlack
    wrappedZoom
  ];

  xdg.configFile."ghostty/config".source = "${dotfilesDir}/ghostty/config";

  xdg.desktopEntries.ghostty = {
    name = "Ghostty";
    exec = "${wrappedGhostty}/bin/ghostty --gtk-single-instance=true";
    icon = "com.mitchellh.ghostty";
    terminal = false;
    categories = [ "System" "TerminalEmulator" ];
    comment = "A terminal emulator";
    settings = {
      StartupNotify = "true";
      StartupWMClass = "com.mitchellh.ghostty";
    };
  };

  # Hide the original unwrapped .desktop file from the ghostty package
  xdg.desktopEntries."com.mitchellh.ghostty" = {
    name = "Ghostty (unwrapped)";
    exec = "false";
    noDisplay = true;
  };

  xdg.desktopEntries.google-chrome = {
    name = "Google Chrome";
    exec = "google-chrome-stable %U";
    icon = "google-chrome";
    terminal = false;
    categories = [ "Network" "WebBrowser" ];
    comment = "Access the Internet";
  };

  # Hide the original unwrapped .desktop files from the google-chrome package
  xdg.desktopEntries."com.google.Chrome" = {
    name = "Google Chrome (unwrapped)";
    exec = "false";
    noDisplay = true;
  };

  fonts.fontconfig.enable = true;

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "text/html" = "firefox.desktop";
    };
  };
}
