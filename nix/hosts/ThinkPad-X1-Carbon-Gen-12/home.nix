{
  imports = [
    ../../home-manager/common.nix
    ../../home-manager/desktop-nixos.nix
    ../../home-manager/neomutt.nix
    ../../home-manager/nascent-desktop.nix
    ../../home-manager/ssh-nascent.nix
  ];

  # Steam is not enabled on this host.
  xdg.configFile."autostart/steam.desktop".enable = false;
}
