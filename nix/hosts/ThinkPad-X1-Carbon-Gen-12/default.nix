{ den, ... }:

{
  den = {
    hosts.x86_64-linux.ThinkPad-X1-Carbon-Gen-12 = { };
    homes.x86_64-linux."jonathan@ThinkPad-X1-Carbon-Gen-12" = { };

    aspects = {
      ThinkPad-X1-Carbon-Gen-12.nixos.imports = [ ./configuration.nix ];
      "jonathan@ThinkPad-X1-Carbon-Gen-12" = {
        includes = [
          (den.aspects.syncthing {
            category = "nascent";
            path = "~/work";
            stignore = ../../../syncthing/work/nascent/stignore;
            tunnels = [
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
          })
          (den.aspects.syncthing {
            category = "personal";
            path = "~/personal";
            stignore = ../../../syncthing/personal/stignore;
          })
        ];
        homeManager.imports = [ ./home.nix ];
      };
    };
  };
}
