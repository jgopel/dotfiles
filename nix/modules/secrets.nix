{ repoRoot, ... }:

{
  den.aspects.secrets.homeManager = { lib, ... }: {
    home.sessionVariables = lib.mapAttrs (
      name: _: lib.removeSuffix "\n" (builtins.readFile (repoRoot + "/secrets/${name}"))
    ) (lib.filterAttrs (_: type: type == "regular") (builtins.readDir (repoRoot + /secrets)));
  };
}
