{ config, pkgs, inputs, ... }:

{
  home.shellAliases.amp = "nix run github:numtide/llm-agents.nix#amp --";

  home.packages = with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
    antigravity-cli
    claude-code
    codex
    pkgs.xclip # for amp clipboard usage
  ];

  xdg.configFile."amp/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/amp/settings.json";
  xdg.configFile."agents/skills".source = ../../agents/skills;

  home.file.".claude/statusline.sh" = {
    source = ../../claude/statusline.sh;
    executable = true;
  };
  home.file.".claude/settings.json".source = ../../claude/settings.json;
}
