{ den, ... }:

{
  den.aspects.desktop.__functor = _: { noctaliaSettingsFile }: {
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

      hardware.bluetooth.enable = true;
      networking.networkmanager.enable = true;

      services = {
        automatic-timezoned.enable = true;
        fwupd.enable = true;
        xserver.xkb = {
          layout = lib.mkDefault "us";
          variant = lib.mkDefault "";
        };
      };
    };

    # Control NetworkManager without polkit admin prompts.
    user.extraGroups = [ "networkmanager" ];

    homeManager.fonts.fontconfig.enable = true;
  };
}
