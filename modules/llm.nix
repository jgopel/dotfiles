{ config, pkgs, llm-agents, ... }:

let
  llm-packages = llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  home.packages = with llm-packages; [
    amp
    claude-code
    # gemini-cli  # FIXME: upstream hash mismatch in llm-agents
    # codex # TODO: This takes forever to build. Revive eventually
  ];
}
