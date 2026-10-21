{
  config,
  pkgs,
  inputs,
  ...
}:

# Desktop applications wrapped for standalone Home Manager on non-NixOS Linux.
let
  wrap = config.lib.nixGL.wrap;

  withRuntimeDirTmp =
    package:
    pkgs.symlinkJoin {
      name = "${package.name}-runtime-dir";
      paths = [ package ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        for executable in "$out/bin/"*; do
          [ -f "$executable" ] || continue
          wrapProgram "$executable" \
            --run 'export TMPDIR="''${XDG_RUNTIME_DIR:-/tmp}"'
        done

        for sourceDesktopEntry in "${package}/share/applications/"*.desktop; do
          [ -e "$sourceDesktopEntry" ] || continue
          if grep -qF "${package}/" "$sourceDesktopEntry"; then
            desktopEntry="$out/share/applications/$(basename "$sourceDesktopEntry")"
            cp --remove-destination "$sourceDesktopEntry" "$desktopEntry"
            substituteInPlace "$desktopEntry" \
              --replace-fail "${package}/" "$out/"
          fi
        done
      '';
    };

  wrappedChrome = withRuntimeDirTmp (wrap pkgs.google-chrome);
  wrappedDiscord = withRuntimeDirTmp (wrap pkgs.discord);
  wrappedFirefox = wrap pkgs.firefox;
  wrappedGhostty = wrap pkgs.ghostty;
  wrappedSignal = withRuntimeDirTmp (wrap pkgs.signal-desktop);
  wrappedSlack = withRuntimeDirTmp (wrap (pkgs.callPackage ./slack-package.nix { }));
in
{
  imports = [ ./desktop-common.nix ];

  targets.genericLinux.nixGL.packages = inputs.nixgl.packages;

  home.sessionVariables.LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [ pkgs.nssmdns ];

  home.packages = with pkgs; [
    polychromatic
    wrappedChrome
    wrappedDiscord
    wrappedFirefox
    wrappedGhostty
    wrappedSignal
    wrappedSlack
  ];

  xdg = {
    configFile."autostart/discord.desktop" = {
      source = "${wrappedDiscord}/share/applications/discord.desktop";
      force = true;
    };

    desktopEntries = {
      ghostty = {
        name = "Ghostty";
        exec = "${wrappedGhostty}/bin/ghostty --gtk-single-instance=true";
        icon = "com.mitchellh.ghostty";
        terminal = false;
        categories = [
          "System"
          "TerminalEmulator"
        ];
        comment = "A terminal emulator";
        settings = {
          StartupNotify = "true";
          StartupWMClass = "com.mitchellh.ghostty";
        };
      };

      # Hide the original unwrapped .desktop file from the ghostty package
      "com.mitchellh.ghostty" = {
        name = "Ghostty (unwrapped)";
        exec = "false";
        noDisplay = true;
      };

      google-chrome = {
        name = "Google Chrome";
        exec = "google-chrome-stable %U";
        icon = "google-chrome";
        terminal = false;
        categories = [
          "Network"
          "WebBrowser"
        ];
        comment = "Access the Internet";
      };

      # Hide the original unwrapped .desktop files from the google-chrome package
      "com.google.Chrome" = {
        name = "Google Chrome (unwrapped)";
        exec = "false";
        noDisplay = true;
      };
    };
  };
}
