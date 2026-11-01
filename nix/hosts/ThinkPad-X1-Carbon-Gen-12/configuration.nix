{
  imports = [
    ../../nixos/users/jonathan.nix
    ../../nixos/boot/systemd-boot.nix
  ];

  boot.loader.systemd-boot.prioritizeNixOS = true;

  # After resume, DNS waits on Tailscale's resolvers exhaust nsncd's eight shared
  # NSS workers, starving local account lookups despite authentication needing
  # no DNS. Observed as ~10s Noctalia "Authorizing" delays and resume UI stalls;
  # nsncd hits its 10s handoff timeout and restarts. Reserve more headroom for
  # account lookups: 32 workers mitigate the measured burst, but do not isolate
  # authentication from DNS or fix the underlying resolver delay.
  systemd.services.nscd.environment.NSNCD_WORKER_COUNT = "32";
}
