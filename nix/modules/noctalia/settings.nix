{ inputs, pkgs }:

{
  shell = {
    polkit_agent = true;
    launch_apps_as_systemd_services = true;
  };
  plugins = {
    source = [
      {
        name = "community";
        kind = "path";
        location = toString (
          pkgs.applyPatches {
            name = "noctalia-community-plugins";
            src = inputs.noctalia-plugins;
            patches = [
              ./timezone-hub.patch
              ./timezone-hub-allow-device-zone.patch
            ];
          }
        );
      }
    ];
  };
}
