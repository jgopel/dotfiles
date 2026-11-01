{
  # Signal's existing database key must remain available without the GNOME desktop.
  den.aspects.signal.provides.to-hosts.nixos.services.gnome.gnome-keyring.enable = true;

  den.aspects.signal.homeManager = { pkgs, ... }: {
    home.packages = [
      # Keep access to the existing database key when switching GNOME/Hyprland.
      (pkgs.symlinkJoin {
        name = "signal-desktop-gnome-keyring";
        paths = [ pkgs.signal-desktop ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram "$out/bin/signal-desktop" \
            --add-flags '--password-store=gnome-libsecret'

          desktopEntry="$out/share/applications/signal.desktop"
          cp --remove-destination "${pkgs.signal-desktop}/share/applications/signal.desktop" "$desktopEntry"
          substituteInPlace "$desktopEntry" \
            --replace-fail 'Exec=signal-desktop %U' "Exec=$out/bin/signal-desktop %U"
        '';
      })
    ];
  };
}
