{ config, pkgs, ... }:

let
  dotfilesDir = builtins.toString ../..;
in
{
  programs.neovim = {
    enable = true;
    package = pkgs.neovim;
    defaultEditor = true;
  };

  xdg.configFile."nvim".source = "${dotfilesDir}/nvim";
}
