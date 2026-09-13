{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../nixos/arctis-sound-manager.nix
    ../../nixos/gnome.nix
    ../../nixos/razer-windows-vm.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages;

  services.fwupd.enable = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    extra-substituters = [ "https://cache.numtide.com" ];
    extra-trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
    ];
  };
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 14d";
  };

  networking.hostName = "XPS-17-9720-nixos";
  networking.networkmanager.enable = true;
  services.avahi.nssmdns4 = true;

  time.timeZone = "America/Denver";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
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

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.keyd = {
    enable = true;
    keyboards.builtIn = {
      ids = [ "0001:0001" ];
      settings.main = {
        capslock = "esc";
        esc = "capslock";
      };
    };
  };

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    powerManagement = {
      enable = true;
      kernelSuspendNotifier = true;
    };
    prime = {
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
      sync.enable = true;
    };
  };

  services.printing.enable = true;

  hardware.openrazer = {
    enable = true;
    users = [ "jonathan" ];
  };

  programs.razerWindowsVm.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  security.sudo.extraConfig = "Defaults pwfeedback";
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.jonathan = {
    isNormalUser = true;
    description = "Jonathan";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.fish;
  };

  programs.fish.enable = true;
  programs.steam.enable = true;

  programs.nix-ld.enable = true;

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [ vim ];

  system.stateVersion = (import ../../platform.nix).stateVersion;
}
