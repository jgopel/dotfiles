{ ... }:

{
  imports = [
    ../../nixos/profiles/desktop.nix
    ../../nixos/arctis-sound-manager.nix
    ../../nixos/users/jonathan.nix
    ../../nixos/boot/systemd-boot.nix
    ../../nixos/kernel-testing.nix
    ../../nixos/razer-windows-vm.nix
    ./hardware-configuration.nix
  ];

  services = {
    tailscale.enable = true;

    # Run `sudo nix run nixpkgs#keyd -- monitor` and find the built-in keyboard
    # in the initial device list; copy its ID, then exit with Ctrl+C.
    # No typing is required.
    keyd.keyboards.builtIn.ids = [ "0001:0001" ];

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
  programs.razerWindowsVm.enable = false;

  system.stateVersion = (import ../../platform.nix).stateVersion;
}
