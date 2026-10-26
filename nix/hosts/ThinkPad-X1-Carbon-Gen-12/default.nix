{
  den = {
    hosts.x86_64-linux.ThinkPad-X1-Carbon-Gen-12 = { };
    homes.x86_64-linux."jonathan@ThinkPad-X1-Carbon-Gen-12" = { };

    aspects = {
      ThinkPad-X1-Carbon-Gen-12.nixos.imports = [ ./configuration.nix ];
      "jonathan@ThinkPad-X1-Carbon-Gen-12".homeManager.imports = [ ./home.nix ];
    };
  };
}
