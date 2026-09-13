{ config, pkgs, ... }:

let
  dotfilesDir = builtins.toString ../..;
in
{
  imports = [
    ./agents.nix
    ./bash.nix
    ./docker-gc.nix
    ./fish.nix
    ./git.nix
    ./rust.nix
    ./tmux.nix
    ./nvim.nix
  ];

  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  services.ssh-agent.enable = true;

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 3d";
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

  xdg.configFile."starship.toml".source = ../../starship.toml;

  home.sessionVariables = {
    MISTRAL_API_KEY = "<redacted>";
    GEMINI_API_KEY = "<redacted>";
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

    # LSP servers and formatters
    clang-tools
    lua-language-server
    (mdformat.withPlugins (ps: with ps; [ mdformat-gfm mdformat-frontmatter ]))
    prettier
    shellcheck
    shfmt
    stylua
  ];

  home.file."bin".source = "${dotfilesDir}/bin";
}
