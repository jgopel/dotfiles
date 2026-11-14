{ den, ... }:

{
  den = {
    hosts.x86_64-linux.XPS-17-9720.users.jonathan = { };
    homes.x86_64-linux."jonathan@XPS-17-9720".nixInstallation = "nixos";

    aspects = {
      XPS-17-9720 = {
        includes = [
          den.aspects.hyprland-testing
          (den.aspects.caps-escape-swap { builtInIds = [ "0001:0001" ]; })
        ];
        nixos = {
          imports = [
            ./hardware-configuration.nix
            ./suspend-tracing.nix
            ../../kernel-testing/suspend-diagnostics.nix
            ../../kernel-testing/atlantic-resume-removal-repro.nix
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
          (den.aspects.jonathan.desktop { noctaliaSettingsFile = ./noctalia/settings.toml; })
          den.aspects.jonathan.agents
          den.aspects.jonathan.dev
          den.aspects.jonathan.personal
          den.aspects.jonathan.personal-sync
          (den.aspects.canopy-desk {
            arctisSettings = {
              fallbackOutput = "alsa_output.pci-0000_00_1f.3-platform-sof_sdw.HiFi__Speaker__sink";
              fallbackInput = "alsa_input.usb-046d_Logitech_BRIO_5BDF971A-03.iec958-stereo";
            };
          })
        ];
        homeManager = {
          home.stateVersion = "26.05";
          programs.btop.settings.selected_battery = "BAT0";
          programs.onepassword.account = {
            url = "https://sovereign-trading.1password.com";
            secrets.OPENROUTER_API_KEY = "op://Employee/env-openrouter/credential";
          };
          services.syncthing-user.tunnels = [
            {
              name = "mnemosyne-guest";
              host = "mnemosyne-guest";
              localPort = 8385;
            }
          ];
        };
      };
    };
  };
}
