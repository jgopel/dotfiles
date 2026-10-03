{
  imports = [
    ../../home-manager/common.nix
    ../../home-manager/desktop-nixos.nix
    ../../home-manager/arctis-sound-manager.nix
    ../../home-manager/nascent-desktop.nix
    ../../home-manager/ssh-nascent.nix
    ../../home-manager/syncthing/nascent.nix
    ../../home-manager/syncthing/personal.nix
  ];

  home.username = "jonathan";
  home.homeDirectory = "/home/jonathan";

  services.syncthing-user.nascent-tunnels = true;

  # Steam is not enabled on this host.
  xdg.configFile."autostart/steam.desktop".enable = false;
}
