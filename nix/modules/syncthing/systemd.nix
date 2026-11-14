{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.syncthing-user;
  commands = import ./commands.nix { inherit pkgs; };
in
{
  config = lib.mkIf cfg.enable {
    systemd.user.services = {
      syncthing = {
        Unit = {
          Description = "Syncthing - Open Source Continuous File Synchronization";
          Documentation = "man:syncthing(1)";
          After = [ "network.target" ];
        };
        Service = {
          ExecStart = lib.concatStringsSep " " (commands.syncthing cfg.guiAddress);
          Restart = "on-failure";
          SuccessExitStatus = [
            3
            4
          ];
          RestartForceExitStatus = [
            3
            4
          ];
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    }
    // lib.listToAttrs (
      map (tunnel: {
        name = "syncthing-tunnel-${tunnel.name}";
        value = {
          Unit = {
            Description = "SSH tunnel to ${tunnel.name} syncthing GUI";
            After = [ "network.target" ];
          };
          Service = {
            ExecStart = lib.concatStringsSep " " (
              commands.tunnel {
                inherit tunnel;
                localAddress = toString tunnel.localPort;
                extraArgs = [ ];
              }
            );
            Restart = "on-failure";
            RestartSec = 5;
          };
          Install = {
            WantedBy = [ "default.target" ];
          };
        };
      }) cfg.tunnels
    );
  };
}
