{ pkgs, ... }:

{
  # Need 7.3 for the TS5Plus USB XHCI fix; return to linuxPackages_latest
  # once that release is available there.
  boot.kernelPackages = pkgs.linuxPackages_testing;

  # Test this Thunderbolt runtime-PM fix across hosts for upstream inclusion.
  boot.kernelPatches = [
    {
      name = "thunderbolt-rpm-subtree";
      patch = ./thunderbolt-rpm-subtree.patch;
    }
  ];
}
