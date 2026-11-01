{ den, ... }:

let
  caches = import ../cache-settings.nix;
in
{
  den.schema.home = { lib, ... }: {
    options.nixInstallation = lib.mkOption {
      type = lib.types.enum [
        "single-user"
        "multi-user"
        "nixos"
      ];
      description = ''
        Required Nix setup: single-user or multi-user Nix on another Linux
        distribution, or NixOS. Single-user cache settings are managed by Home
        Manager, multi-user settings by bootstrap-system.sh, and NixOS settings
        by the NixOS configuration. Standalone Home Manager can be used with
        any of these installation types.
      '';
    };
  };

  den.aspects.nix = {
    includes = [ den.aspects.nix.single-user ];

    nixos = {
      nixpkgs.config.allowUnfree = true;

      nix = {
        settings = caches.common // {
          experimental-features = [
            "nix-command"
            "flakes"
          ];
        };

        gc = {
          automatic = true;
          dates = "daily";
          options = "--delete-older-than 14d";
        };
      };
    };

    homeManager = { pkgs, ... }: {
      nix = {
        package = pkgs.nix;
        settings.experimental-features = [
          "nix-command"
          "flakes"
        ];
        gc = {
          automatic = true;
          dates = "daily";
          options = "--delete-older-than 3d";
        };
      };
    };

    single-user = { home, ... }: {
      homeManager = { config, lib, ... }: {
        nix.settings = lib.mkIf (home.nixInstallation == "single-user") (
          caches.common // { netrc-file = "${config.xdg.configHome}/nix/netrc"; }
        );
      };
    };

    nascent = {
      includes = [ den.aspects.nix.nascent.single-user ];
      provides.to-hosts.nixos.nix.settings = caches.nascent;
      single-user = { home, ... }: {
        homeManager = { lib, ... }: {
          nix.settings = lib.mkIf (home.nixInstallation == "single-user") caches.nascent;
        };
      };
    };
  };
}
