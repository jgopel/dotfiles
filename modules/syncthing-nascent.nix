{ config, lib, ... }:

# Nascent cluster configuration for Syncthing
# Members: jonathan-ThinkPad-X1-Carbon-Gen-12, sov-cpu-srv, ip-172-31-2-254
#
# To set up the cluster:
# 1. Run `home-manager switch` on each machine
# 2. Start syncthing: `systemctl --user start syncthing`
# 3. Access GUI at http://127.0.0.1:8384 on each machine
# 4. Add devices by exchanging Device IDs (Actions > Show ID)
# 5. Add the ~/work folder in the GUI and share with cluster devices

let
  cfg = config.services.syncthing-user;
in
{
  imports = [ ./syncthing.nix ];

  options.services.syncthing-user.nascent-tunnels = lib.mkEnableOption "SSH tunnels to Nascent syncthing servers";

  config.services.syncthing-user = {
    enable = true;
    clusters = [ "nascent" ];
    folders = [
      {
        path = "~/work";
        stignore = ../syncthing/stignore-nascent-work;
      }
    ];
    tunnels = lib.mkIf cfg.nascent-tunnels [
      { name = "montreal_dev_box"; host = "montreal_dev_box"; localPort = 8385; }
      { name = "japan_dev_box"; host = "japan_dev_box"; localPort = 8386; }
      { name = "ib_fix_dev_box"; host = "ib_fix_dev_box"; localPort = 8387; }
    ];
  };
}
