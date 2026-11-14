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
        (den.aspects.hyprland { settingsFile = noctaliaSettingsFile; })
        den.aspects.pipewire
      ];

      provides.to-hosts.nixos = { lib, pkgs, ... }: {
        # Keep graphical recovery tools available without Home Manager.
        environment.systemPackages = [
          pkgs.ghostty
          pkgs.firefox
        ];

        networking.networkmanager.enable = true;

        services = {
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
