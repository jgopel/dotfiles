{
  den,
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    ./agents.nix
    ./amp.nix
    ./antigravity-cli.nix
    ./bazel.nix
    ./btop.nix
    ./claude-code.nix
    ./codex.nix
    ./docker.nix
    ./mosh.nix
    ./server.nix
    ./syncthing
  ];

  den = {
    default.includes = [
      den.batteries.define-user
      den.aspects.agents
      den.aspects.btop
      den.aspects.mosh
    ];

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
