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
    ./arctis-sound-manager.nix
    ./bazel.nix
    ./btop.nix
    ./cachix.nix
    ./canopy-desk.nix
    ./claude-code.nix
    ./cli-tools.nix
    ./codex.nix
    ./cpp.nix
    ./desktop.nix
    ./dev-tools.nix
    ./docker.nix
    ./editor-tools.nix
    ./fzf.nix
    ./hyprland.nix
    ./hyprland-testing.nix
    ./mosh.nix
    ./nascent.nix
    ./nix.nix
    ./noctalia.nix
    ./nvim.nix
    ./python.nix
    ./rust.nix
    ./server.nix
    ./syncthing
  ];

  den = {
    default.includes = [
      den.batteries.define-user
      den.aspects.agents
      den.aspects.btop
      den.aspects.cachix
      den.aspects.cli-tools
      den.aspects.dev-tools
      den.aspects.fzf
      den.aspects.mosh
      den.aspects.nix
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
