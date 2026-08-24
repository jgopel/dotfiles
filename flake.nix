{
  description = "Jonathan's NixOS and Home Manager configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    arctis-sound-manager = {
      url = "github:loteran/Arctis-Sound-Manager?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents.url = "github:numtide/llm-agents.nix";

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
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

  outputs = { nixpkgs, home-manager, arctis-sound-manager, llm-agents, neovim-nightly-overlay, nixgl, rust-overlay, nix-index-database, ... }:
    let
      system = "x86_64-linux";
      llmAgentPackages = llm-agents.packages.${system};
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          neovim-nightly-overlay.overlays.default
          rust-overlay.overlays.default
          (final: prev: {
            buildFHSEnv = args:
              prev.buildFHSEnv (args // {
                # The FHS /usr hides the host zoneinfo targeted by /etc/localtime.
                targetPkgs = pkgs:
                  (args.targetPkgs or (_: [ ])) pkgs
                  ++ [ pkgs.tzdata ];
              });
          })
          # TODO: Remove this once nixpkgs has 2.0.15 or later - syncthing
          # 2.0.12-2.0.14 hit a panic due to a QUIC error
          (final: prev: {
            syncthing = prev.syncthing.overrideAttrs (old: rec {
              version = "2.0.15";
              src = prev.fetchFromGitHub {
                owner = "syncthing";
                repo = "syncthing";
                tag = "v${version}";
                hash = "sha256-v77ovjV+UoCRA1GteP+HDqC8dsRvtOhFX/IkSgSIf8Y=";
              };
              vendorHash = "sha256-boYTLgvH+iWlh3y3Z0LPvSVGEget3X94AthtJKphhCw=";
              buildPhase = prev.lib.replaceStrings
                [ "-version v${old.version}" ]
                [ "-version v${version}" ]
                old.buildPhase;
              meta = old.meta // {
                changelog = "https://github.com/syncthing/syncthing/releases/tag/v${version}";
              };
            });
          })
        ];
        config.allowUnfree = true;
      };
      rustToolchain = pkgs.rust-bin.stable.latest.default.override {
        extensions = [ "rust-src" "rust-analyzer" "clippy" "rustfmt" ];
      };
      rustNightly = pkgs.rust-bin.nightly.latest.default;
      cargo-nightly = pkgs.writeShellScriptBin "cargo-nightly" ''
        export RUSTC="${rustNightly}/bin/rustc"
        export RUSTDOC="${rustNightly}/bin/rustdoc"
        exec ${rustNightly}/bin/cargo "$@"
      '';
    in
    {
      nixosConfigurations."XPS-17-9720-nixos" = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          arctis-sound-manager.nixosModules.default
          ./modules/arctis-sound-manager.nix
          ./hosts/nixos/configuration.nix
        ];
      };

      homeConfigurations."jonathan@XPS-17-9720-nixos" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          nix-index-database.homeModules.nix-index
          ./home.nix

          ./modules/desktop-nixos.nix
          ./modules/arctis-sound-manager-home.nix
          ./modules/rclone-google-drive.nix
        ];
        extraSpecialArgs = {
          inherit llmAgentPackages rustToolchain cargo-nightly;
          username = "jonathan";
          homeDirectory = "/home/jonathan";
        };
      };

      homeConfigurations."jonathan@jonathan-ThinkPad-X1-Carbon-Gen-12" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          nix-index-database.homeModules.nix-index
          ./home.nix

          ./modules/bash-standalone.nix
          ./modules/desktop-standalone.nix
          ./modules/rclone-google-drive.nix
          ./modules/nascent.nix
          ./modules/nascent-desktop.nix
          ./modules/syncthing-nascent.nix
          { services.syncthing-user.nascent-tunnels = true; }
        ];
        extraSpecialArgs = {
          inherit llmAgentPackages nixgl rustToolchain cargo-nightly;
          username = "jonathan";
          homeDirectory = "/home/jonathan";
        };
      };

      homeConfigurations."jonathan@jonathan-XPS-17-9720" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          nix-index-database.homeModules.nix-index
          ./home.nix

          ./modules/bash-standalone.nix
          ./modules/desktop-standalone.nix
          ./modules/rclone-google-drive.nix
        ];
        extraSpecialArgs = {
          inherit llmAgentPackages nixgl rustToolchain cargo-nightly;
          username = "jonathan";
          homeDirectory = "/home/jonathan";
        };
      };

      homeConfigurations."jonathan@sov-cpu-srv" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          nix-index-database.homeModules.nix-index
          ./home.nix

          ./modules/bash-standalone.nix
          ./modules/server.nix
          ./modules/syncthing-nascent.nix
          ./modules/nascent.nix
        ];
        extraSpecialArgs = {
          inherit llmAgentPackages rustToolchain cargo-nightly;
          username = "jonathan";
          homeDirectory = "/home/jonathan";
        };
      };

      homeConfigurations."jonathan@ip-172-31-2-254" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          nix-index-database.homeModules.nix-index
          ./home.nix

          ./modules/bash-standalone.nix
          ./modules/server.nix
          ./modules/syncthing-nascent.nix
          ./modules/nascent.nix
        ];
        extraSpecialArgs = {
          inherit llmAgentPackages rustToolchain cargo-nightly;
          username = "jonathan";
          homeDirectory = "/home/jonathan";
        };
      };

      homeConfigurations."jonathan@ip-172-31-96-20" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          nix-index-database.homeModules.nix-index
          ./home.nix

          ./modules/bash-standalone.nix
          ./modules/server.nix
          ./modules/syncthing-nascent.nix
          ./modules/nascent.nix
        ];
        extraSpecialArgs = {
          inherit llmAgentPackages rustToolchain cargo-nightly;
          username = "jonathan";
          homeDirectory = "/home/jonathan";
        };
      };
    };
}
