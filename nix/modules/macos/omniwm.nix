{ repoRoot, ... }:

{
  den.aspects.macos.omniwm = {
    homeManager =
      { config, pkgs, ... }:
      let
        # Schema 5 and sided Command bindings require this release. Retain
        # nixpkgs' bsdtar unpacking so the app's signature survives extraction.
        omniwm = pkgs.omniwm.overrideAttrs {
          version = "0.8.0";
          src = pkgs.fetchurl {
            url = "https://github.com/OmniNull/OmniWM/releases/download/v0.8.0/OmniWM-v0.8.0.zip";
            hash = "sha256-b3+z4hHeOoPncrExgAaAyz0g1MY4gRofAhIP0iXwPMc=";
          };
        };
      in
      {
        home.packages = [ omniwm ];
        # Merge only Spotlight's shortcut; a CustomUserPreferences dictionary
        # would replace all AppleSymbolicHotKeys, including unrelated shortcuts.
        home.activation.omniwmLauncherShortcut = config.lib.dag.entryAfter [ "writeBoundary" ] ''
          run /usr/bin/defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys \
            -dict-add 64 '<dict><key>enabled</key><false/></dict>'
        '';

        xdg.configFile = {
          "omniwm/settings.toml".source = repoRoot + /omniwm/settings.toml;
          # The bundled shell otherwise overrides settings.toml's bar placement.
          "omniwm/shell/shell.toml".source = repoRoot + /omniwm/shell.toml;
        };
        launchd.agents.omniwm = {
          enable = true;
          config = {
            ProgramArguments = [ "${omniwm}/Applications/OmniWM.app/Contents/MacOS/OmniWM" ];
            RunAtLoad = true;
            ProcessType = "Interactive";
            LimitLoadToSessionType = "Aqua";
          };
        };
      };

    provides.to-hosts.darwin.system.defaults.CustomUserPreferences = {
      # Disable native window management that competes with OmniWM.
      "com.apple.WindowManager" = {
        GloballyEnabled = false;
        EnableTilingByEdgeDrag = false;
        EnableTopTilingByEdgeDrag = false;
        EnableTilingOptionAccelerator = false;
      };
      # Horizontal three/four-finger swipes belong to OmniWM. Preserve
      # native vertical Mission Control/App Expose gestures.
      "com.apple.AppleMultitouchTrackpad" = {
        TrackpadThreeFingerHorizSwipeGesture = 0;
        TrackpadFourFingerHorizSwipeGesture = 0;
      };
      "com.apple.driver.AppleBluetoothMultitouch.trackpad" = {
        TrackpadThreeFingerHorizSwipeGesture = 0;
        TrackpadFourFingerHorizSwipeGesture = 0;
      };
      # Square window corners, as OmniWM's System-wide Window Corners "Square"
      # option stores them (macOS 26.4+). Apps apply it after a full relaunch.
      NSGlobalDomain = {
        NSConvolutionOverride1 = 0.01; # Standard windows
        NSConvolutionOverride2 = 0.01; # Panels
      };
    };
  };
}
