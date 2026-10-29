{ den, repoRoot, ... }:

{
  den = {
    hosts.x86_64-linux.XPS-17-9720 = { };
    homes.x86_64-linux."jonathan@XPS-17-9720".nixInstallation = "nixos";

    aspects = {
      XPS-17-9720 = {
        includes = [
          den.aspects.canopy-desk
          den.aspects.hyprland-testing
        ];
        nixos.imports = [ ./configuration.nix ];
      };
      "jonathan@XPS-17-9720" = {
        includes = [
          (den.aspects.canopy-desk {
            noctaliaSettingsFile = ./noctalia/settings.toml;
            arctisSettings = {
              fallbackOutput = "alsa_output.pci-0000_00_1f.3-platform-sof_sdw.HiFi__Speaker__sink";
              fallbackInput = "alsa_input.usb-046d_Logitech_BRIO_5BDF971A-03.iec958-stereo";
            };
          })
          (den.aspects.syncthing {
            category = "personal";
            path = "~/personal";
            stignore = repoRoot + /syncthing/personal/stignore;
          })
        ];
        homeManager.imports = [ ./home.nix ];
      };
    };
  };
}
