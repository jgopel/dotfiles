{ config, pkgs, ... }:

let
  wrap = config.lib.nixGL.wrap;
  wrappedSlack = wrap pkgs.slack;
  wrappedTelegram = wrap pkgs.telegram-desktop;

  # Zoom's bwrap sandbox breaks desktop integration on non-NixOS systems
  # because it replaces /usr/share with Nix FHS content, hiding host gsettings schemas.
  # We override buildFHSEnv to inject extra bwrap args for host schema access.
  zoomWithFixes = pkgs.zoom-us.override {
    buildFHSEnv = args: pkgs.buildFHSEnv (args // {
      extraBwrapArgs = (args.extraBwrapArgs or []) ++ [
        "--ro-bind /usr/share/glib-2.0/schemas /usr/share/glib-2.0/schemas"
        "--setenv GSETTINGS_SCHEMA_DIR /usr/share/glib-2.0/schemas"
        "--setenv QT_XCB_GL_INTEGRATION none"
      ];
    });
  };

  wrappedZoom = wrap zoomWithFixes;
in
{
  home.packages = [
    wrappedSlack
    wrappedTelegram
    wrappedZoom
  ];

  home.file.".local/share/dbus-1/services/org.telegram.desktop.service".text = ''
    [D-BUS Service]
    Name=org.telegram.desktop
    Exec=${wrappedTelegram}/bin/Telegram
  '';
}
