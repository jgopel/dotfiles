{ pkgs, ... }:

{
  home.packages = [ pkgs.ghostty.terminfo ];

  home.sessionVariables.TERMINFO_DIRS = "$HOME/.nix-profile/share/terminfo:/usr/share/terminfo";
}
