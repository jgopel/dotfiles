{
  imports = [
    ../../home-manager/common.nix
    ../../home-manager/bash-standalone.nix
    ../../home-manager/desktop-standalone.nix
    ../../home-manager/nascent-desktop.nix
    ../../home-manager/syncthing-nascent.nix
  ];

  home.username = "jonathan";
  home.homeDirectory = "/home/jonathan";

  services.syncthing-user.nascent-tunnels = true;
}
