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
        assertions = [
          {
            # Nix recognizes "pre", but not "rc", as older than the final release.
            assertion = lib.versionAtLeast (lib.replaceStrings [ "-rc" ] [ "pre" ]
              config.boot.kernelPackages.kernel.version
            ) "7.3";
            message = "Linux 7.3 or newer is required for the XHCI fixes that prevent USB devices connected through the CalDigit TS5 Plus from wedging.";
          }
        ];

        hardware.openrazer = {
          enable = true;
          users = lib.attrNames (lib.filterAttrs (_: user: user.isNormalUser) config.users.users);
        };
      };
    };
}
