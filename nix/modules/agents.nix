{ den, repoRoot, ... }:

{
  den.aspects.agents = {
    includes = [
      den.aspects.amp
      den.aspects.antigravity-cli
      den.aspects.claude-code
      den.aspects.codex
    ];

    homeManager.xdg.configFile."agents/skills".source = repoRoot + /agents/skills;
  };
}
