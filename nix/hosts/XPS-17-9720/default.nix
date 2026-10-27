{ den, ... }:

{
  den = {
    hosts.x86_64-linux.XPS-17-9720 = { };
    homes.x86_64-linux."jonathan@XPS-17-9720" = { };

    aspects = {
      XPS-17-9720.nixos.imports = [ ./configuration.nix ];
      "jonathan@XPS-17-9720" = {
        includes = [
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
