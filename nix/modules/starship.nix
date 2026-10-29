{ repoRoot, ... }:

{
  den.aspects.starship.homeManager = {
    programs.starship.enable = true;

    xdg.configFile."starship.toml".source = repoRoot + /starship.toml;
  };
}
