{
  den.aspects.syncthing.__functor =
    _:
    {
      category,
      path,
      stignore,
      tunnels ? [ ],
    }:
    {
      # Each call must have its own identity so den retains multiple categories.
      name = "syncthing-${category}";
      homeManager = {
        imports = [ ./service.nix ];
        services.syncthing-user = {
          enable = true;
          clusters = [ category ];
          folders = [ { inherit path stignore; } ];
          inherit tunnels;
        };
      };
    };
}
