{
  imports = [
    ../common.nix
    ../gnome.nix
    ../audio.nix
  ];

  networking.networkmanager.enable = true;
  services.avahi.nssmdns4 = true;
  services.fwupd.enable = true;
}
