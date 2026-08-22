{ config, pkgs, username, homeDirectory, rustToolchain, cargo-nightly, ... }:

let
  dotfilesDir = builtins.toString ./.;
in
{
  imports = [
    ./modules/bash.nix
    ./modules/docker-gc.nix
    ./modules/fish.nix
    ./modules/git.nix
    ./modules/tmux.nix
    ./modules/nvim.nix
  ];

  home.username = username;
  home.homeDirectory = homeDirectory;
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  services.ssh-agent.enable = true;

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 14d";
    };
  };

  home.activation.report-changes = config.lib.dag.entryAnywhere ''
    if [[ -n "''${oldGenPath:-}" ]]; then
      ${pkgs.nvd}/bin/nvd diff "$oldGenPath" "$newGenPath" || true
    fi
  '';

  programs.nix-index-database.comma.enable = true;

  programs.fzf = {
    enable = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config.global.log_format = builtins.fromJSON ''"\u001b[2mdirenv: %s\u001b[0m"'';
  };

  programs.starship = {
    enable = true;
  };

  xdg.configFile."starship.toml".source = ./starship.toml;
  xdg.configFile."bacon/prefs.toml".source = ./bacon/prefs.toml;
  xdg.configFile."amp/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${homeDirectory}/dotfiles/amp/settings.json";
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
    btop
    colorized-logs
    curl
    dtrx
    eternal-terminal
    gdb
    inetutils
    jq
    less
    mosh
    openssh_gssapi
    perf
    plocate
    ripgrep
    rsync
    strace
    sysstat
    time
    tree
    unzip
    wget
    xclip # for amp clipboard usage
    yq

    # Language agnostic tools
    ast-grep
    gnumake
    prek
    tree-sitter

    # C++ tools
    cmake
    gcc
    ninja

    # Python tools
    isort
    python3
    ruff
    ty
    uv

    # Rust tools
    bacon
    cargo-nextest
    cargo-nightly
    rustToolchain

    # LSP servers and formatters
    clang-tools
    lua-language-server
    prettier
    shellcheck
    shfmt
    stylua

    # LLMs
    antigravity-cli
    claude-code
    codex
    nodejs
  ];

  home.file."bin".source = "${dotfilesDir}/bin";
  home.file.".claude/statusline.sh" = {
    source = ./claude/statusline.sh;
    executable = true;
  };
  home.file.".claude/settings.json".source = ./claude/settings.json;
}
