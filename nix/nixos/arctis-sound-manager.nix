{ arctis-sound-manager, ... }:

{
  imports = [ arctis-sound-manager.nixosModules.default ];

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  services.arctis-sound-manager = {
    enable = true;
    autostartTray = true;
  };
}
