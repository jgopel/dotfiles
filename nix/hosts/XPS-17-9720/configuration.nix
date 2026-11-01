{ ... }:

{
  imports = [
    ../../nixos/profiles/desktop.nix
    ../../nixos/users/jonathan.nix
    ../../nixos/boot/systemd-boot.nix
    ../../nixos/kernel-testing.nix
  ];

  programs.steam.enable = true;
}
