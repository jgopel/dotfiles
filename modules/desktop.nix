{ config, pkgs, nixgl, ... }:

let
  dotfilesDir = builtins.toString ./..;
  wrap = config.lib.nixGL.wrap;
  wrappedDiscord = wrap pkgs.discord;
  wrappedFirefox = wrap pkgs.firefox;
  wrappedGhostty = wrap pkgs.ghostty;
  wrappedSignal = wrap pkgs.signal-desktop;
in
{
  targets.genericLinux.nixGL.packages = nixgl.packages;

  home.packages = with pkgs; [
    dropbox
    google-chrome
    hack-font
    keepassxc
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

  fonts.fontconfig.enable = true;
}
