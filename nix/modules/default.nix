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
    ./arctis-sound-manager
    ./bazel.nix
    ./boot-nixos-first.nix
    ./btop.nix
    ./cachix.nix
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
    ./mosh.nix
    ./nascent.nix
    ./nix.nix
    ./noctalia
    ./nvim.nix
    ./pipewire.nix
    ./python.nix
    ./rust.nix
    ./secrets.nix
    ./server.nix
    ./signal.nix
    ./slack.nix
    ./ssh.nix
    ./starship.nix
    ./syncthing
    ./tailscale.nix
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
      den.aspects.secrets
      den.aspects.ssh
      den.aspects.starship
      den.aspects.tailscale
      den.aspects.tmux
    ];

    default.nixos = { lib, pkgs, ... }: {
      boot.kernelPackages = lib.mkDefault pkgs.linuxPackages;
      boot.loader = {
        systemd-boot = {
          enable = lib.mkDefault true;
          configurationLimit = lib.mkDefault 10;
        };
        efi.canTouchEfiVariables = lib.mkDefault true;
      };

      time.timeZone = lib.mkDefault "America/Denver";

      i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
      i18n.extraLocaleSettings = lib.mkDefault {
        LC_ADDRESS = "en_US.UTF-8";
        LC_IDENTIFICATION = "en_US.UTF-8";
        LC_MEASUREMENT = "en_US.UTF-8";
        LC_MONETARY = "en_US.UTF-8";
        LC_NAME = "en_US.UTF-8";
        LC_NUMERIC = "en_US.UTF-8";
        LC_PAPER = "en_US.UTF-8";
        LC_TELEPHONE = "en_US.UTF-8";
        LC_TIME = "en_US.UTF-8";
      };

      security.sudo.extraConfig = "Defaults pwfeedback";

      # Prek hooks such as tombi download generic Linux binaries that expect
      # /lib64/ld-linux-x86-64.so.2 rather than a Nix store interpreter.
      programs.nix-ld.enable = true;

      # Keep a recovery editor available without Home Manager.
      environment.systemPackages = [ pkgs.vim ];
    };

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
