{
  # Run `sudo nix run nixpkgs#keyd -- monitor` and find the built-in keyboard
  # in the initial device list.
  den.aspects.caps-escape-swap.__functor = _: { builtInIds }: {
    name = "caps-escape-swap";
    nixos = {
      services.keyd = {
        enable = true;
        keyboards.builtIn = {
          ids = builtInIds;
          settings.main = {
            capslock = "esc";
            esc = "capslock";
          };
        };
      };
    };
  };
}
