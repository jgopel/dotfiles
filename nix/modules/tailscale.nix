{
  den.aspects.tailscale = {
    nixos.services.tailscale.enable = true;
    homeManager = { pkgs, ... }: { home.packages = [ pkgs.tailscale ]; };
  };
}
