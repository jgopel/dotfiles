{ den, ... }:

{
  den.aspects.desktop.__functor =
    _:
    {
      noctaliaSettingsFile ? null,
    }:
    {
      name = "desktop";
      includes = [
        den.aspects.gnome
        (den.aspects.hyprland { settingsFile = noctaliaSettingsFile; })
        den.aspects.pipewire
      ];

      provides.to-hosts.nixos = { lib, ... }: {
        networking.networkmanager.enable = true;

        services = {
          avahi.nssmdns4 = true;
          fwupd.enable = true;
          xserver.xkb = {
            layout = lib.mkDefault "us";
            variant = lib.mkDefault "";
          };
        };
      };

      homeManager.fonts.fontconfig.enable = true;
    };
}
