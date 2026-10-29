{
  den,
  inputs,
  mkPkgs,
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
    ./fish.nix
    ./fzf.nix
    ./ghostty.nix
    ./git.nix
    ./home-manager.nix
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
    ./ssh.nix
    ./starship.nix
    ./syncthing
    ./tmux.nix
  ];

  den = {
    default.includes = [
      den.batteries.define-user
      den.aspects.agents
      den.aspects.btop
      den.aspects.cachix
      den.aspects.cli-tools
      den.aspects.dev-tools
      den.aspects.fish
      den.aspects.fzf
      den.aspects.ghostty.terminfo
      den.aspects.git
      den.aspects.home-manager
      den.aspects.mosh
      den.aspects.nix
      den.aspects.ssh
      den.aspects.starship
      den.aspects.tmux
    ];

    # Preserve legacy modules' inputs argument and select packages per home.
    schema = {
      host.instantiate =
        args: inputs.nixpkgs.lib.nixosSystem (args // { specialArgs = { inherit inputs; }; });
      home = { config, ... }: {
        pkgs = mkPkgs config.system;
        instantiate =
          args:
          inputs.home-manager.lib.homeManagerConfiguration (
            args // { extraSpecialArgs = { inherit inputs; }; }
          );
      };
    };
  };
}
