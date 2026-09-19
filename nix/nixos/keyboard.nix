{ lib, ... }:

{
  services.xserver.xkb = {
    layout = lib.mkDefault "us";
    variant = lib.mkDefault "";
  };

  services.keyd = {
    enable = true;
    # Each host selects its built-in keyboard via keyboards.builtIn.ids.
    keyboards.builtIn.settings.main = {
      capslock = "esc";
      esc = "capslock";
    };
  };
}
