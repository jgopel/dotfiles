{ inputs, ... }:

{
  imports = [ inputs.arctis-sound-manager.nixosModules.default ];

  security.rtkit.enable = true;
  services.pulseaudio.enable = false;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.arctis-sound-manager = {
    enable = true;
    autostartTray = true;
  };
}
