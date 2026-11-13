{ den, repoRoot, ... }:

{
  imports = [
    ./desktop.nix
    ./nascent.nix
    ./personal.nix
  ];

  den.aspects.jonathan = {
    includes = [
      den.aspects.agents
      den.aspects.btop
      den.aspects.cli-tools
      den.aspects.dev-tools
      den.aspects.fish
      den.aspects.fzf
      den.aspects.ghostty.terminfo
      den.aspects.git
      den.aspects.mosh
      den.aspects.ssh
      den.aspects.starship
      den.aspects.tailscale
      den.aspects.tmux
    ];

    user =
      {
        osConfig,
        lib,
        pkgs,
        ...
      }:
      {
        description = "Jonathan";
        extraGroups = [
          "wheel"
        ]
        ++ lib.optional osConfig.networking.networkmanager.enable "networkmanager";
        shell = pkgs.fish;
      };

    provides.to-hosts.nixos = { lib, ... }: {
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
    };

    homeManager.programs = {
      git.includes = [ { path = repoRoot + /git/identity; } ];
      fish.interactiveShellInit = builtins.readFile (repoRoot + /fish/jonathan.fish);
    };

    personal-sync.includes = [
      (den.aspects.syncthing {
        category = "personal";
        path = "~/personal";
        stignore = repoRoot + /syncthing/personal/stignore;
      })
    ];
  };
}
