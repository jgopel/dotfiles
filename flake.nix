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

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, neovim-nightly-overlay, llm-agents, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ neovim-nightly-overlay.overlays.default ];
        config.allowUnfree = true;
      };
    in
    {
      homeConfigurations."jonathan@jonathan-ThinkPad-X1-Carbon-Gen-12" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home.nix
          ./modules/desktop.nix
        ];
        extraSpecialArgs = {
          inherit llm-agents;
          username = "jonathan";
          homeDirectory = "/home/jonathan";
        };
      };

      homeConfigurations."adminjg@sov-cpu-srv" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home.nix
        ];
        extraSpecialArgs = {
          inherit llm-agents;
          username = "adminjg";
          homeDirectory = "/home/adminjg";
        };
      };
    };
}
