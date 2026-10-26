{
  den.aspects.mosh = {
    nixos = { pkgs, ... }: { environment.systemPackages = [ pkgs.mosh ]; };
    homeManager = { pkgs, ... }: { home.packages = [ pkgs.mosh ]; };

    server = {
      nixos.programs.mosh.enable = true;

      homeManager = { pkgs, ... }: {
        # Add mosh-server to PATH so SSH can spawn it.
        home.sessionPath = [ "${pkgs.mosh}/bin" ];
      };
    };
  };
}
