{ den, repoRoot, ... }:

{
  den.aspects.jonathan.nascent = {
    includes = [
      den.aspects.nix.nascent
      (den.aspects.syncthing {
        category = "nascent";
        path = "~/work";
        stignore = repoRoot + /syncthing/work/nascent/stignore;
      })
    ];

    desktop = {
      includes = [
        den.aspects.jonathan.nascent
        den.aspects.ssh.nascent
      ];

      provides.to-hosts.darwin.homebrew.casks = [
        "microsoft-teams"
        "telegram"
        "zoom"
      ];

      hmLinux =
        { config, pkgs, ... }:
        let
          telegram = config.lib.nixGL.wrap pkgs.telegram-desktop;
        in
        {
          home.packages = [
            telegram
            (config.lib.nixGL.wrap pkgs.teams-for-linux)
            (config.lib.nixGL.wrap pkgs.zoom-us)
          ];
          home.file.".local/share/dbus-1/services/org.telegram.desktop.service".text = ''
            [D-BUS Service]
            Name=org.telegram.desktop
            Exec=${telegram}/bin/Telegram
          '';
        };
    };
  };
}
