{ config, lib, ... }:

let
  cfg = config.services.syncthing-user;
in
{
  imports = [ ../syncthing.nix ];

  options.services.syncthing-user.nascent-tunnels = lib.mkEnableOption "SSH tunnels to Nascent syncthing servers";

  config.services.syncthing-user = {
    enable = true;
    clusters = [ "nascent" ];
    folders = [
      {
        path = "~/work";
        stignore = ../../../syncthing/stignore-nascent-work;
      }
    ];
    tunnels = lib.mkIf cfg.nascent-tunnels [
      {
        name = "sov-cpu-srv";
        host = "sov-cpu-srv";
        localPort = 8385;
      }
      {
        name = "platform-tokyo-dev";
        host = "platform-tokyo-dev";
        localPort = 8386;
      }
      {
        name = "shared-ib-fix-dev";
        host = "shared-ib-fix-dev";
        localPort = 8387;
      }
    ];
  };
}
