{ den, ... }:

{
  den.aspects.canopy-desk.__functor = _: { arctisSettings }: {
    name = "canopy-desk";
    includes = [ (den.aspects.arctis-sound-manager arctisSettings) ];

    provides.to-hosts.nixos =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        boot.kernelPackages = lib.mkOverride 900 pkgs.linuxPackages_latest;

        assertions = [
          {
            # Nix recognizes "pre", but not "rc", as older than the final release.
            assertion = lib.versionAtLeast (lib.replaceStrings [ "-rc" ] [ "pre" ]
              config.boot.kernelPackages.kernel.version
            ) "7.3";
            message = "Linux 7.3 or newer is required for the XHCI fixes that prevent USB devices connected through the CalDigit TS5 Plus from wedging.";
          }
        ];

        # Allow Oryx browser flashing and live training for the ZSA Moonlander.
        hardware.keyboard.zsa.enable = true;

        hardware.openrazer = {
          enable = true;
          users = lib.attrNames (lib.filterAttrs (_: user: user.isNormalUser) config.users.users);
        };
      };

    homeManager = { pkgs, ... }: { home.packages = [ pkgs.polychromatic ]; };
  };
}
