{
  imports = [
    ../../home-manager/common.nix
    ../../home-manager/desktop-nixos.nix
    ../../home-manager/neomutt.nix
    ../../home-manager/arctis-sound-manager.nix
    ../../home-manager/syncthing/personal.nix
  ];

  home.username = "jonathan";
  home.homeDirectory = "/home/jonathan";
}
