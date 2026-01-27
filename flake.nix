{
  description = "Jonathan's dotfiles managed with Home Manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
  };

  outputs = { nixpkgs, home-manager, neovim-nightly-overlay, nixgl, rust-overlay, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          neovim-nightly-overlay.overlays.default
          rust-overlay.overlays.default
        ];
        config.allowUnfree = true;
      };
      rustToolchain = pkgs.rust-bin.stable.latest.default.override {
        extensions = [ "rust-src" "rust-analyzer" "clippy" "rustfmt" ];
      };
    in
    {
      homeConfigurations."jonathan@jonathan-ThinkPad-X1-Carbon-Gen-12" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home.nix
          ./modules/desktop.nix
          ./modules/nascent.nix
        ];
        extraSpecialArgs = {
          inherit nixgl rustToolchain;
          username = "jonathan";
          homeDirectory = "/home/jonathan";
        };
      };

      homeConfigurations."jonathan@jonathan-XPS-17-9720" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home.nix
          ./modules/desktop.nix
        ];
        extraSpecialArgs = {
          inherit nixgl rustToolchain;
          username = "jonathan";
          homeDirectory = "/home/jonathan";
        };
      };

      homeConfigurations."adminjg@sov-cpu-srv" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home.nix
          ./modules/server.nix
        ];
        extraSpecialArgs = {
          inherit rustToolchain;
          username = "adminjg";
          homeDirectory = "/home/adminjg";
        };
      };

      homeConfigurations."jonathan@ip-172-31-2-254" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home.nix
          ./modules/server.nix
        ];
        extraSpecialArgs = {
          inherit rustToolchain;
          username = "jonathan";
          homeDirectory = "/home/jonathan";
        };
      };
    };
}
