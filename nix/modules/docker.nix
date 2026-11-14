{
  den.aspects.docker = {
    provides.to-hosts.nixos = { config, lib, ... }: {
      virtualisation.docker.enable = true;
      # Docker group membership grants root-equivalent access via the root-owned daemon.
      users.groups.docker.members = lib.attrNames (
        lib.filterAttrs (_: user: user.isNormalUser) config.users.users
      );
    };

    homeManager =
      { pkgs, ... }:
      let
        dockerGc = pkgs.writeShellApplication {
          name = "docker-gc";
          runtimeInputs = [ pkgs.docker-client ];
          text = ''
            docker container prune --force --filter "until=$((14*24))h"
            docker image prune --all --force --filter "until=$((14*24))h"
            docker network prune --force --filter "until=$((14*24))h"
            docker volume prune --all --force
          '';
        };
      in
      {
        home.packages = [ pkgs.docker-client ];

        systemd.user.services.docker-gc = {
          Unit.Description = "Prune unused Docker resources";
          Service = {
            Type = "oneshot";
            ExecStart = "${dockerGc}/bin/docker-gc";
          };
        };

        systemd.user.timers.docker-gc = {
          Unit.Description = "Daily Docker garbage collection";
          Timer = {
            OnCalendar = "daily";
            Persistent = true;
          };
          Install.WantedBy = [ "timers.target" ];
        };
      };
  };
}
