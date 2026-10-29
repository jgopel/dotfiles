{
  imports = [
    ../../home-manager/common.nix
    ../../home-manager/desktop-nixos.nix
    ../../home-manager/neomutt.nix
    ../../home-manager/nascent-desktop.nix
  ];

  home.stateVersion = "26.05";

  # Steam is not enabled on this host.
  xdg.configFile."autostart/steam.desktop".enable = false;
}
