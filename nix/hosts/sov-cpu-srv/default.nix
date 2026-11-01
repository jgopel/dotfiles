{ den, ... }:

{
  den = {
    homes.x86_64-linux."jonathan@sov-cpu-srv".nixInstallation = "multi-user";
    aspects."jonathan@sov-cpu-srv" = {
      includes = [
        den.aspects.jonathan.nascent
        den.aspects.server
        den.aspects.jonathan.personal-sync
        (den.aspects.bazel { outputUserRoot = "/datapool/jonathan/bazel"; })
      ];
      homeManager.home.stateVersion = "26.05";
    };
  };
}
