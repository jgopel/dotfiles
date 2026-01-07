{ config, pkgs, ... }:

let
  dotfilesDir = builtins.toString ./..;
in
{
  programs.neovim = {
    enable = true;
    package = pkgs.neovim;
    defaultEditor = true;
  };

  xdg.configFile = {
    "nvim/init.lua".source = "${dotfilesDir}/nvim/init.lua";
    "nvim/lua/config/lazy.lua".source = "${dotfilesDir}/nvim/lua/config/lazy.lua";
  };
}
