{
  den,
  inputs,
  mkPkgs,
  ...
}:

{
  imports = [
    ./1pass
    ./agents.nix
    ./amp.nix
    ./antigravity-cli.nix
    ./arctis-sound-manager
    ./bazel.nix
    ./boot-nixos-first.nix
    ./btop.nix
    ./canopy-desk.nix
    ./caps-escape-swap.nix
    ./claude-code.nix
    ./cli-tools.nix
    ./codex.nix
    ./cpp.nix
    ./desktop.nix
    ./dev-tools.nix
    ./docker.nix
    ./editor-tools.nix
    ./firefox.nix
    ./fish.nix
    ./fzf.nix
    ./ghostty.nix
    ./git.nix
    ./gnome
    ./home-manager.nix
    ./hyprland
    ./hyprland-testing.nix
    ./jonathan
    ./mdns.nix
    ./mosh.nix
    ./nix.nix
    ./noctalia
    ./nvim.nix
    ./pipewire.nix
    ./python.nix
    ./rust.nix
    ./server.nix
    ./signal.nix
    ./slack.nix
    ./ssh.nix
    ./starship.nix
    ./syncthing
    ./tailscale.nix
    ./tmux.nix
    ./unraid-guest.nix
  ];

  den = {
    default.includes = [
      den.batteries.define-user
      den.aspects.home-manager
      den.aspects.nix
    ];

    default.nixos =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        boot.kernelPackages = lib.mkDefault pkgs.linuxPackages;
        boot.loader = {
          systemd-boot = {
            enable = lib.mkDefault true;
            configurationLimit = lib.mkDefault 10;
          };
          efi.canTouchEfiVariables = lib.mkDefault true;
        };

        # Keep recovery tools available without Home Manager. Headless systems
        # already have a console shell and do not need graphical applications.
        environment.systemPackages = [
          pkgs.vim
        ]
        ++ lib.optionals config.services.graphical-desktop.enable [
          pkgs.ghostty
          pkgs.firefox
        ];
      };

    # Supply flake inputs to class modules and select packages per home.
    schema = {
      host = {
        includes = [ den.batteries.mutual-provider ];
        instantiate = args: inputs.nixpkgs.lib.nixosSystem (args // { specialArgs = { inherit inputs; }; });
      };
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
