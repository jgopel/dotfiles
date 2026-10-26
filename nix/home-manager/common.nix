{
  config,
  lib,
  pkgs,
  ...
}:

let
  dotfilesDir = builtins.toString ../..;
in
{
  imports = [
    ./agents.nix
    ./bash.nix
    ./direnv.nix
    ./docker-gc.nix
    ./fish.nix
    ./git.nix
    ./nix.nix
    ./nix-index.nix
    ./rust.nix
    ./ssh.nix
    ./starship.nix
    ./terminfo.nix
    ./tmux.nix
    ./nvim.nix
  ];

  programs.fzf.enable = true;
  programs.home-manager.enable = true;

  home = {
    inherit (import ../platform.nix) stateVersion;

    activation.report-changes = config.lib.dag.entryAnywhere ''
      if [[ -n "''${oldGenPath:-}" ]]; then
        ${pkgs.nvd}/bin/nvd diff "$oldGenPath" "$newGenPath" || true
      fi
    '';

    sessionVariables = lib.mapAttrs (
      name: _: lib.removeSuffix "\n" (builtins.readFile (../../secrets + "/${name}"))
    ) (lib.filterAttrs (_: type: type == "regular") (builtins.readDir ../../secrets));

    packages = with pkgs; [
      # General tools
      ack
      colorized-logs
      curl
      dtrx
      # eternal-terminal
      gdb
      inetutils
      jq
      less
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
      (mdformat.withPlugins (
        ps: with ps; [
          mdformat-gfm
          mdformat-frontmatter
        ]
      ))
      prettier
      shellcheck
      shfmt
      stylua
    ];

    file."bin".source = "${dotfilesDir}/bin";
  };
}
