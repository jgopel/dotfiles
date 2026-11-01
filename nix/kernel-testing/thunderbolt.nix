{
  imports = [ ./base.nix ];

  # Test this Thunderbolt runtime-PM fix across hosts for upstream inclusion.
  boot.kernelPatches = [
    {
      name = "thunderbolt-rpm-subtree";
      patch = ./thunderbolt-rpm-subtree.patch;
    }
  ];
}
