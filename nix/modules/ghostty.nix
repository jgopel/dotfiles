{ den, repoRoot, ... }:

{
  den.aspects.ghostty = {
    includes = [ den.aspects.ghostty.terminfo ];

    homeManager.xdg.configFile."ghostty/config".source = repoRoot + /ghostty/config;

    hmLinux = { config, pkgs, ... }: {
      # Home Manager's wrapper is a no-op when nixGL is not configured.
      home.packages = [ (config.lib.nixGL.wrap pkgs.ghostty) ];
    };

    hmDarwin = { pkgs, ... }: { home.packages = [ pkgs.ghostty-bin ]; };

    terminfo = {
      homeManager.home.sessionVariables.TERMINFO_DIRS = "$HOME/.nix-profile/share/terminfo:/usr/share/terminfo";
      hmLinux = { pkgs, ... }: { home.packages = [ pkgs.ghostty.terminfo ]; };
      hmDarwin = { pkgs, ... }: { home.packages = [ pkgs.ghostty-bin.terminfo ]; };
    };
  };
}
