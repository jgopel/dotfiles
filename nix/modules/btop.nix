{
  den.aspects.btop = {
    provides.to-hosts.nixos = { pkgs, ... }: {
      security.wrappers.btop = {
        owner = "root";
        group = "root";
        source = "${pkgs.btop}/bin/btop";
        capabilities = "cap_perfmon+ep cap_dac_read_search+ep";
      };
    };

    homeManager.programs.btop = {
      enable = true;
      settings.update_ms = 500;
    };
  };
}
