{ pkgs, ... }:

let
  dotfilesDir = builtins.toString ../..;
in
{
  home.packages = with pkgs; [
    dropbox
    hack-font
    keepassxc
  ];

  xdg.configFile."ghostty/config".source = "${dotfilesDir}/ghostty/config";

  fonts.fontconfig.enable = true;

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
}
