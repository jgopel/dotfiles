{
  imports = [ ./base.nix ];

  # Temporary diagnostics for the XPS's intermittent s2idle hang.
  boot.kernelPatches = [
    {
      name = "suspend-diagnostics";
      patch = ./suspend-diagnostics.patch;
    }
  ];
}
