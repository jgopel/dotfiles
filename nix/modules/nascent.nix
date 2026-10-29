{ den, ... }:

{
  den.aspects.nascent.includes = [
    den.aspects.nix.nascent
    (den.aspects.syncthing {
      category = "nascent";
      path = "~/work";
      stignore = ../../syncthing/work/nascent/stignore;
    })
  ];
}
