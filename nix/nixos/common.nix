{ lib, pkgs, ... }:

{
  imports = [ ./nix.nix ];

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

  programs.nix-ld.enable = true;

  environment.systemPackages = with pkgs; [ vim ];
}
