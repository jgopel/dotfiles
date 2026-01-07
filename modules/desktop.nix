{ config, pkgs, ... }:

let
  dotfilesDir = builtins.toString ./..;
in
{
  home.packages = with pkgs; [
    hack-font
    ghostty
  ];

  xdg.configFile."ghostty/config".source = "${dotfilesDir}/ghostty/config";

  fonts.fontconfig.enable = true;
}
