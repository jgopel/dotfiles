{ den, repoRoot, ... }:

{
  den.aspects.ghostty = {
    includes = [ den.aspects.ghostty.terminfo ];

    homeManager = { config, pkgs, ... }: {
      # Home Manager's wrapper is a no-op when nixGL is not configured.
      home.packages = [ (config.lib.nixGL.wrap pkgs.ghostty) ];

      xdg.configFile."ghostty/config".source = repoRoot + /ghostty/config;
    };

    terminfo.homeManager = { pkgs, ... }: {
      home.packages = [ pkgs.ghostty.terminfo ];

      home.sessionVariables.TERMINFO_DIRS = "$HOME/.nix-profile/share/terminfo:/usr/share/terminfo";
    };
  };
}
