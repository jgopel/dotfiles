{ den, ... }:

{
  den.aspects.dev-tools = {
    includes = [
      den.aspects.rust
      den.aspects.nvim
      den.aspects.python
      den.aspects.cpp
    ];

    homeManager = { pkgs, ... }: {
      home.packages = with pkgs; [ gdb ];

      programs.fish.shellAliases.gdb = "gdb -silent";
    };
  };
}
