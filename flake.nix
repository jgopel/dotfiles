{
  description = "Jonathan's NixOS, macOS, and Home Manager configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    den.url = "github:denful/den";

    darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

    # Agent skill sources
    superpowers = {
      url = "github:obra/superpowers";
      flake = false;
    };
    janestreet-agent-skills = {
      url = "github:janestreet/agent_skills";
      flake = false;
    };
    trailofbits-skills = {
      # Pinned to the last commit before upstream removed
      # ask-questions-if-underspecified (trailofbits/skills#214).
      url = "github:trailofbits/skills/daa4ad03eb6ae7c451665ff30b5daaa6cfbe613c";
      flake = false;
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      # Keep upstream's nixpkgs pin to match its binary cache builds.
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
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
      fhsRuntimeOverlay = _final: prev: {
        buildFHSEnv =
          args:
          let
            targetPkgs =
              pkgs:
              (args.targetPkgs or (_: [ ])) pkgs
              ++ [
                # The FHS /usr hides the host zoneinfo targeted by /etc/localtime.
                pkgs.tzdata
                # Electron uses xdg-open to open external links.
                pkgs.xdg-utils
              ];
          in
          prev.buildFHSEnv (args // { inherit targetPkgs; });
      };

      mkPkgs =
        system:
        import nixpkgs {
          inherit system;
          overlays = [ fhsRuntimeOverlay ];
          config.allowUnfree = true;
        };

      mkDevShell =
        system:
        let
          pkgs = mkPkgs system;
        in
        pkgs.mkShellNoCC {
          packages = with pkgs; [
            just
            prek
            nixfmt
            statix
            deadnix
          ];
        };

      evaluation = nixpkgs.lib.evalModules {
        specialArgs = {
          inherit inputs mkPkgs;
          repoRoot = ./.;
        };
        modules = [
          inputs.den.flakeModule
          ./nix
        ];
      };
    in
    evaluation.config.flake
    // {
      devShells = nixpkgs.lib.genAttrs evaluation.config.den.systems (system: {
        default = mkDevShell system;
      });
    };
}
