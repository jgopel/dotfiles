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
    launchd.agents = {
      syncthing = {
        enable = true;
        config = {
          ProgramArguments = commands.syncthing cfg.guiAddress;
          RunAtLoad = true;
          KeepAlive = true;
          ProcessType = "Background";
          StandardOutPath = "${config.home.homeDirectory}/Library/Logs/syncthing.log";
          StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/syncthing.log";
        };
      };
    }
    // lib.listToAttrs (
      map (tunnel: {
        name = "syncthing-tunnel-${tunnel.name}";
        value = {
          enable = true;
          config = {
            ProgramArguments = [
              "${pkgs.bash}/bin/bash"
              "-c"
              ''
                # launchd does not source the interactive shell's agent setup.
                ${lib.optionalString config.sshAuthSock.enable config.sshAuthSock.initialization.bash}
                exec ${
                  lib.escapeShellArgs (
                    commands.tunnel {
                      inherit tunnel;
                      localAddress = "127.0.0.1:${toString tunnel.localPort}";
                      extraArgs = [
                        "-o"
                        "BatchMode=yes"
                      ];
                    }
                  )
                }
              ''
            ];
            EnvironmentVariables.AUTOSSH_GATETIME = "0";
            RunAtLoad = true;
            KeepAlive = true;
            ThrottleInterval = 5;
            ProcessType = "Background";
            StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/syncthing-tunnel-${tunnel.name}.log";
          };
        };
      }) cfg.tunnels
    );
  };
}
