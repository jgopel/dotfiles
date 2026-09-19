{ lib, pkgs, ... }:

let
  nixpkgsAlwaysShowWorkspaceThumbnails = pkgs.gnomeExtensions.always-show-workspace-thumbnails;
  alwaysShowWorkspaceThumbnails =
    if lib.versionAtLeast nixpkgsAlwaysShowWorkspaceThumbnails.version "12" then
      nixpkgsAlwaysShowWorkspaceThumbnails
    else
      nixpkgsAlwaysShowWorkspaceThumbnails.overrideAttrs (_: {
        version = "12";
        src = pkgs.fetchFromGitHub {
          owner = "AlynxZhou";
          repo = "gnome-shell-extension-always-show-workspace-thumbnails";
          rev = "63f1284a7e1b87c456008d960dc2435ad99e35a8";
          hash = "sha256-eQJTOsQW5505tvHw5G7LR85/RZg4x+LiuQCBqJXqpg4=";
        };
      });
in
{
  programs.gnome-shell.extensions = [ { package = alwaysShowWorkspaceThumbnails; } ];
}
