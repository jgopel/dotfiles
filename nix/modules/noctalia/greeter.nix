{
  # Separate from the main Noctalia feature only because some hosts still use
  # GNOME/GDM and the Noctalia greeter documents that support for Gnome is poor.
  den.aspects.noctalia-greeter.provides.to-hosts.nixos.services.displayManager.noctalia-greeter.enable =
    true;
}
