{ den, ... }:

{
  den = {
    hosts.x86_64-linux.XPS-17-9720 = { };
    homes.x86_64-linux."jonathan@XPS-17-9720" = { };

    aspects = {
      XPS-17-9720 = {
        includes = [
          den.aspects.desktop
          den.aspects.hyprland-testing
        ];
        nixos.imports = [ ./configuration.nix ];
      };
      "jonathan@XPS-17-9720" = {
        includes = [
          (den.aspects.desktop { noctaliaSettingsFile = ./noctalia/settings.toml; })
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
