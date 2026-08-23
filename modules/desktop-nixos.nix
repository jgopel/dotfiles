{ pkgs, ... }:

{
  imports = [ ./desktop-common.nix ];

  home.packages = with pkgs; [
    discord
    firefox
    ghostty
    google-chrome
    polychromatic
    signal-desktop
    slack
  ];

  xdg.configFile."autostart/discord.desktop" = {
    source = "${pkgs.discord}/share/applications/discord.desktop";
    force = true;
  };
}
