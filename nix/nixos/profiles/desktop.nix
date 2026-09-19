{
  imports = [
    ../common.nix
    ../gnome.nix
    ../audio.nix
    ../keyboard.nix
  ];

  hardware.openrazer.enable = true;

  networking.networkmanager.enable = true;
  services.avahi.nssmdns4 = true;
  services.fwupd.enable = true;
}
