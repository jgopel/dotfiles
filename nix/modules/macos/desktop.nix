{
  den.aspects.macos.desktop = {
    provides.to-hosts.darwin = {
      homebrew = {
        enable = true;
        # Do not remove apps installed outside this configuration or upgrade
        # unrelated applications as a side effect of switching generations.
        onActivation = {
          cleanup = "none";
          autoUpdate = false;
          upgrade = false;
        };
      };

      system.defaults = {
        dock = {
          mru-spaces = false;
          autohide = true;
        };
        spaces.spans-displays = false;
        NSGlobalDomain = {
          ApplePressAndHoldEnabled = false;
          # Fast held-key navigation in Neovim and other applications.
          KeyRepeat = 2;
          InitialKeyRepeat = 15;
          "com.apple.swipescrolldirection" = false;
        };
      };
    };
  };
}
