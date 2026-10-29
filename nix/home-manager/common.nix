{ lib, ... }:

{
  home.sessionVariables = lib.mapAttrs (
    name: _: lib.removeSuffix "\n" (builtins.readFile (../../secrets + "/${name}"))
  ) (lib.filterAttrs (_: type: type == "regular") (builtins.readDir ../../secrets));
}
