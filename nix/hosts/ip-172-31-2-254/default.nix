{ den, ... }:

{
  den = {
    homes.x86_64-linux."jonathan@ip-172-31-2-254" = { };
    aspects."jonathan@ip-172-31-2-254" = {
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
