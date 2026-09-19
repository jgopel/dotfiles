{ pkgs, ... }:

{
  imports = [
    ../../nixos/profiles/desktop.nix
    ../../nixos/users/jonathan.nix
    ../../nixos/boot/systemd-boot.nix
    ./hardware-configuration.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "ThinkPad-X1-Carbon-Gen-12-nixos";

  services.tailscale.enable = true;

  # Run `sudo nix run nixpkgs#keyd -- monitor` and find the built-in keyboard
  # in the initial device list; copy its ID, then exit with Ctrl+C.
  # No typing is required.
  services.keyd.keyboards.builtIn.ids = [ "0001:0001" ];

  system.stateVersion = (import ../../platform.nix).stateVersion;
}
