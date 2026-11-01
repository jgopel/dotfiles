{ lib, ... }:

{
  imports = [ ./base.nix ];

  # Temporary diagnostics for the XPS's intermittent s2idle hang.
  boot.kernelPatches = [
    {
      name = "suspend-diagnostics";
      patch = ./suspend-diagnostics.patch;
      structuredExtraConfig = {
        EXPERT = lib.kernel.yes;
        PM_DEBUG = lib.kernel.yes;
        PSTORE = lib.kernel.yes;
        EFI_VARS_PSTORE = lib.kernel.yes;
        DPM_WATCHDOG = lib.kernel.yes;
        DPM_WATCHDOG_ENABLED = lib.kernel.yes;
        DPM_WATCHDOG_WARNING_TIMEOUT = lib.kernel.freeform "60";
        DPM_WATCHDOG_TIMEOUT = lib.kernel.freeform "120";
      };
    }
  ];
}
