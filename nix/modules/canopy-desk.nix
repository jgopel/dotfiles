{ den, ... }:

{
  den.aspects.canopy-desk.__functor =
    _:
    {
      noctaliaSettingsFile ? null,
      arctisSettings ? { },
    }:
    {
      name = "canopy-desk";
      includes = [
        (den.aspects.desktop { inherit noctaliaSettingsFile; })
        (den.aspects.arctis-sound-manager arctisSettings)
      ];

      nixos = { config, lib, ... }: {
        hardware.openrazer = {
          enable = true;
          users = lib.attrNames (lib.filterAttrs (_: user: user.isNormalUser) config.users.users);
        };
      };
    };
}
