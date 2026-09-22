{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.boot.loader.systemd-boot.prioritizeNixOS =
    lib.mkEnableOption "putting NixOS first in the firmware boot order";

  config.boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = lib.mkDefault 10;

      # NOTE: This is just to change the bootloader name from "Linux Boot
      # Manager" to "NixOS Boot Manager" for clarity. It so happens that this
      # changes the bootloader order, so it needs to be saved and reloaded.
      extraInstallCommands = lib.mkIf config.boot.loader.efi.canTouchEfiVariables ''
        ${lib.optionalString (!config.boot.loader.systemd-boot.prioritizeNixOS) ''
          bootOrder="$(${pkgs.efibootmgr}/bin/efibootmgr | ${pkgs.gawk}/bin/awk '/^BootOrder:/ { print $2 }')"
          if [ -n "$bootOrder" ]; then
            trap '${pkgs.efibootmgr}/bin/efibootmgr --bootorder "$bootOrder"' EXIT
          fi
        ''}
        ${config.systemd.package}/bin/bootctl \
          --esp-path=${lib.escapeShellArg config.boot.loader.efi.efiSysMountPoint} \
          --efi-boot-option-description='NixOS Boot Manager' \
          install
      '';
    };
    efi.canTouchEfiVariables = lib.mkDefault true;
  };
}
