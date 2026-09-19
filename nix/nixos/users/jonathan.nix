{
  config,
  lib,
  pkgs,
  ...
}:

{
  users.users.jonathan = {
    isNormalUser = true;
    description = "Jonathan";
    extraGroups = [ "wheel" ] ++ lib.optional config.networking.networkmanager.enable "networkmanager";
    shell = pkgs.fish;
  };

  # OpenRazer applies this membership only when its support is enabled.
  hardware.openrazer.users = [ "jonathan" ];

  programs.fish.enable = true;
}
