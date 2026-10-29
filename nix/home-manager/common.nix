{ lib, ... }:

{
  imports = [
    ./ssh.nix
    ./starship.nix
    ./tmux.nix
  ];

  home.sessionVariables = lib.mapAttrs (
    name: _: lib.removeSuffix "\n" (builtins.readFile (../../secrets + "/${name}"))
  ) (lib.filterAttrs (_: type: type == "regular") (builtins.readDir ../../secrets));
}
