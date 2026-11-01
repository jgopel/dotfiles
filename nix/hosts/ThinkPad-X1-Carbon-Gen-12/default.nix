{ den, ... }:

{
  den = {
    hosts.x86_64-linux.ThinkPad-X1-Carbon-Gen-12.users.jonathan = { };
    homes.x86_64-linux."jonathan@ThinkPad-X1-Carbon-Gen-12".nixInstallation = "nixos";

    aspects = {
      ThinkPad-X1-Carbon-Gen-12 = {
        includes = [
          den.aspects.boot-nixos-first
          den.aspects.hyprland-testing
          (den.aspects.caps-escape-swap { builtInIds = [ "0001:0001" ]; })
        ];
        nixos = { pkgs, ... }: {
          imports = [
            ./hardware-configuration.nix
            ../../kernel-testing/thunderbolt.nix
          ];

          hardware.graphics.extraPackages = [ pkgs.intel-media-driver ];

          networking.hostName = "ThinkPad-X1-Carbon-Gen-12";
          system.stateVersion = "26.05";

          # After resume, DNS waits on Tailscale's resolvers exhaust nsncd's
          # eight shared NSS workers, starving local account lookups despite
          # authentication needing no DNS. Observed as ~10s Noctalia
          # "Authorizing" delays and resume UI stalls; nsncd hits its 10s
          # handoff timeout and restarts. Reserve more headroom for account
          # lookups: 32 workers mitigate the measured burst, but do not isolate
          # authentication from DNS or fix the underlying resolver delay.
          systemd.services.nscd.environment.NSNCD_WORKER_COUNT = "32";
        };
      };
      "jonathan@ThinkPad-X1-Carbon-Gen-12" = {
        includes = [
          (den.aspects.jonathan.desktop { noctaliaSettingsFile = ./noctalia/settings.toml; })
          den.aspects.jonathan.nascent
          den.aspects.jonathan.personal-sync
          (den.aspects.canopy-desk {
            arctisSettings = {
              fallbackOutput = "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Speaker__sink";
              fallbackInput = "alsa_input.usb-046d_Logitech_BRIO_5BDF971A-03.analog-stereo";
            };
          })
        ];
        homeManager = {
          home.stateVersion = "26.05";
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
