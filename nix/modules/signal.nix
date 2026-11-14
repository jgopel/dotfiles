{
  den.aspects.signal = {
    # Signal's existing database key lives in GNOME Keyring.
    provides.to-hosts.nixos.services.gnome.gnome-keyring.enable = true;
    provides.to-hosts.darwin.homebrew.casks = [ "signal" ];

    hmLinux = { pkgs, ... }: {
      home.packages = [
        # Hyprland is not a desktop Electron recognizes, so name the key's store explicitly.
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
  };
}
