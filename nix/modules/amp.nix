{
  den.aspects.amp.homeManager = { config, pkgs, ... }: {
    home.shellAliases.amp = "nix run github:numtide/llm-agents.nix#amp --";
    home.packages = [ pkgs.xclip ];

    xdg.configFile."amp/settings.json".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/amp/settings.json";
  };
}
