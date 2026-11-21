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

    homeManager.xdg.configFile = {
      "agents/skills/ask-questions-if-underspecified".source =
        "${inputs.trailofbits-skills}/plugins/ask-questions-if-underspecified/skills/ask-questions-if-underspecified";
      "agents/skills/brainstorming".source = "${inputs.superpowers}/skills/brainstorming";
      "agents/skills/socratic-tutor".source = "${inputs.janestreet-agent-skills}/socratic-tutor";
      "agents/skills/systematic-debugging".source = "${inputs.superpowers}/skills/systematic-debugging";
      "agents/skills/writing-rust-code".source = repoRoot + /agents/skills/writing-rust-code;
    };

    desktop.hmLinux = { pkgs, ... }: {
      home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.amp-desktop ];
    };
  };
}
