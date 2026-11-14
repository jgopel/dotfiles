{ den, repoRoot, ... }:

{
  imports = [
    ./desktop.nix
    ./nascent.nix
    ./personal.nix
  ];

  den.aspects.jonathan = {
    includes = [
      den.aspects.btop
      den.aspects.cli-tools
      den.aspects.fish
      den.aspects.fzf
      den.aspects.ghostty.terminfo
      den.aspects.git
      den.aspects.mosh
      den.aspects.nvim
      den.aspects.ssh
      den.aspects.starship
      den.aspects.tailscale
      den.aspects.tmux
    ];

    user = { pkgs, ... }: {
      description = "Jonathan";
      extraGroups = [ "wheel" ];
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

    dev.includes = [ den.aspects.dev-tools ];
    agents.includes = [ den.aspects.agents ];

    personal-sync.includes = [
      (den.aspects.syncthing {
        category = "personal";
        path = "~/personal";
        stignore = repoRoot + /syncthing/personal/stignore;
      })
    ];
  };
}
