{
  den.aspects.mosh = {
    provides.to-hosts.nixos = { pkgs, ... }: { environment.systemPackages = [ pkgs.mosh ]; };
    homeManager = { pkgs, ... }: { home.packages = [ pkgs.mosh ]; };

    server = {
      provides.to-hosts.nixos.programs.mosh.enable = true;

      homeManager = { pkgs, ... }: {
        # Add mosh-server to PATH so SSH can spawn it.
        home.sessionPath = [ "${pkgs.mosh}/bin" ];
      };
    };
  };
}
