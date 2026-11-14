{ pkgs, ... }:

{
  programs.gnome-shell.extensions = [ { package = pkgs.gnomeExtensions.vitals; } ];

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
