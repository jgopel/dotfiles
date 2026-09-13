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

  outputs = inputs@{ nixpkgs, home-manager, arctis-sound-manager, llm-agents, neovim-nightly-overlay, rust-overlay, nix-index-database, ... }:
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
                targetPkgs = pkgs:
                  (args.targetPkgs or (_: [ ])) pkgs
                  ++ [
                    # The FHS /usr hides the host zoneinfo targeted by /etc/localtime.
                    pkgs.tzdata
                    # Electron uses xdg-open to open external links.
                    pkgs.xdg-utils
                  ];
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
    import ./nix/hosts {
      inherit nixpkgs home-manager system pkgs arctis-sound-manager nix-index-database;
      inherit inputs llmAgentPackages rustToolchain cargo-nightly;
    };
}
