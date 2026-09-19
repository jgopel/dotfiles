{ lib, ... }:

{
  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = lib.mkDefault 10;
    };
    efi.canTouchEfiVariables = lib.mkDefault true;
  };
}
