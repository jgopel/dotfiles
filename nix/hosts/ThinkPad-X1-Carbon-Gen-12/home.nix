{
  imports = [
    ../../home-manager/common.nix
    ../../home-manager/desktop-nixos.nix
    ../../home-manager/neomutt.nix
    ../../home-manager/arctis-sound-manager.nix
    ../../home-manager/nascent-desktop.nix
    ../../home-manager/ssh-nascent.nix
    ../../home-manager/syncthing/nascent.nix
    ../../home-manager/syncthing/personal.nix
  ];

  home.username = "jonathan";
  home.homeDirectory = "/home/jonathan";

  services.arctis-settings = {
    fallbackOutput = "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Speaker__sink";
    fallbackInput = "alsa_input.usb-046d_Logitech_BRIO_5BDF971A-03.analog-stereo";
  };

  services.syncthing-user.nascent-tunnels = true;

  # Steam is not enabled on this host.
  xdg.configFile."autostart/steam.desktop".enable = false;
}
