{ inputs, nixpkgs, home-manager, system, pkgs }:

let
  inherit (nixpkgs) lib;
  directories = lib.attrNames (lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./.));
  hostsWith = file: builtins.filter (host: builtins.pathExists (./. + "/${host}/${file}")) directories;
in
{
  nixosConfigurations = lib.genAttrs (hostsWith "configuration.nix") (host:
    lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [ (./. + "/${host}/configuration.nix") ];
    });

  homeConfigurations = builtins.listToAttrs (map
    (host:
      let
        home = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ (./. + "/${host}/home.nix") ];
          extraSpecialArgs = { inherit inputs; };
        };
      in
      lib.nameValuePair "${home.config.home.username}@${host}" home)
    (hostsWith "home.nix"));
}
