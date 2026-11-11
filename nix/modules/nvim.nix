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
          package = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.neovim;
          defaultEditor = true;
        };

        # sudoedit's editor lookup may use a secure_path without Nix profile binaries.
        home.sessionVariables.SUDO_EDITOR = "${config.programs.neovim.finalPackage}/bin/nvim";

        home.packages = with pkgs; [
          (config.lib.onepassword.wrap {
            name = "nvim-ai";
            package = config.programs.neovim.finalPackage;
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
          })

          # Plugin executables, independent of other CLI package selections.
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
