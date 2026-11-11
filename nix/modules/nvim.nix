{ den, repoRoot, ... }:

{
  den.aspects.nvim = {
    includes = [
      den.aspects."1pass"
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
      {
        programs.neovim = {
          enable = true;
          package = config.lib.onepassword.wrap {
            package = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.neovim;
            command = "nvim";
            secretNames = [ "OPENROUTER_API_KEY" ];
            skipArguments = [
              "--headless"
              "--embed"
              "-es"
              "-Es"
              "-l"
              "--version"
              "-v"
              "--help"
              "-h"
            ];
          };
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

        xdg.configFile."nvim".source = repoRoot + /nvim;
      };
  };
}
