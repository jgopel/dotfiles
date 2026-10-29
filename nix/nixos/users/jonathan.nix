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
}
