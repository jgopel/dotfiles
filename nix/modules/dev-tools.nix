{ den, inputs, ... }:

{
  den.aspects.dev-tools = {
    includes = [
      den.aspects.rust
      den.aspects.nvim.dev
      den.aspects.python
      den.aspects.cpp
    ];

    # Prek hooks download generic Linux binaries that expect /lib64/ld-linux-x86-64.so.2.
    provides.to-hosts.nixos.programs.nix-ld.enable = true;

    homeManager = {
      imports = [ inputs.nix-index-database.homeModules.nix-index ];

      programs = {
        nix-index-database.comma.enable = true;
        direnv = {
          enable = true;
          nix-direnv.enable = true;
          config.global.log_format = builtins.fromJSON ''"\u001b[2mdirenv: %s\u001b[0m"'';
        };
      };
    };

    hmLinux = { pkgs, ... }: {
      home.packages = with pkgs; [
        gdb
        perf
        strace
      ];
      programs.fish.shellAliases.gdb = "gdb -silent";
    };

    hmDarwin = { pkgs, ... }: { home.packages = [ pkgs.lldb ]; };
  };
}
