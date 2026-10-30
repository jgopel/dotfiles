{
  den.aspects.cachix = {
    homeManager = { config, pkgs, ... }: {
      home.packages = [ pkgs.cachix ];
      home.activation.cacheHome = config.lib.dag.entryAfter [ "installPackages" ] ''
        if ! run ${pkgs.cachix}/bin/cachix push jonathan "$newGenPath"; then
          echo "WARNING: Home Manager cache upload failed; continuing activation. Configure Cachix credentials with a write-capable token and check connectivity." >&2
        fi
      '';
    };
  };
}
