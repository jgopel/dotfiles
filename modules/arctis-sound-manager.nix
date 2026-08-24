{
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
