{
  imports = [
    ../common.nix
    ../gnome.nix
    ../audio.nix
    ../keyboard.nix
    ../hyprland-testing.nix
  ];

  hardware.openrazer.enable = true;

  programs.hyprland.enable = true;

  networking.networkmanager.enable = true;
  services.avahi.nssmdns4 = true;
  services.fwupd.enable = true;
}
