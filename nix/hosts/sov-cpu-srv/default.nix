{ den, repoRoot, ... }:

{
  den = {
    homes.x86_64-linux."jonathan@sov-cpu-srv".nixInstallation = "multi-user";
    aspects."jonathan@sov-cpu-srv" = {
      includes = [
        den.aspects.nascent
        den.aspects.server
        (den.aspects.bazel { outputUserRoot = "/datapool/jonathan/bazel"; })
        (den.aspects.syncthing {
          category = "personal";
          path = "~/personal";
          stignore = repoRoot + /syncthing/personal/stignore;
        })
      ];
      homeManager.home.stateVersion = "26.05";
    };
  };
}
