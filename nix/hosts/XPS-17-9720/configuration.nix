{ ... }:

{
  imports = [
    ../../nixos/profiles/desktop.nix
    ../../nixos/users/jonathan.nix
    ../../nixos/boot/systemd-boot.nix
    ../../nixos/kernel-testing.nix
    ./hardware-configuration.nix
    ./suspend-tracing.nix
  ];

  services = {
    xserver.videoDrivers = [ "nvidia" ];
  };

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    powerManagement = {
      enable = true;
      kernelSuspendNotifier = true;
    };
    prime = {
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
      sync.enable = true;
    };
  };

  networking.hostName = "XPS-17-9720";

  programs.steam.enable = true;

  system.stateVersion = "26.05";
}
