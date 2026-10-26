{
  den = {
    homes.x86_64-linux."jonathan@sov-cpu-srv" = { };
    aspects."jonathan@sov-cpu-srv".homeManager.imports = [ ./home.nix ];
  };
}
