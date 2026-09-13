{ pkgs, inputs, ... }:

let
  dotfilesDir = builtins.toString ../..;
in
{
  programs.neovim = {
    enable = true;
    package = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.neovim;
    defaultEditor = true;
  };

  xdg.configFile."nvim".source = "${dotfilesDir}/nvim";
}
