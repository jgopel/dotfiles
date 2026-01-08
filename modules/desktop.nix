{ config, pkgs, nixgl, ... }:

let
  dotfilesDir = builtins.toString ./..;
  wrappedGhostty = config.lib.nixGL.wrap pkgs.ghostty;
in
{
  targets.genericLinux.nixGL.packages = nixgl.packages;

  home.packages = with pkgs; [
    hack-font
    wrappedGhostty
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
