{ den, ... }:

{
  den = {
    homes.x86_64-linux."jonathan@ip-172-31-96-20".nixInstallation = "multi-user";
    aspects."jonathan@ip-172-31-96-20" = {
      includes = [
        den.aspects.jonathan.nascent
        den.aspects.server
      ];
      homeManager.home.stateVersion = "26.05";
    };
  };
}
