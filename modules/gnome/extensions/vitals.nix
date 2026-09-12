{ lib, pkgs, ... }:

let
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
  programs.gnome-shell.extensions = [ { package = vitals; } ];

  dconf.settings."org/gnome/shell/extensions/vitals" = {
    hot-sensors = [
      "_processor_usage_"
      "_memory_usage_"
      "__network-rx_max__"
      "__network-tx_max__"
    ];
    position-in-panel = 0;
    show-memory = true;
  };
}
