{ inputs, ... }:

{
  den.aspects.antigravity-cli.homeManager = { pkgs, ... }: {
    home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.antigravity-cli ];
  };
}
