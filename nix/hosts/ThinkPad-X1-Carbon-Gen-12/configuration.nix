{ pkgs, ... }:

{
  imports = [
    ../../nixos/profiles/desktop.nix
    ../../nixos/arctis-sound-manager.nix
    ../../nixos/users/jonathan.nix
    ../../nixos/boot/systemd-boot.nix
    ../../nixos/kernel-testing.nix
    # ../../nixos/swifteam.nix
    ../../system-nascent.nix
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.prioritizeNixOS = true;

  hardware.graphics.extraPackages = [ pkgs.intel-media-driver ];

  networking.hostName = "ThinkPad-X1-Carbon-Gen-12";

  services = {
    tailscale.enable = true;

    # Run `sudo nix run nixpkgs#keyd -- monitor` and find the built-in keyboard
    # in the initial device list; copy its ID, then exit with Ctrl+C.
    # No typing is required.
    keyd.keyboards.builtIn.ids = [ "0001:0001" ];
  };

  system.stateVersion = (import ../../platform.nix).stateVersion;
}
