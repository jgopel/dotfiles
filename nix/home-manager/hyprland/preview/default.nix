{ pkgs, inputs, ... }:

let
  desktop = pkgs.callPackage ../package.nix { inherit inputs; };
  sharedSettings = pkgs.lib.recursiveUpdate (import ../../noctalia/settings.nix { inherit inputs; }) (
    builtins.fromTOML (builtins.readFile ../../../../noctalia/settings.toml)
  );
  settings = pkgs.lib.recursiveUpdate sharedSettings {
    shell = {
      polkit_agent = false;
      launch_apps_as_systemd_services = false;
      offline_mode = true;
      session.actions = [ ];
    };
    lockscreen.enabled = false;
    idle.behavior = {
      lock.enabled = false;
      screen-off.enabled = false;
    };
  };
  shellConfig = (pkgs.formats.toml { }).generate "noctalia-preview.toml" settings;
  # No activation directories: do not start desktop services on the private bus.
  busConfig = pkgs.writeText "hyprland-preview-dbus.conf" ''
    <!DOCTYPE busconfig PUBLIC "-//freedesktop//DTD D-Bus Bus Configuration 1.0//EN"
      "http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd">
    <busconfig>
      <type>session</type>
      <listen>unix:tmpdir=/tmp</listen>
      <auth>EXTERNAL</auth>
      <policy context="default">
        <allow send_destination="*"/>
        <allow receive_sender="*"/>
        <allow own="*"/>
      </policy>
    </busconfig>
  '';
in
pkgs.writeShellApplication {
  name = "hyprland-preview";
  runtimeInputs = with pkgs; [
    desktop.noctalia
    hyprland
    ghostty
    lua5_5
    dbus
    util-linux
    procps
    coreutils
  ];
  text = ''
    export HYPRLAND_SHARED_CONFIG=${desktop.config}
    export HYPRLAND_PREVIEW_CONFIG=${./overlay.lua}
    export HYPRLAND_PREVIEW_SHELL_CONFIG=${shellConfig}
    export HYPRLAND_DBUS_CONFIG=${busConfig}
    export XCURSOR_PATH=${pkgs.adwaita-icon-theme}/share/icons
    export XCURSOR_THEME=Adwaita XCURSOR_SIZE=24
    ${builtins.readFile ./preview.sh}
  '';
  meta = {
    description = "Opt-in nested Hyprland with an isolated Noctalia session";
    license = pkgs.lib.licenses.mit;
    platforms = pkgs.lib.platforms.linux;
  };
}
