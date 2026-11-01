{
  den.aspects.tailscale = {
    provides.to-hosts.nixos.services.tailscale.enable = true;
    homeManager = { pkgs, ... }: { home.packages = [ pkgs.tailscale ]; };
  };
}
