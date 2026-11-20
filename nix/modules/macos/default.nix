{ den, ... }:

{
  imports = [
    ./desktop.nix
    ./keyboard.nix
    ./omniwm.nix
  ];

  den.aspects.macos.__functor = _: { omniwmSettingsFile }: {
    name = "macos";
    includes = [
      den.aspects.macos.desktop
      den.aspects.macos.keyboard
      (den.aspects.macos.omniwm { settingsFile = omniwmSettingsFile; })
    ];
  };
}
