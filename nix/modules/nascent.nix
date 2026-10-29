{ den, repoRoot, ... }:

{
  den.aspects.nascent.includes = [
    den.aspects.nix.nascent
    (den.aspects.syncthing {
      category = "nascent";
      path = "~/work";
      stignore = repoRoot + /syncthing/work/nascent/stignore;
    })
  ];
}
