{
  den.aspects.cachix = {
    homeManager = { config, pkgs, ... }: {
      home.packages = [ pkgs.cachix ];
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
