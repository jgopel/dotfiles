{ den, ... }:

{
  den = {
    homes.x86_64-linux."jonathan@sov-cpu-srv" = { };
    aspects."jonathan@sov-cpu-srv" = {
      includes = [
        den.aspects.server
        (den.aspects.syncthing {
          category = "nascent";
          path = "~/work";
          stignore = ../../../syncthing/work/nascent/stignore;
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
}
