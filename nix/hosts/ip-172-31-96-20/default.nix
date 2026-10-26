{ den, ... }:

{
  den = {
    homes.x86_64-linux."jonathan@ip-172-31-96-20" = { };
    aspects."jonathan@ip-172-31-96-20" = {
      includes = [
        den.aspects.server
        (den.aspects.syncthing {
          category = "nascent";
          path = "~/work";
          stignore = ../../../syncthing/work/nascent/stignore;
        })
      ];
      homeManager.imports = [ ./home.nix ];
    };
  };
}
