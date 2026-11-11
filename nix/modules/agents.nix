{
  den,
  inputs,
  repoRoot,
  ...
}:

{
  den.aspects.agents = {
    includes = [
      den.aspects.amp
      den.aspects.antigravity-cli
      den.aspects.claude-code
      den.aspects.codex
    ];

    homeManager.xdg.configFile."agents/skills".source = repoRoot + /agents/skills;

    desktop.homeManager = { pkgs, ... }: {
      home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.amp-desktop ];
    };
  };
}
