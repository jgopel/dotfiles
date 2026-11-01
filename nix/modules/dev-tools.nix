{ den, inputs, ... }:

{
  den.aspects.dev-tools = {
    includes = [
      den.aspects.rust
      den.aspects.nvim
      den.aspects.python
      den.aspects.cpp
    ];

    # Prek hooks download generic Linux binaries that expect /lib64/ld-linux-x86-64.so.2.
    provides.to-hosts.nixos.programs.nix-ld.enable = true;

    homeManager = { pkgs, ... }: {
      imports = [ inputs.nix-index-database.homeModules.nix-index ];

      home.packages = with pkgs; [ gdb ];

      programs = {
        fish.shellAliases.gdb = "gdb -silent";
        nix-index-database.comma.enable = true;
        direnv = {
          enable = true;
          nix-direnv.enable = true;
          config.global.log_format = builtins.fromJSON ''"\u001b[2mdirenv: %s\u001b[0m"'';
        };
      };
    };
  };
}
