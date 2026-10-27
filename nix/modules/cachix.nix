let
  cacheSettings = {
    extra-substituters = [ "https://jonathan.cachix.org" ];
    extra-trusted-public-keys = [
      "jonathan.cachix.org-1:aCu0qEoqdLs+Qmq9udXYcB5YISRuipb0XVxlpUx0PnE="
    ];
    netrc-file = "/etc/nix/netrc";
  };
in
{
  den.aspects.cachix = {
    nixos.nix.settings = cacheSettings;

    homeManager = { config, pkgs, ... }: {
      home.packages = [ pkgs.cachix ];
      nix.settings = cacheSettings;
      systemd.user.services.cachix-watch-store = {
        Unit.Description = "Upload new Nix store paths to Jonathan's Cachix cache";
        Service = {
          ExecStart = "${pkgs.cachix}/bin/cachix watch-store jonathan";
          Environment = [ "PATH=${config.nix.package}/bin" ];
          Restart = "on-failure";
          RestartSec = 30;
        };
        Install.WantedBy = [ "default.target" ];
      };
      home.activation.cacheHome = config.lib.dag.entryAfter [ "installPackages" ] ''
        if ! run ${pkgs.cachix}/bin/cachix push jonathan "$newGenPath"; then
          echo "WARNING: Home Manager cache upload failed; continuing activation. Configure Cachix credentials with a write-capable token and check connectivity." >&2
        fi
      '';
    };
  };
}
