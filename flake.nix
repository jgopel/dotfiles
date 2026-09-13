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

  outputs = inputs@{ nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
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
    in
    import ./nix/hosts {
      inherit inputs system pkgs;
    };
}
