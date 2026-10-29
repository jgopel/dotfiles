{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./direnv.nix
    ./git.nix
    ./nix.nix
    ./nix-index.nix
    ./ssh.nix
    ./starship.nix
    ./terminfo.nix
    ./tmux.nix
  ];

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
  };
}
