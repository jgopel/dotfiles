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
  ];

  home.username = username;
  home.homeDirectory = homeDirectory;
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  home.activation.report-changes = config.lib.dag.entryAnywhere ''
    ${pkgs.nvd}/bin/nvd diff $oldGenPath $newGenPath || true
  '';

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
    amp-cli
    atop
    claude-code
    cmake
    codex
    curl
    dtrx
    gcc
    gdb
    gemini-cli
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
    poetry
    python3
    ripgrep
    rsync
    strace
    sysstat
    time
    tree
    uv
    wget
    yq
  ];

  home.file."bin".source = "${dotfilesDir}/bin";
}
