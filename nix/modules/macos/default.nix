{ den, ... }:

{
  imports = [
    ./desktop.nix
    ./keyboard.nix
    ./omniwm.nix
  ];

  den.aspects.macos.includes = [
    den.aspects.macos.desktop
    den.aspects.macos.keyboard
    den.aspects.macos.omniwm
  ];
}
