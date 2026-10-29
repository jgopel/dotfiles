{
  den.aspects.home-manager.homeManager = { config, pkgs, ... }: {
    programs.home-manager.enable = true;

    home.activation.report-changes = config.lib.dag.entryAnywhere ''
      if [[ -n "''${oldGenPath:-}" ]]; then
        ${pkgs.nvd}/bin/nvd diff "$oldGenPath" "$newGenPath" || true
      fi
    '';
  };
}
