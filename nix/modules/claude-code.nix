{ inputs, ... }:

{
  den.aspects.claude-code.homeManager = { pkgs, ... }: {
    home = {
      packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code ];

      file.".claude/statusline.sh" = {
        source = ../../claude/statusline.sh;
        executable = true;
      };
      file.".claude/settings.json".source = ../../claude/settings.json;
    };
  };
}
