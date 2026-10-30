{ den, ... }:

{
  den = {
    homes.x86_64-linux."jonathan@ip-172-31-2-254".nixInstallation = "multi-user";
    aspects."jonathan@ip-172-31-2-254" = {
      includes = [
        den.aspects.nascent
        den.aspects.server
      ];
      homeManager.home.stateVersion = "26.05";
    };
  };
}
