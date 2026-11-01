{ den, repoRoot, ... }:

{
  den.aspects.jonathan.nascent.includes = [
    den.aspects.nix.nascent
    (den.aspects.syncthing {
      category = "nascent";
      path = "~/work";
      stignore = repoRoot + /syncthing/work/nascent/stignore;
    })
    (den.lib.policy.when ({ hasAspect, ... }: hasAspect den.aspects.jonathan.desktop) {
      includes = [ den.aspects.ssh.nascent ];

      homeManager =
        { config, pkgs, ... }:
        let
          telegram = config.lib.nixGL.wrap pkgs.telegram-desktop;
        in
        {
          home.packages = [ telegram ];
          home.file.".local/share/dbus-1/services/org.telegram.desktop.service".text = ''
            [D-BUS Service]
            Name=org.telegram.desktop
            Exec=${telegram}/bin/Telegram
          '';
        };
    })
  ];
}
