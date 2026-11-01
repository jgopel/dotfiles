{ config, pkgs, ... }:

let
  wrap = config.lib.nixGL.wrap;
  wrappedTelegram = wrap pkgs.telegram-desktop;
in
{
  home.packages = [ wrappedTelegram ];

  home.file.".local/share/dbus-1/services/org.telegram.desktop.service".text = ''
    [D-BUS Service]
    Name=org.telegram.desktop
    Exec=${wrappedTelegram}/bin/Telegram
  '';
}
