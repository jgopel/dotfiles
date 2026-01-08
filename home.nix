{ config, pkgs, username, homeDirectory, rustToolchain, ... }:

let
  dotfilesDir = builtins.toString ./.;
in
{
  imports = [
    ./modules/bash.nix
    ./modules/fish.nix
    ./modules/git.nix
    ./modules/tmux.nix
    ./modules/nvim.nix
    ./modules/llm.nix
  ];

  home.username = username;
  home.homeDirectory = homeDirectory;
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  programs.fzf = {
    enable = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.starship = {
    enable = true;
  };

  xdg.configFile."starship.toml".source = ./starship.toml;

  home.sessionPath = [ "$HOME/.cargo/bin" ];

  home.packages = with pkgs; [
    fishPlugins.done
    fishPlugins.fzf-fish
    rustToolchain

    ack
    atop
    cmake
    curl
    dtrx
    gcc
    gdb
    gnumake
    htop
    inetutils
    jq
    mosh
    ninja
    nodejs
    openssh_gssapi
    perf
    plocate
    python3
    ripgrep
    rsync
    sysstat
    strace
    time
    tree
    uv
    wget
    yq
  ];

  home.file."bin".source = "${dotfilesDir}/bin";
}
