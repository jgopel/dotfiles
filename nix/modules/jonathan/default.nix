{ den, repoRoot, ... }:

let
  caches = import ../../cache-settings.nix;
in
{
  imports = [
    ./desktop.nix
    ./nascent.nix
  ];

  den.aspects.jonathan = {
    includes = [
      den.aspects.agents
      den.aspects.btop
      (den.aspects.cachix "jonathan")
      den.aspects.cli-tools
      den.aspects.dev-tools
      den.aspects.fish
      den.aspects.fzf
      den.aspects.ghostty.terminfo
      den.aspects.git
      den.aspects.mosh
      den.aspects.secrets
      den.aspects.ssh
      den.aspects.starship
      den.aspects.tailscale
      den.aspects.tmux
      ({ home, ... }: {
        homeManager = { lib, ... }: {
          nix.settings = lib.mkIf (home.nixInstallation == "single-user") caches.jonathan;
        };
      })
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
      nix.settings = caches.jonathan;
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
      git.settings = {
        user = {
          name = "Jonathan Gopel";
          email = "jgopel@gmail.com";
        };
        sendemail = {
          smtpserver = "smtp.gmail.com";
          smtpserverport = 587;
          smtpencryption = "tls";
          smtpuser = "jgopel@gmail.com";
        };
      };
      fish.interactiveShellInit = ''
        set -gx TZ 'America/Denver'
      '';
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
