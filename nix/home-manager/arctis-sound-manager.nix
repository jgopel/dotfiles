{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.arctis-settings;
  preferences = import ./arctis-settings.nix { inherit (cfg) fallbackOutput fallbackInput; };
  applySettings = pkgs.writeShellScript "apply-arctis-settings" ''
    set -e
    ${lib.concatMapAttrsStringSep "\n" (
      name: contents:
      let
        source = pkgs.writeText (builtins.baseNameOf name) contents;
        destination = "${config.xdg.configHome}/arctis_manager/${name}";
      in
      ''
        ${pkgs.coreutils}/bin/install -Dm600 \
          ${source} \
          ${lib.escapeShellArg destination}
      ''
    ) preferences}
  '';

  openArctisManager = pkgs.writeShellApplication {
    name = "open-arctis-manager";
    runtimeInputs = with pkgs; [
      gawk
      jq
      libnotify
      socat
      systemd
    ];
    text = ''
      readonly unit="app-ArctisManager.service"
      tray_bus_name=""
      tray_object_path=""

      find_tray_item() {
        local bus_names item item_bus_name item_pid main_pid

        main_pid="$(systemctl --user show --property MainPID --value "$unit")"
        if [[ -z "$main_pid" || "$main_pid" == "0" ]]; then
          return 1
        fi

        bus_names="$(busctl --user list --no-legend --no-pager)"
        while IFS= read -r item; do
          item_bus_name="''${item%%@*}"
          tray_object_path="''${item#*@}"
          item_pid="$(awk -v name="$item_bus_name" '$1 == name { print $2; exit }' <<< "$bus_names")"
          if [[ "$item_pid" == "$main_pid" ]]; then
            tray_bus_name="$item_bus_name"
            return 0
          fi
        done < <(
          busctl --user --json=short get-property \
            org.kde.StatusNotifierWatcher \
            /StatusNotifierWatcher \
            org.kde.StatusNotifierWatcher \
            RegisteredStatusNotifierItems 2>/dev/null \
            | jq -r '.data[]'
        )

        return 1
      }

      systemctl --user start "$unit"

      for _ in {1..50}; do
        if find_tray_item; then
          if [[ -n "''${1:-}" ]] \
            && printf 'url:%s' "$1" \
              | socat -u STDIN UNIX-CONNECT:/tmp/ArctisManagerGui 2>/dev/null
          then
            exit 0
          fi

          busctl --user --timeout=1s call \
            "$tray_bus_name" \
            "$tray_object_path" \
            org.kde.StatusNotifierItem \
            Activate ii 0 0
          exit 0
        fi
        sleep 0.1
      done

      message="The Arctis Sound Manager tray did not become available."
      printf '%s\n' "$message" >&2
      notify-send "Arctis Sound Manager" "$message" || true
      exit 1
    '';
  };
in
{
  options.services.arctis-settings = {
    fallbackOutput = lib.mkOption {
      type = lib.types.nonEmptyStr;
      description = "PipeWire sink node.name used when the headset disconnects and for external output routes.";
    };
    fallbackInput = lib.mkOption {
      type = lib.types.nonEmptyStr;
      description = "PipeWire source node.name used as the alternative to the headset microphone.";
    };
  };

  config = {
    xdg = {
      # ASM rewrites settings, so copy them before startup instead of symlinking.
      # After a Home Manager switch, apply with:
      #   systemctl --user restart arctis-manager.service
      configFile = {
        "systemd/user/arctis-manager.service.d/settings.conf".text = ''
          [Service]
          ExecStartPre=${applySettings}
        '';

        # The router already starts After=arctis-manager.service. Stop its
        # background route writer during the copy, then restart it with the daemon.
        # Leave the GUI running: its shutdown handler stops the audio services.
        "systemd/user/arctis-video-router.service.d/settings.conf".text = ''
          [Unit]
          PartOf=arctis-manager.service
        '';
      };

      # Override the package's launcher so opening the app activates the
      # Nix-managed login tray instead of starting another GUI process.
      desktopEntries.ArctisManager = {
        name = "Arctis Sound Manager";
        exec = "${openArctisManager}/bin/open-arctis-manager %u";
        icon = "arctis-manager";
        terminal = false;
        categories = [
          "AudioVideo"
          "Audio"
          "Utility"
        ];
        mimeType = [ "x-scheme-handler/arctis-asm" ];
      };
    };
  };
}
