{ repoRoot, ... }:

{
  den.aspects.git.homeManager = {
    programs.git = {
      enable = true;
      lfs.enable = true;
      includes = [ { path = repoRoot + /git/config; } ];
    };

    xdg.configFile."git/ignore".source = repoRoot + /git/ignore;
  };
}
