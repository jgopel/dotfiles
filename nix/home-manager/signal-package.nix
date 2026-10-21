{
  signal-desktop,
  symlinkJoin,
  makeWrapper,
}:

# Keep access to the existing database key when switching GNOME/Hyprland.
symlinkJoin {
  name = "signal-desktop-gnome-keyring";
  paths = [ signal-desktop ];
  nativeBuildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram "$out/bin/signal-desktop" \
      --add-flags '--password-store=gnome-libsecret'

    desktopEntry="$out/share/applications/signal.desktop"
    cp --remove-destination "${signal-desktop}/share/applications/signal.desktop" "$desktopEntry"
    substituteInPlace "$desktopEntry" \
      --replace-fail 'Exec=signal-desktop %U' "Exec=$out/bin/signal-desktop %U"
  '';
}
