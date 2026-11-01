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
        den.aspects.ghostty
        (den.aspects.hyprland { settingsFile = noctaliaSettingsFile; })
      ];

      nixos = { lib, ... }: {
        services.xserver.xkb = {
          layout = lib.mkDefault "us";
          variant = lib.mkDefault "";
        };
      };
    };
}
