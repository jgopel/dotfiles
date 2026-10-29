{ lib, ... }:

{
  imports = [
    ./git.nix
    ./ssh.nix
    ./starship.nix
    ./terminfo.nix
    ./tmux.nix
  ];

  home = {
    inherit (import ../platform.nix) stateVersion;

    sessionVariables = lib.mapAttrs (
      name: _: lib.removeSuffix "\n" (builtins.readFile (../../secrets + "/${name}"))
    ) (lib.filterAttrs (_: type: type == "regular") (builtins.readDir ../../secrets));
  };
}
