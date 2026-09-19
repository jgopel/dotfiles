{
  config,
  pkgs,
  inputs,
  ...
}:

{
  home = {
    shellAliases.amp = "nix run github:numtide/llm-agents.nix#amp --";

    packages = with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
      antigravity-cli
      claude-code
      codex
      pkgs.xclip # for amp clipboard usage
    ];

    file.".claude/statusline.sh" = {
      source = ../../claude/statusline.sh;
      executable = true;
    };
    file.".claude/settings.json".source = ../../claude/settings.json;
  };

  xdg.configFile."amp/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/amp/settings.json";
  xdg.configFile."agents/skills".source = ../../agents/skills;
}
