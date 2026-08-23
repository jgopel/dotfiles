{ lib, pkgs, ... }:

let
  nixpkgsAlwaysShowWorkspaceThumbnails =
    pkgs.gnomeExtensions.always-show-workspace-thumbnails;
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
  emptyStringArray = lib.hm.gvariant.mkEmptyArray lib.hm.gvariant.type.string;
  nixpkgsVitals = pkgs.gnomeExtensions.vitals;
  vitals =
    if lib.versionAtLeast nixpkgsVitals.version "82" then
      nixpkgsVitals
    else
      nixpkgsVitals.overrideAttrs (_: {
        version = "82.0.4";
        src = pkgs.fetchzip {
          url = "https://extensions.gnome.org/extension-data/VitalsCoreCoding.com.v82.shell-extension.zip";
          hash = "sha256-oTnIn9OL5xdIgvgNsUEmRaEGJGBMTrZuZkelpZrgVV0=";
          stripRoot = false;
        };
        patches = [ ];
        postPatch = ''
          substituteInPlace sensors.js \
            --replace-fail \
              "import * as FileModule from './helpers/file.js';" \
              "import * as FileModule from './helpers/file.js';

          imports.gi.GIRepository.Repository.dup_default().prepend_search_path('${pkgs.libgtop}/lib/girepository-1.0');"
        '';
      });
in
{
  imports = [ ./desktop-common.nix ];

  home.packages = with pkgs; [
    discord
    firefox
    ghostty
    google-chrome
    polychromatic
    signal-desktop
    slack
  ];

  programs.gnome-shell = {
    enable = true;
    extensions = [
      { package = pkgs.gnomeExtensions.tactile; }
      { package = vitals; }
      { package = alwaysShowWorkspaceThumbnails; }
      { package = pkgs.gnomeExtensions.appindicator; }
    ];
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      clock-format = "12h";
      show-battery-percentage = true;
    };

    "org/gnome/nautilus/preferences".sort-directories-first = true;

    "org/gtk/gtk4/settings/file-chooser".sort-directories-first = true;
    "org/gtk/settings/file-chooser".sort-directories-first = true;

    "org/gnome/shell/extensions/tactile" = {
      border-size = 2;
      col-3 = 0;
      gap-size = 0;
      layout-1 = emptyStringArray;
      layout-2 = emptyStringArray;
      layout-3 = emptyStringArray;
      layout-4 = emptyStringArray;
      next-monitor = emptyStringArray;
      prev-monitor = emptyStringArray;
      show-settings = emptyStringArray;
      text-size = 80;
      tile-0-0 = [ "u" ];
      tile-0-1 = [ "j" ];
      tile-0-2 = [ "m" ];
      tile-1-0 = [ "i" ];
      tile-1-1 = [ "k" ];
      tile-1-2 = [ "comma" ];
      tile-2-0 = [ "o" ];
      tile-2-1 = [ "l" ];
      tile-2-2 = [ "period" ];
      tile-3-0 = [ "p" ];
      tile-3-1 = [ "semicolon" ];
      tile-3-2 = [ "slash" ];
    };

    "org/gnome/shell/extensions/vitals" = {
      hot-sensors = [
        "_processor_usage_"
        "_memory_usage_"
        "__network-rx_max__"
        "__network-tx_max__"
      ];
      position-in-panel = 0;
      show-memory = true;
    };
  };

  xdg.configFile = {
    "autostart/dropbox.desktop" = {
      source = "${pkgs.dropbox}/share/applications/dropbox.desktop";
      force = true;
    };
    "autostart/discord.desktop" = {
      source = "${pkgs.discord}/share/applications/discord.desktop";
      force = true;
    };
    "autostart/steam.desktop" = {
      source = "${pkgs.steam-unwrapped}/share/applications/steam.desktop";
      force = true;
    };
    "autostart/slack.desktop" = {
      source = "${pkgs.slack}/share/applications/slack.desktop";
      force = true;
    };
    "autostart/signal.desktop" = {
      source = "${pkgs.signal-desktop}/share/applications/signal.desktop";
      force = true;
    };
  };
}
