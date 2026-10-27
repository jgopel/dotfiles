{ den, ... }:

{
  den = {
    hosts.x86_64-linux.ThinkPad-X1-Carbon-Gen-12 = { };
    homes.x86_64-linux."jonathan@ThinkPad-X1-Carbon-Gen-12" = { };

    aspects = {
      ThinkPad-X1-Carbon-Gen-12 = {
        includes = [
          den.aspects.canopy-desk
          den.aspects.hyprland-testing
        ];
        nixos.imports = [ ./configuration.nix ];
      };
      "jonathan@ThinkPad-X1-Carbon-Gen-12" = {
        includes = [
          (den.aspects.canopy-desk {
            noctaliaSettingsFile = ./noctalia/settings.toml;
            arctisSettings = {
              fallbackOutput = "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Speaker__sink";
              fallbackInput = "alsa_input.usb-046d_Logitech_BRIO_5BDF971A-03.analog-stereo";
            };
          })
          (den.aspects.syncthing {
            category = "nascent";
            path = "~/work";
            stignore = ../../../syncthing/work/nascent/stignore;
            tunnels = [
              {
                name = "sov-cpu-srv";
                host = "sov-cpu-srv";
                localPort = 8385;
              }
              {
                name = "platform-tokyo-dev";
                host = "platform-tokyo-dev";
                localPort = 8386;
              }
              {
                name = "shared-ib-fix-dev";
                host = "shared-ib-fix-dev";
                localPort = 8387;
              }
            ];
          })
          (den.aspects.syncthing {
            category = "personal";
            path = "~/personal";
            stignore = ../../../syncthing/personal/stignore;
          })
        ];
        homeManager.imports = [ ./home.nix ];
      };
    };
  };
}
