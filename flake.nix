{
  description = "Jonathan's NixOS and Home Manager configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    den.url = "github:denful/den";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia.url = "github:noctalia-dev/noctalia/cachix";
    noctalia-plugins = {
      url = "github:noctalia-dev/community-plugins";
      flake = false;
    };

    arctis-sound-manager = {
      url = "github:loteran/Arctis-Sound-Manager?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents.url = "github:numtide/llm-agents.nix";

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      # Keep upstream's nixpkgs pin to match its binary cache builds.
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    swifteam = {
      url = "https://cdn.swifteam.com/st-agent-linux/v1.357.0/nixos/swifteam.tar.gz";
      flake = false;
    };

    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ nixpkgs, ... }:
    let
      inherit (import ./nix/platform.nix) system;
      configurations =
        (nixpkgs.lib.evalModules {
          specialArgs = { inherit inputs pkgs; };
          modules = [
            inputs.den.flakeModule
            ./nix
          ];
        }).config.flake;
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          (_final: prev: {
            buildFHSEnv =
              args:
              prev.buildFHSEnv (
                args
                // {
                  targetPkgs =
                    pkgs:
                    (args.targetPkgs or (_: [ ])) pkgs
                    ++ [
                      # The FHS /usr hides the host zoneinfo targeted by /etc/localtime.
                      pkgs.tzdata
                      # Electron uses xdg-open to open external links.
                      pkgs.xdg-utils
                    ];
                }
              );
          })
        ];
        config.allowUnfree = true;
      };
    in
    configurations
    // {
      devShells.${system}.default = pkgs.mkShellNoCC {
        packages = with pkgs; [
          gnumake
          prek
          nixfmt
          statix
          deadnix
        ];
      };
    };
}
