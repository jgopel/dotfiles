{
  config,
  pkgs,
  inputs,
  ...
}:

let
  dotfilesDir = builtins.toString ../..;
in
{
  programs.neovim = {
    enable = true;
    package = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.neovim;
    defaultEditor = true;
  };

  # sudoedit's editor lookup may use a secure_path without Nix profile binaries.
  home.sessionVariables.SUDO_EDITOR = "${config.programs.neovim.finalPackage}/bin/nvim";

  xdg.configFile."nvim".source = "${dotfilesDir}/nvim";
}
