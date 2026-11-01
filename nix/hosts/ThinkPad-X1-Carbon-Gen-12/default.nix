{ den, repoRoot, ... }:

{
  den = {
    hosts.x86_64-linux.ThinkPad-X1-Carbon-Gen-12 = { };
    homes.x86_64-linux."jonathan@ThinkPad-X1-Carbon-Gen-12".nixInstallation = "nixos";

    aspects = {
      ThinkPad-X1-Carbon-Gen-12 = {
        includes = [
          den.aspects.canopy-desk
          den.aspects.hyprland-testing
          den.aspects.nascent
          (den.aspects.caps-escape-swap { builtInIds = [ "0001:0001" ]; })
        ];
        nixos = { pkgs, ... }: {
          imports = [
            ./configuration.nix
            ./hardware-configuration.nix
          ];

          hardware.graphics.extraPackages = [ pkgs.intel-media-driver ];

          networking.hostName = "ThinkPad-X1-Carbon-Gen-12";
          system.stateVersion = "26.05";
        };
      };
      "jonathan@ThinkPad-X1-Carbon-Gen-12" = {
        includes = [
          den.aspects.nascent
          den.aspects.ssh.nascent
          (den.aspects.canopy-desk {
            noctaliaSettingsFile = ./noctalia/settings.toml;
            arctisSettings = {
              fallbackOutput = "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Speaker__sink";
              fallbackInput = "alsa_input.usb-046d_Logitech_BRIO_5BDF971A-03.analog-stereo";
            };
          })
          (den.aspects.syncthing {
            category = "personal";
            path = "~/personal";
            stignore = repoRoot + /syncthing/personal/stignore;
          })
        ];
        homeManager = {
          imports = [ ./home.nix ];
          services.syncthing-user.tunnels = [
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
        };
      };
    };
  };
}
