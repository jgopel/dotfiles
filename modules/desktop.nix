{ config, pkgs, nixgl, ... }:

let
  dotfilesDir = builtins.toString ./..;
  wrap = config.lib.nixGL.wrap;
  wrappedChrome = wrap pkgs.google-chrome;
  wrappedDiscord = wrap pkgs.discord;
  wrappedFirefox = wrap pkgs.firefox;
  wrappedGhostty = wrap pkgs.ghostty;
  wrappedSignal = wrap pkgs.signal-desktop;
in
{
  targets.genericLinux.nixGL.packages = nixgl.packages;

  home.packages = with pkgs; [
    dropbox
    hack-font
    keepassxc
    wrappedChrome
    wrappedDiscord
    wrappedFirefox
    wrappedGhostty
    wrappedSignal
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
    mimeType = [ "text/html" "text/xml" "application/xhtml+xml" "x-scheme-handler/http" "x-scheme-handler/https" ];
  };

  # Hide the original unwrapped .desktop files from the google-chrome package
  xdg.desktopEntries."com.google.Chrome" = {
    name = "Google Chrome (unwrapped)";
    exec = "false";
    noDisplay = true;
  };

  fonts.fontconfig.enable = true;
}
