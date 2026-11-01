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
        den.aspects.firefox
        den.aspects.ghostty
        den.aspects.gnome
        (den.aspects.hyprland { settingsFile = noctaliaSettingsFile; })
        den.aspects.pipewire
        den.aspects.signal
        den.aspects.slack
      ];

      nixos = { lib, ... }: {
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

      homeManager = { pkgs, ... }: {
        home.packages = with pkgs; [
          discord
          dropbox
          google-chrome
          hack-font
          keepassxc
        ];

        fonts.fontconfig.enable = true;
      };
    };
}
