{ config, pkgs, username, homeDirectory, ... }:

let
  dotfilesDir = builtins.toString ./.;
in
{
  imports = [
    ./modules/bash.nix
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
    enableBashIntegration = true;
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  home.packages = with pkgs; [
    ack
    atop
    bash-completion
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
    perf
    plocate
    python3
    ripgrep
    rsync
    rustup
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
