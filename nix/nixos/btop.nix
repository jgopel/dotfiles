{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.btop ];

  security.wrappers.btop = {
    owner = "root";
    group = "root";
    source = "${pkgs.btop}/bin/btop";
    capabilities = "cap_perfmon+ep cap_dac_read_search+ep";
  };
}
