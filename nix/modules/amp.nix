{
  den.aspects.amp = {
    homeManager = { config, ... }: {
      home.shellAliases = {
        amp = "nix run --option tarball-ttl 86400 github:numtide/llm-agents.nix#amp --";
        amp-update = "nix run --refresh github:numtide/llm-agents.nix#amp --";
      };

      xdg.configFile."amp/settings.json".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/amp/settings.json";
    };

    hmLinux = { pkgs, ... }: { home.packages = [ pkgs.xclip ]; };
  };
}
