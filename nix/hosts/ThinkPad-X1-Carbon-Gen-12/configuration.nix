{ pkgs, ... }:

{
  imports = [
    ../../nixos/profiles/desktop.nix
    ../../nixos/users/jonathan.nix
    ../../nixos/boot/systemd-boot.nix
    # ../../nixos/swifteam.nix
    ../../system-nascent.nix
    ./hardware-configuration.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

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

  # After resume, DNS waits on Tailscale's resolvers exhaust nsncd's eight shared
  # NSS workers, starving local account lookups despite authentication needing
  # no DNS. Observed as ~10s Noctalia "Authorizing" delays and resume UI stalls;
  # nsncd hits its 10s handoff timeout and restarts. Reserve more headroom for
  # account lookups: 32 workers mitigate the measured burst, but do not isolate
  # authentication from DNS or fix the underlying resolver delay.
  systemd.services.nscd.environment.NSNCD_WORKER_COUNT = "32";

  system.stateVersion = (import ../../platform.nix).stateVersion;
}
