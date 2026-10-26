{
  den,
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    ./btop.nix
    ./syncthing
  ];

  den = {
    default.includes = [ den.aspects.btop ];

    # Preserve legacy modules' inputs argument and the standalone HM package set.
    schema = {
      host.instantiate =
        args: inputs.nixpkgs.lib.nixosSystem (args // { specialArgs = { inherit inputs; }; });
      home = {
        inherit pkgs;
        instantiate =
          args:
          inputs.home-manager.lib.homeManagerConfiguration (
            args // { extraSpecialArgs = { inherit inputs; }; }
          );
      };
    };
  };
}
