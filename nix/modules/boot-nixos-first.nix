{
  den.aspects.boot-nixos-first.nixos = { config, lib, ... }: {
    # Give NixOS a recognizable entry and put it first in the firmware
    # boot order, not the generation list inside the boot menu.
    boot.loader.systemd-boot.extraInstallCommands = lib.mkIf config.boot.loader.efi.canTouchEfiVariables ''
      ${config.systemd.package}/bin/bootctl \
        --esp-path=${lib.escapeShellArg config.boot.loader.efi.efiSysMountPoint} \
        --efi-boot-option-description='NixOS Boot Manager' \
        install
    '';
  };
}
