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
          (den.aspects.caps-escape-swap { builtInIds = [ "0001:0001" ]; })
        ];
        nixos = {
          imports = [
            ./configuration.nix
            ./hardware-configuration.nix
            ./suspend-tracing.nix
            ../../kernel-testing/suspend-diagnostics.nix
            ../../kernel-testing/thunderbolt.nix
          ];

          programs.steam.enable = true;

          services = {
            xserver.videoDrivers = [ "nvidia" ];
          };

          hardware.nvidia = {
            modesetting.enable = true;
            open = true;
            powerManagement = {
              enable = true;
              kernelSuspendNotifier = true;
            };
            prime = {
              intelBusId = "PCI:0:2:0";
              nvidiaBusId = "PCI:1:0:0";
              sync.enable = true;
            };
          };

          networking.hostName = "XPS-17-9720";
          system.stateVersion = "26.05";
        };
      };
      "jonathan@XPS-17-9720" = {
        includes = [
          den.aspects.ssh.personal
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
        homeManager.home.stateVersion = "26.05";
      };
    };
  };
}
