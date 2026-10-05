{ inputs, lib, ... }:

{
  imports = [ inputs.arctis-sound-manager.nixosModules.default ];

  # GDM also starts graphical-session.target; its ASM instance must not compete
  # with the logged-in user's daemon for the headset's USB interface.
  systemd.user.services =
    lib.genAttrs
      [
        "arctis-manager"
        "arctis-video-router"
        "arctis-stream-guard"
        "arctis-firstrun-seed"
        "app-ArctisManager"
      ]
      (_: {
        unitConfig.ConditionUser = [
          "!gdm"
          "!gdm-greeter"
        ];
      });

  security.rtkit.enable = true;
  services = {
    pulseaudio.enable = false;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    arctis-sound-manager = {
      enable = true;
      autostartTray = true;
    };
  };
}
