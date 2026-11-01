{ lib, pkgs, ... }:

let
  emptyStringArray = lib.hm.gvariant.mkEmptyArray lib.hm.gvariant.type.string;
  tactile = pkgs.gnomeExtensions.tactile.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      # Reset the remembered layout only when opening a new grid.
      substituteInPlace extension/tileModal.js \
        --replace-fail \
          'this._monitor = window.get_monitor();' \
          'this._monitor = window.get_monitor(); this.saveMonitorLayout(this._monitor, 1);'
    '';
  });
in
{
  programs.gnome-shell.extensions = [ { package = tactile; } ];

  dconf.settings."org/gnome/shell/extensions/tactile" = {
    border-size = 2;
    col-3 = 0;
    gap-size = 0;
    layout-1 = [ "1" ];
    layout-2 = [ "2" ];
    layout-2-col-0 = 1;
    layout-2-col-1 = 1;
    layout-2-col-2 = 1;
    layout-2-col-3 = 1;
    layout-2-row-0 = 1;
    layout-2-row-1 = 1;
    layout-2-row-2 = 0;
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
}
