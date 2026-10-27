{ inputs, ... }:

{
  den.aspects.codex.homeManager = { pkgs, ... }: {
    home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex ];
  };
}
