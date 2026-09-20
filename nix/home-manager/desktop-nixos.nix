{ pkgs, ... }:

{
  imports = [
    ./desktop-common.nix
    ./gnome
  ];

  programs.firefox = {
    enable = true;
    policies.Preferences."widget.gtk.native-emoji-dialog" = {
      # Keep Ctrl+. available for 1Password in every profile.
      Value = false;
      Status = "locked";
    };
  };

  home.packages = with pkgs; [
    discord
    ghostty
    google-chrome
    polychromatic
    signal-desktop
    slack
  ];

  xdg.configFile = {
    "autostart/dropbox.desktop" = {
      source = "${pkgs.dropbox}/share/applications/dropbox.desktop";
      force = true;
    };
    "autostart/discord.desktop" = {
      source = "${pkgs.discord}/share/applications/discord.desktop";
      force = true;
    };
    "autostart/steam.desktop" = {
      source = pkgs.runCommand "steam-autostart.desktop" { } ''
        substitute ${pkgs.steam-unwrapped}/share/applications/steam.desktop $out \
          --replace-fail "Exec=steam %U" "Exec=steam -silent %U"
      '';
      force = true;
    };
    "autostart/slack.desktop" = {
      source = "${pkgs.slack}/share/applications/slack.desktop";
      force = true;
    };
    "autostart/signal.desktop" = {
      source = "${pkgs.signal-desktop}/share/applications/signal.desktop";
      force = true;
    };
  };
}
