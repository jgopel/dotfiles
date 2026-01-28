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

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  home.activation.report-changes = config.lib.dag.entryAnywhere ''
    if [[ -n "''${oldGenPath:-}" ]]; then
      ${pkgs.nvd}/bin/nvd diff "$oldGenPath" "$newGenPath" || true
    fi
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
  xdg.configFile."amp/settings.json".source = ./amp/settings.json;
  xdg.configFile."agents/skills".source = ./agents/skills;

  home.sessionPath = [ "$HOME/.cargo/bin" "$HOME/.amp/bin" ];

  home.sessionVariables = {
    TERMINFO_DIRS = "$HOME/.nix-profile/share/terminfo:/usr/share/terminfo";
  };

  home.packages = with pkgs; [
    fishPlugins.done
    fishPlugins.fzf-fish
    ghostty.terminfo

    # General tools
    ack
    atop
    colorized-logs
    curl
    dtrx
    gdb
    htop
    inetutils
    jq
    mosh
    eternal-terminal
    openssh_gssapi
    perf
    plocate
    ripgrep
    rsync
    strace
    sysstat
    time
    tree
    wget
    yq

    # Language agnostic tools
    gnumake

    # C++ tools
    cmake
    gcc
    ninja

    # Python tools
    poetry
    python3
    uv

    # Rust tools
    rustToolchain

    # LLMs
    claude-code
    codex
    gemini-cli
    nodejs

  ];

  home.file."bin".source = "${dotfilesDir}/bin";
}
