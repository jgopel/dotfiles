{ den, ... }:

{
  den.aspects.nvim = {
    includes = [
      den.aspects.cpp
      den.aspects.rust
      den.aspects.python
      den.aspects.editor-tools
    ];

    homeManager =
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

        # Plugin executables, independent of other CLI package selections.
        home.packages = with pkgs; [
          ast-grep
          gcc
          git
          ripgrep
          tree-sitter
        ];

        programs.fish.interactiveShellInit = ''
          set -gx VISUAL nvim
          set -gx EDITOR nvim
        '';

        xdg.configFile."nvim".source = "${dotfilesDir}/nvim";
      };
  };
}
