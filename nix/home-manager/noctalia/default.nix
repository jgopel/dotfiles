{
  config,
  inputs,
  pkgs,
  ...
}:

{
  imports = [ inputs.noctalia.homeModules.default ];

  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    settings = import ./settings.nix { inherit inputs; };
  };

  home.file."${config.xdg.stateHome}/noctalia/settings.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/noctalia/settings.toml";

  home.packages = [
    pkgs.lua5_5
    pkgs.util-linux
  ];
}
