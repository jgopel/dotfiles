{ den, ... }:

{
  den = {
    hosts.aarch64-darwin.Jonathans-MacBook-Pro.users.jonathan = { };
    homes.aarch64-darwin."jonathan@Jonathans-MacBook-Pro".nixInstallation = "darwin";

    aspects = {
      Jonathans-MacBook-Pro.darwin = {
        networking.hostName = "Jonathans-MacBook-Pro";
        networking.localHostName = "Jonathans-MacBook-Pro";
        time.timeZone = "America/Denver";

        homebrew.casks = [ "steam" ];

        # Apple's socket-activated sshd still listens on port 22; only this
        # account, connecting from a Tailscale address, may authenticate.
        # Keep ~/.ssh/authorized_keys as user-owned state, including its
        # existing ThinkPad and NixOS public keys.
        services.openssh.extraConfig = ''
          AllowUsers jonathan@100.64.0.0/10 jonathan@fd7a:115c:a1e0::/48
        '';

        system = {
          primaryUser = "jonathan";
          stateVersion = 6;
          # Disable only AC idle sleep; nix-darwin's power.sleep option uses
          # pmset -a and would also change the battery policy.
          activationScripts.postActivation.text = ''
            /usr/bin/pmset -c sleep 0
          '';
        };

        # -s is AC-only. Do not use `pmset disablesleep`, which also defeats
        # battery/lid sleep when the laptop is unplugged and put in a bag.
        # Verify closed-lid/no-display SSH after activation on this hardware.
        launchd.daemons.ac-awake.serviceConfig = {
          ProgramArguments = [
            "/usr/bin/caffeinate"
            "-s"
          ];
          RunAtLoad = true;
          KeepAlive = true;
        };
      };

      "jonathan@Jonathans-MacBook-Pro" = {
        includes = [
          (den.aspects.jonathan.desktop.macos { omniwmSettingsFile = ./omniwm/settings.toml; })
          den.aspects.jonathan.agents
          den.aspects.jonathan.dev
          den.aspects.jonathan.nascent.desktop
          den.aspects.jonathan.personal-sync
          den.aspects.server
        ];

        homeManager = {
          home.stateVersion = "26.05";
          # Per-user, mode 0700, and cleared by macOS; also usable over SSH.
          home.sessionVariables.XDG_RUNTIME_DIR = "$(/usr/bin/getconf DARWIN_USER_TEMP_DIR)";
          programs.onepassword.account = {
            url = "https://sovereign-trading.1password.com";
            secrets.OPENROUTER_API_KEY = "op://Employee/env-openrouter/credential";
          };
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
          ];
        };
      };
    };
  };
}
