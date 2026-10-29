{ den, ... }:

{
  den = {
    homes.x86_64-linux."jonathan@ip-172-31-96-20".nixInstallation = "multi-user";
    aspects."jonathan@ip-172-31-96-20" = {
      includes = [
        den.aspects.nascent
        den.aspects.server
      ];
      homeManager.imports = [ ./home.nix ];
    };
  };
}
