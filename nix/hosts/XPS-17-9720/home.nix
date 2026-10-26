{
  imports = [
    ../../home-manager/common.nix
    ../../home-manager/desktop-nixos.nix
    ../../home-manager/neomutt.nix
    ../../home-manager/ssh-personal.nix
    ../../home-manager/arctis-sound-manager.nix
  ];

  home.username = "jonathan";
  home.homeDirectory = "/home/jonathan";

  services.arctis-settings = {
    fallbackOutput = "alsa_output.pci-0000_00_1f.3-platform-sof_sdw.HiFi__Speaker__sink";
    fallbackInput = "alsa_input.usb-046d_Logitech_BRIO_5BDF971A-03.iec958-stereo";
  };
}
