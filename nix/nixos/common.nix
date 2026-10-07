{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./btop.nix
    ./nix.nix
  ];

  time.timeZone = lib.mkDefault "America/Denver";

  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  i18n.extraLocaleSettings = lib.mkDefault {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  security.sudo.extraConfig = "Defaults pwfeedback";
  nixpkgs.config.allowUnfree = true;

  # Allow Oryx browser flashing and live training for ZSA keyboards.
  hardware.keyboard.zsa.enable = true;

  virtualisation.docker.enable = true;
  # NOTE: Docker group membership grants root-equivalent access via the root-owned daemon.
  users.groups.docker.members = lib.attrNames (
    lib.filterAttrs (_: user: user.isNormalUser) config.users.users
  );

  programs.nix-ld.enable = true;

  environment.systemPackages = with pkgs; [ vim ];
}
