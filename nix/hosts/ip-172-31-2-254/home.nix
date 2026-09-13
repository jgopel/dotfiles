{
  imports = [
    ../../home-manager/common.nix
    ../../home-manager/bash-standalone.nix
    ../../home-manager/server.nix
    ../../home-manager/syncthing-nascent.nix
  ];

  home.username = "jonathan";
  home.homeDirectory = "/home/jonathan";
}
