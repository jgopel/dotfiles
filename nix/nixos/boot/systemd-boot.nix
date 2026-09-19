{ lib, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = lib.mkDefault 10;
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;
}
