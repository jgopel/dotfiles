{ config, pkgs, ... }:

let
  dotfilesDir = builtins.toString ../..;
in
{
  programs.bash = {
    enable = true;

    initExtra = ''
      # Add ~/bin to PATH
      export PATH="$HOME/bin:$PATH"

      # Source the existing bashrc which handles all configuration
      # including host-specific files via hostname -s
      if [[ -f "${dotfilesDir}/bash/.bashrc" ]]; then
        . "${dotfilesDir}/bash/.bashrc"
      fi
    '';
  };

  home.file = {
    ".editrc".source = "${dotfilesDir}/bash/.editrc";
    ".inputrc".source = "${dotfilesDir}/bash/.inputrc";
  };
}
